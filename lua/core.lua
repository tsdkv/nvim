local M = {}

-- Safely execute a function and catch errors
local function wrap(f)
    local ok, err = pcall(f)
    if not ok then
        vim.notify("Config Error: " .. tostring(err), vim.log.levels.WARN)
    end
end

-- Execute immediately (best for UI, colors, and core settings)
M.now = function(f)
    wrap(f)
end

-- Execute after a delay so it doesn't block Neovim startup
M.later = function(f, ms)
    vim.defer_fn(function() wrap(f) end, ms or 10)
end

-- Execute immediately if a file is opened via CLI (e.g., `nvim file.lua`), otherwise delay
M.now_if_args = function(f)
    if vim.fn.argc(-1) > 0 then M.now(f) else M.later(f) end
end

-- Execute exactly once when the specified Neovim event occurs
M.on_event = function(events, f)
    vim.api.nvim_create_autocmd(events, {
        once = true,
        callback = function() wrap(f) end,
    })
end

-- Execute exactly once when the specified filetype is opened
-- Example: core.on_filetype({ "rust", "go" }, function() print("Backend file opened") end)
M.on_filetype = function(filetypes, f)
    vim.api.nvim_create_autocmd("FileType", {
        pattern = filetypes,
        once = true,
        callback = function() wrap(f) end,
    })
end

return M
