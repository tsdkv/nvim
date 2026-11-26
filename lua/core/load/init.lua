local M = {}
local H = {}

H.augroup = function(name)
    return vim.api.nvim_create_augroup(name, { clear = true })
end

-- Named modules share an attempt across triggers. Each callback registration gets its own.
H.modules = {}
H.last_callback = setmetatable({}, { __mode = "k" })
H.trace_log = {}
H.triggers = H.augroup("CoreLoadTriggers")

local function callback_label(fn)
    local info = debug.getinfo(fn, "S")
    return ("%s:%d"):format(info.short_src, info.linedefined)
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

local function setup_module(mod)
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

local function traceback(err)
    return debug.traceback(tostring(err), 2)
end

local function execute(target)
    if type(target) == "function" then
        return xpcall(target, traceback)
    end

    local previous = package.loaded[target]
    local ok, mod = xpcall(require, traceback, target)
    if not ok then
        -- LuaJIT can leave a failed require marked as in progress. Allow an explicit retry.
        package.loaded[target] = previous
        return false, mod
    end
    return xpcall(setup_module, traceback, mod)
end

local function register(target, phase, label)
    local named = type(target) == "string"
    if not named and type(target) ~= "function" then
        vim.notify(("Invalid loader target: %s"):format(type(target)), vim.log.levels.ERROR)
        return function() end
    end

    local entry = named and H.modules[target] or nil
    if not entry or (entry.status == "failed" and phase == "ensure") then
        entry = {
            target = label or (named and target or callback_label(target)),
            phase = phase,
            status = "registered",
            registered_at = vim.uv.hrtime(),
        }
        table.insert(H.trace_log, entry)
        if named then
            H.modules[target] = entry
        end
    end

    return function(reason)
        if entry.status ~= "registered" then
            return
        end

        local parent = H.current
        entry.trigger = phase
        entry.reason = reason or phase
        entry.parent = parent and parent.target
        entry.status = "running"
        entry.start_time = vim.uv.hrtime()
        H.current = entry
        if not named then
            H.last_callback[target] = entry
        end
        local ok, err = execute(target)
        H.current = parent
        entry.duration_ms = (vim.uv.hrtime() - entry.start_time) / 1e6
        if ok then
            entry.status = "loaded"
        else
            entry.status = "failed"
            entry.err = tostring(err)
            local summary = entry.err:match("^[^\n]*") or entry.err
            vim.notify(("Config Error [%s]: %s (see :LoadTrace)"):format(entry.target, summary), vim.log.levels.WARN)
        end
    end
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
        local run = H.queue[head]

        -- Free the memory immediately so the GC can clean up the closure
        H.queue[head] = nil
        H.queue_head = head + 1

        run()

        H.draining = false
        drain()
    end)
end

M.now = function(target, label)
    register(target, "now", label)()
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
    H.queue[H.queue_tail] = register(target, "later", label)
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

--- Run a registration on the first matching event across all its events and patterns.
---@param events string|string[]
---@param target string|function
---@param pattern? string|string[]
---@param label? string
M.on_event = function(events, target, pattern, label)
    local run = register(target, "event", label)
    local id
    id = vim.api.nvim_create_autocmd(events, {
        group = H.triggers,
        pattern = pattern,
        callback = function(ev)
            vim.api.nvim_del_autocmd(id)
            local reason = ev.event
            if ev.event == "User" or ev.event == "FileType" then
                reason = reason .. " " .. ev.match
            end
            run(reason)
        end,
    })
end

--- Schedule setup for an already-open filetype, or when the first matching buffer opens.
---@param filetypes string|string[]
---@param target string|function
---@param label? string
M.on_filetype = function(filetypes, target, label)
    local run = register(target, "filetype", label)
    local fts = type(filetypes) == "table" and filetypes or { filetypes }
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
            local ft = vim.bo[buf].filetype
            if vim.tbl_contains(fts, ft) then
                vim.schedule(function()
                    run("existing " .. ft .. " buffer")
                end)
                return
            end
        end
    end

    local id
    id = vim.api.nvim_create_autocmd("FileType", {
        group = H.triggers,
        pattern = fts,
        callback = function(ev)
            vim.api.nvim_del_autocmd(id)
            vim.schedule(function()
                run("FileType " .. ev.match)
            end)
        end,
    })
end

--- A named module, or the most recently executed registration of this callback, succeeded.
---@param target string|function
---@return boolean
M.loaded = function(target)
    local entry = H.modules[target] or H.last_callback[target]
    return entry ~= nil and entry.status == "loaded"
end

--- Run immediately. Only an explicit ensure retries a failed named module.
---@param target string|function
---@param label? string
M.ensure = function(target, label)
    register(target, "ensure", label)()
end

M.get_trace = function()
    return H.trace_log
end

--- Exposed for buffer-local keymaps (LSP on_attach, etc.)
M.keymap = keymap

return M
