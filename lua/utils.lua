local M = {}

M.github = function(x) return 'https://github.com/' .. x end

M.check_type = function(name, val, ref, allow_nil)
    if type(val) == ref or (ref == 'callable' and vim.is_callable(val)) or (allow_nil and val == nil) then return end

    error(string.format('`%s` should be %s, not %s', name, ref, type(val)))
end

return M
