local M = {}
local H = {}

local function wrap(f, label)
    local ok, err = pcall(f)
    if not ok then
        local msg = label and ("Config Error [%s]: %s"):format(label, tostring(err))
            or ("Config Error: %s"):format(tostring(err))
        vim.notify(msg, vim.log.levels.WARN)
    end
end

H.augroup = function(name)
    return vim.api.nvim_create_augroup(name, { clear = true })
end

H.safe_require = function(name)
    local ok, mod = pcall(require, name)
    if not ok then
        vim.notify("Failed to load: " .. name, vim.log.levels.WARN)
        return nil
    end
    return mod
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

-- Resolves a target (string module name or function) into a callable.
-- String: safe_require the module, then call .setup() if it exists.
--         Wrapped in H.done guard to ensure setup() runs at most once.
-- Function: used as-is.
-- Invalid type: notifies with ERROR and returns a no-op to prevent crashes.
local function resolve(target)
    if type(target) == "function" then
        return target
    end

    if type(target) == "string" then
        return function()
            if H.done[target] then
                return
            end
            H.done[target] = true

            local mod = H.safe_require(target)

            if not mod then
                return
            end

            if type(mod) ~= "table" then
                return
            end

            if type(mod.setup) == "function" then
                mod.setup()
            end
        end
    end

    vim.notify(("lib: invalid target type '%s'"):format(type(target)), vim.log.levels.ERROR)
    return function() end
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
        wrap(item.fn, item.label)
        H.draining = false
        drain()
    end)
end

M.now = function(target)
    wrap(resolve(target), get_target_key(target))
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

M.on_event = function(events, target, pattern)
    local target_key = get_target_key(target)
    local group = H.augroup("CoreLoadLoadOnEvent_" .. target_key)

    vim.api.nvim_create_autocmd(events, {
        once = true,
        group = group,
        pattern = pattern,
        callback = function()
            wrap(resolve(target), target_key)

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
            vim.schedule(function()
                wrap(resolve(target), target_key)
            end)
        end,
    })

    -- Handle buffers already open at registration time: if a matching filetype
    -- is already loaded, skip the autocmd entirely and schedule immediately.
    local fts = type(filetypes) == "table" and filetypes or { filetypes }
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.tbl_contains(fts, vim.bo[buf].filetype) then
            vim.api.nvim_del_augroup_by_id(group)
            vim.schedule(function()
                wrap(resolve(target), target_key)
            end)
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
    local key = get_target_key(target)
    if H.done[key] then
        return
    end
    wrap(resolve(target), key)
end

return M
