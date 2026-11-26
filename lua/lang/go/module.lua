local M = {}

-- Read the module path from the nearest go.mod so gopls and goimports can
-- group this module's imports separately from third-party ones.
-- start: directory to search upward from (defaults to the current buffer's).
function M.module_path(start)
    local gomod = vim.fs.find("go.mod", { upward = true, path = start or vim.fn.expand("%:p:h") })[1]
    if not gomod then
        return nil
    end
    for _, line in ipairs(vim.fn.readfile(gomod, "", 5)) do
        local mod = line:match("^module%s+(%S+)")
        if mod then
            return mod
        end
    end
    return nil
end

return M
