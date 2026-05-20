local M = {}

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
            if type(mod.setup) ~= 'function' then
                vim.notify(
                    ("lib: '%s' loaded but has no setup()"):format(target),
                    vim.log.levels.WARN
                )
                return
            end
            mod.setup()
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
local queue, draining = {}, false
local function drain()
    if draining or #queue == 0 then return end
    draining = true

    vim.schedule(function()
        local f = table.remove(queue, 1)
        wrap(f)
        draining = false
        drain()
    end)
end

M.now = function(target)
    wrap(resolve(target))
end

local later_group = M.augroup("LibLaterStart")
local has_autocmd = false

M.later = function(target)
    table.insert(queue, resolve(target))
    if vim.v.vim_did_enter == 1 then
        drain()
    else
        if not has_autocmd then
            has_autocmd = true
            vim.api.nvim_create_autocmd("VimEnter", {
                group = later_group,
                once = true,
                callback = function()
                    drain()

                    vim.api.nvim_del_augroup_by_id(later_group)
                end
            })
        end
    end
end

M.now_if_args = function(f)
    if vim.fn.argc(-1) > 0 then M.now(f) else M.later(f) end
end

M.on_event = function(events, target, pattern)
    local target_key = get_target_key(target)
    local group = M.augroup('LibLazyLoadOnEvent_' .. target_key)

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

M.on_filetype = function(filetypes, target)
    local target_key = get_target_key(target)
    local group = M.augroup('LibLazyFiletype_' .. target_key)

    vim.api.nvim_create_autocmd("FileType", {
        group    = group,
        pattern  = filetypes,
        once     = true,
        callback = function()
            wrap(resolve(target))

            vim.api.nvim_del_augroup_by_id(group)
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
