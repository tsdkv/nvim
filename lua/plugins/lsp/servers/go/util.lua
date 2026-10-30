local M = {}

-- Read the module path from the nearest go.mod so gopls can group this
-- module's imports separately from third-party ones ("local" setting).
function M.module_path()
    local gomod = vim.fs.find("go.mod", { upward = true, path = vim.fn.expand("%:p:h") })[1]
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
