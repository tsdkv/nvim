local M = {}

M.setup = function()
    local ls = require("luasnip")
    local f = ls.function_node

    ls.add_snippets("go", {
        ls.snippet("here", {
            f(function(_, snip)
                return {
                    string.format('fmt.Println("HERE -> %s:%s")', snip.env.TM_FILENAME, snip.env.TM_LINE_NUMBER),
                }
            end, {}),
        }),
    })
end

return M
