local M = {}
local H = {}

H.augroup = function(name)
    return vim.api.nvim_create_augroup(name, { clear = true })
end

-- Generates a clean, unique and stable string key for any target type
local function get_target_key(target)
    if type(target) == "string" then
        return target
    end

    -- Extract file and line number for anonymous functions
    local info = debug.getinfo(target, "Sl")
    if info and info.short_src then
        local filename = info.short_src:match("^.+/(.+)$") or info.short_src
        return string.format("%s_%d", filename:gsub("%.", "_"), info.linedefined)
    end

    -- Fallback: strip invalid characters from the function memory address
    return tostring(target):gsub("[^%w]", "_")
end

-- H.done tracks which string targets have already been executed,
-- preventing double-setup when the same module is scheduled from multiple places.
H.done = {}

-- Log history tracking
H.trace_log = {}
H.trace_map = {}

local function record_registration(target, phase, label)
    local key = label or get_target_key(target)
    if not H.trace_map[key] then
        local entry = {
            target = key,
            phase = phase,
            status = "registered",
            registered_at = vim.uv.hrtime(),
        }
        H.trace_map[key] = entry
        table.insert(H.trace_log, entry)
    end
end

local function record_load_start(target, label)
    local key = label or get_target_key(target)
    local entry = H.trace_map[key]
    if entry then
        entry.status = "loading"
        entry.start_time = vim.uv.hrtime()
    end
end

local function record_load_end(target, status, err, label)
    local key = label or get_target_key(target)
    local entry = H.trace_map[key]
    if entry then
        entry.status = status
        if err then
            entry.err = err
        end
        if entry.start_time then
            entry.duration_ms = (vim.uv.hrtime() - entry.start_time) / 1e6
        end
    end
end

--- Process a keymap spec table. Calls vim.keymap.set() for each entry.
---
--- Format (same as which-key wk.add() spec):
---   { [1]=lhs, [2]=rhs, desc=string, mode?=string|table, buffer?=number, expr?=bool }
--- Group-only entries (no [2]) are skipped.
---
---@param specs table[]
---@param opts? table  Shared options merged into each entry (e.g. { buffer = bufnr })
local function keymap(specs, opts)
    opts = opts or {}
    for _, k in ipairs(specs) do
        if k[2] ~= nil then
            local mode = k.mode or "n"
            vim.keymap.set(mode, k[1], k[2], {
                desc = k.desc,
                buffer = k.buffer or opts.buffer,
                silent = k.silent ~= false,
                noremap = k.noremap ~= false,
                expr = k.expr,
            })
        end
    end
end

-- Cache for resolved wrapper closures to prevent redundant allocations
H.resolved_cache = {}

-- Resolves a target (string module name or function) into a callable.
-- String: require the module, then call .setup() if it exists.
--         Wrapped in H.done guard to ensure setup() runs at most once.
-- Function: used as-is.
-- Invalid type: notifies with ERROR and returns a no-op to prevent crashes.
local function resolve(target, label)
    local key = label or get_target_key(target)

    if H.resolved_cache[key] then
        return H.resolved_cache[key]
    end

    local run_load

    if type(target) == "function" then
        run_load = target
    elseif type(target) == "string" then
        run_load = function()
            local mod = require(target)
            if type(mod) ~= "table" then
                return
            end

            if type(mod.setup) == "function" then
                mod.setup()
            end
            if type(mod.keymap) == "table" then
                keymap(mod.keymap)
            end
        end
    else
        vim.notify(("lib: invalid target type '%s'"):format(type(target)), vim.log.levels.ERROR)
        return function() end
    end

    local wrapper = function()
        if H.done[key] then
            return
        end
        H.done[key] = true

        record_load_start(target, label)
        local ok, err = pcall(run_load)
        if ok then
            record_load_end(target, "success", nil, label)
        else
            record_load_end(target, "failed", tostring(err), label)
            vim.notify(("Config Error [%s]: %s"):format(key, tostring(err)), vim.log.levels.WARN)
        end
    end

    H.resolved_cache[key] = wrapper
    return wrapper
end

-- One-per-tick queue: each later() task runs on its own event-loop tick so
-- the UI can redraw between tasks.
H.queue = {}
H.queue_head = 1
H.queue_tail = 1
H.draining = false

local function drain()
    if H.draining or H.queue_head == H.queue_tail then
        return
    end
    H.draining = true

    vim.schedule(function()
        local head = H.queue_head
        local item = H.queue[head]

        -- Free the memory immediately so the GC can clean up the closure
        H.queue[head] = nil
        H.queue_head = head + 1

        item.fn()

        H.draining = false
        drain()
    end)
end

M.now = function(target, label)
    record_registration(target, "now", label)
    resolve(target, label)()
end

H.later_group = H.augroup("CoreLoadLaterStart")
H.has_autocmd = false

