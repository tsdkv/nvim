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
H.trace = {}

local function record_registration(target, phase)
    local key = get_target_key(target)
    if not H.trace[key] then
        local entry = {
            target = key,
            phase = phase,
            status = "registered",
            registered_at = vim.uv.hrtime(),
        }
        H.trace[key] = entry
        table.insert(H.trace, entry)
    end
end

local function record_load_start(target)
    local key = get_target_key(target)
    local entry = H.trace[key]
    if entry then
        entry.status = "loading"
        entry.start_time = vim.uv.hrtime()
    end
end

local function record_load_end(target, status, err)
    local key = get_target_key(target)
    local entry = H.trace[key]
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

-- Resolves a target (string module name or function) into a callable.
-- String: require the module, then call .setup() if it exists.
--         Wrapped in H.done guard to ensure setup() runs at most once.
-- Function: used as-is.
-- Invalid type: notifies with ERROR and returns a no-op to prevent crashes.
local function resolve(target)
    local key = get_target_key(target)
    local run_load

    if type(target) == "function" then
        run_load = target
    elseif type(target) == "string" then
        run_load = function()
            local mod = require(target)
            if type(mod) == "table" and type(mod.setup) == "function" then
                mod.setup()
            end
        end
    else
        vim.notify(("lib: invalid target type '%s'"):format(type(target)), vim.log.levels.ERROR)
        return function() end
    end

    return function()
        if H.done[key] then
            return
        end
        H.done[key] = true

        record_load_start(target)
        local ok, err = pcall(run_load)
        if ok then
            record_load_end(target, "success")
        else
            record_load_end(target, "failed", tostring(err))
            vim.notify(("Config Error [%s]: %s"):format(key, tostring(err)), vim.log.levels.WARN)
        end
    end
end

-- One-per-tick queue: each later() task runs on its own event-loop tick so
-- the UI can redraw between tasks.
H.queue, H.draining = {}, false
local function drain()
    if H.draining or #H.queue == 0 then
        return
    end
    H.draining = true

    vim.schedule(function()
        local item = table.remove(H.queue, 1)
        item.fn()
        H.draining = false
        drain()
    end)
end

M.now = function(target)
    record_registration(target, "now")
    resolve(target)()
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
M.later = function(target)
    record_registration(target, "later")

    table.insert(H.queue, { fn = resolve(target), label = get_target_key(target) })

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
M.on_event = function(events, target, pattern)
    record_registration(target, "event")

    local target_key = get_target_key(target)
    local group = H.augroup("CoreLoadLoadOnEvent_" .. target_key)

    vim.api.nvim_create_autocmd(events, {
        once = true,
        group = group,
        pattern = pattern,
        callback = function()
            resolve(target)()

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
M.on_filetype = function(filetypes, target)
    record_registration(target, "filetype")

    local target_key = get_target_key(target)
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
            vim.schedule(resolve(target))
        end,
    })

    -- Handle buffers already open at registration time: if a matching filetype
    -- is already loaded, skip the autocmd entirely and schedule immediately.
    local fts = type(filetypes) == "table" and filetypes or { filetypes }
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.tbl_contains(fts, vim.bo[buf].filetype) then
            vim.api.nvim_del_augroup_by_id(group)
            vim.schedule(resolve(target))
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
M.ensure = function(target)
    record_registration(target, "ensure")

    resolve(target)()
end

M.get_trace = function()
    return H.trace
end

return M
