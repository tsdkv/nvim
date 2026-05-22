local M = {}
local H = {}

local function wrap(f)
    local ok, err = pcall(f)
    if not ok then
        vim.notify("Config Error: " .. tostring(err), vim.log.levels.WARN)
    end
end

M.augroup = function(name)
    return vim.api.nvim_create_augroup(name, { clear = true })
end

M.safe_require = function(name)
    local ok, mod = pcall(require, name)
    if not ok then
        vim.notify("Failed to load: " .. name, vim.log.levels.WARN)
        return nil
    end
    return mod
end

-- Resolves a target (string module name or function) into a callable.
-- String: safe_require the module, then call .setup() if it exists.
-- Function: used as-is.
-- Invalid type: notifies with ERROR and returns a no-op to prevent crashes.
local function resolve(target)
    if type(target) == 'function' then return target end

    if type(target) == 'string' then
        return function()
            local mod = M.safe_require(target)

            if not mod then return end

            if type(mod) ~= 'table' then return end

            if type(mod.setup) == 'function' then
                mod.setup()
            end
        end
    end

    vim.notify(
        ("lib: invalid target type '%s'"):format(type(target)),
        vim.log.levels.ERROR
    )
    return function() end
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

-- One-per-tick queue: each later() task runs on its own event-loop tick so
-- the UI can redraw between tasks.
H.queue, H.draining = {}, false
local function drain()
    if H.draining or #H.queue == 0 then return end
    H.draining = true

    vim.schedule(function()
        local f = table.remove(H.queue, 1)
        wrap(f)
        H.draining = false
        drain()
    end)
end

M.now = function(target)
    wrap(resolve(target))
end

H.later_group = M.augroup("CoreLoadLaterStart")
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
    table.insert(H.queue, resolve(target))

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
            end
        })
    end
end

M.now_if_args = function(f)
    if vim.fn.argc(-1) > 0 then M.now(f) else M.later(f) end
end

M.on_event = function(events, target, pattern)
    local target_key = get_target_key(target)
    local group = M.augroup('CoreLoadLoadOnEvent_' .. target_key)

    vim.api.nvim_create_autocmd(events, {
        once     = true,
        group    = group,
        pattern  = pattern,
        callback = function()
            wrap(resolve(target))

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
---@param filetypes string|string[] The filetype pattern(s) to match (e.g., "go", "lua").
---@param target string|function The module name to require, or a function to call.
M.on_filetype = function(filetypes, target)
    local target_key = get_target_key(target)
    local group = M.augroup('CoreLoadFiletype_' .. target_key)

    vim.api.nvim_create_autocmd("FileType", {
        group    = group,
        pattern  = filetypes,
        -- Allow nested events so the loaded plugin can trigger its own
        -- syntax or initialization autocmds seamlessly.
        nested   = true,
        callback = function()
            -- Immediately delete the autocmd group before executing the target.
            -- This prevents infinite recursion if the plugin happens to open
            -- another buffer or trigger the same filetype internally.
            vim.api.nvim_del_augroup_by_id(group)

            -- Defer the actual loading process to the next event loop tick.
            -- This allows Neovim to immediately render the newly opened file
            -- to the screen without causing the UI to freeze.
            vim.schedule(function()
                wrap(resolve(target))
            end)
        end,
    })
end

-- Stub keymap: on first press removes itself, runs the target, then replays
-- the key so the real handler (registered by target's setup) fires.
-- If setup fails, notifies and skips replay to avoid triggering an unregistered handler.
M.on_key = function(lhs, target, mode)
    mode = mode or 'n'
    local fn = resolve(target)
    vim.keymap.set(mode, lhs, function()
        pcall(vim.keymap.del, mode, lhs)
        local ok, err = pcall(fn)
        if not ok then
            vim.notify("Config Error: " .. tostring(err), vim.log.levels.WARN)
            return
        end
        vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes(lhs, true, false, true),
            'm', false
        )
    end, { silent = true })
end

-- Stub command: on first invocation removes itself, runs the target, then
-- re-executes the command with original args.
-- If setup fails, notifies and skips replay to avoid running a missing command.
M.on_cmd = function(name, target)
    local fn = resolve(target)
    vim.api.nvim_create_user_command(name, function(opts)
        vim.api.nvim_del_user_command(name)
        local ok, err = pcall(fn)
        if not ok then
            vim.notify("Config Error: " .. tostring(err), vim.log.levels.WARN)
            return
        end
        vim.cmd(name .. (opts.args ~= '' and ' ' .. opts.args or ''))
    end, { nargs = '*' })
end


return M