--- Defers the execution of a target to keep the main thread responsive.
---
--- Targets are placed in a one-per-tick FIFO queue. If the editor is still
--- starting up, the queue waits for the `VimEnter` event. Otherwise, it
--- begins processing immediately via `vim.schedule`.
---
--- Target resolution:
--- - `function`: Executed as-is.
--- - `string`: Treated as a module name. It is safely required, and its
---   `.setup()` function is called *only* if the module returns a table
---   that actually contains one.
---
---@param target string|function The module name to require, or a function to call.
---@param label? string Optional label for the trace output.
M.later = function(target, label)
    record_registration(target, "later", label)

    H.queue[H.queue_tail] = { fn = resolve(target, label), label = label or get_target_key(target) }
    H.queue_tail = H.queue_tail + 1

    if vim.v.vim_did_enter == 1 then
        drain()
        return
    end

    if not H.has_autocmd then
        H.has_autocmd = true
        vim.api.nvim_create_autocmd("VimEnter", {
            group = H.later_group,
            once = true,
            callback = function()
                drain()

                vim.api.nvim_del_augroup_by_id(H.later_group)
            end,
        })
    end
end

--- Defers the execution of a target until a specific autocommand event or events fire.
---
--- The autocommand is configured to trigger exactly once (`once = true`) and
--- immediately self-deletes upon invocation to clean up memory and prevent
--- duplicate setup triggers.
---
---@param events string|string[] The autocommand event or list of events (e.g., "BufReadPre", "LspAttach").
---@param target string|function The module name to require, or a function to call.
---@param pattern string|nil Optional pattern to filter autocommand events (e.g., "*.go").
---@param label? string Optional label for the trace output.
M.on_event = function(events, target, pattern, label)
    record_registration(target, "event", label)

    local target_key = label or get_target_key(target)
    local group = H.augroup("CoreLoadLoadOnEvent_" .. target_key)

    vim.api.nvim_create_autocmd(events, {
        once = true,
        group = group,
        pattern = pattern,
        callback = function()
            resolve(target, label)()

            vim.api.nvim_del_augroup_by_id(group)
        end,
    })
end

--- Defers the execution of a target until a specific filetype is opened.
---
--- This function safely manages the plugin lifecycle by allowing nested
--- events for proper initialization, aggressively self-deleting the
--- autocmd to prevent reentrancy loops, and deferring the actual load
--- to the event loop (`vim.schedule`) to keep the editor UI responsive.
---
--- If a buffer with a matching filetype is already open at registration
--- time, the target is scheduled immediately and the autocmd is skipped.
---
---@param filetypes string|string[] The filetype pattern(s) to match (e.g., "go", "lua").
---@param target string|function The module name to require, or a function to call.
---@param label? string Optional label for the trace output.
M.on_filetype = function(filetypes, target, label)
    record_registration(target, "filetype", label)

    local target_key = label or get_target_key(target)
    local group = H.augroup("CoreLoadFiletype_" .. target_key)

    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = filetypes,
        -- Allow nested events so the loaded plugin can trigger its own
        -- syntax or initialization autocmds seamlessly.
        nested = true,
        callback = function()
            -- Immediately delete the autocmd group before executing the target.
            -- This prevents infinite recursion if the plugin happens to open
            -- another buffer or trigger the same filetype internally.
            vim.api.nvim_del_augroup_by_id(group)

            -- Defer the actual loading process to the next event loop tick.
            -- This allows Neovim to immediately render the newly opened file
            -- to the screen without causing the UI to freeze.
            vim.schedule(resolve(target, label))
        end,
    })

    -- Handle buffers already open at registration time: if a matching filetype
    -- is already loaded, skip the autocmd entirely and schedule immediately.
    local fts = type(filetypes) == "table" and filetypes or { filetypes }
    local ft_set = {}
    for _, ft in ipairs(fts) do
        ft_set[ft] = true
    end

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and ft_set[vim.bo[buf].filetype] then
            vim.api.nvim_del_augroup_by_id(group)
            vim.schedule(resolve(target, label))
            return
        end
    end
end

--- Returns true if the target has already been executed by the loader.
--- Only reliable for string targets; function targets use a debug-info key.
---
---@param target string|function
---@return boolean
M.loaded = function(target)
    return H.done[get_target_key(target)] == true
end

--- Executes target immediately if it has not already been loaded.
--- Idempotent: safe to call multiple times or from multiple places.
--- Intended for explicit dependency management inside setup() functions.
---
--- Example:
---   M.setup = function()
---       load.ensure('mason')  -- guarantee mason is ready before continuing
---       require('mason-tool-installer').setup({ ... })
---   end
---
---@param target string|function The module name to require, or a function to call.
---@param label? string Optional label for the trace output.
M.ensure = function(target, label)
    record_registration(target, "ensure", label)

    resolve(target, label)()
end

M.get_trace = function()
    return H.trace_log
end

--- Exposed for buffer-local keymaps (LSP on_attach, etc.)
M.keymap = keymap

return M
