local M = {}

M.setup = function()
    local ls = require("luasnip")
    local treesitter_postfix = require("luasnip.extras.treesitter_postfix").treesitter_postfix
    local sn = ls.snippet_node
    local t = ls.text_node
    local f = ls.function_node

    ls.add_snippets("go", {
        treesitter_postfix({
            trig = ".dbg",
            -- "live" removes the trigger from the buffer before tree-sitter parses it,
            -- so `.dbg` doesn't mess up the syntax tree of the expression before it.
            reparseBuffer = "live",
            matchTSNode = {
                query = [[
                    [
                      (identifier)
                      (call_expression)
                      (selector_expression)
                      (slice_expression)
                      (index_expression)
                      (parenthesized_expression)
                      (type_conversion_expression)
                      (composite_literal)
                      (binary_expression)
                      (unary_expression)
                      (type_assertion_expression)
                      (interpreted_string_literal)
                      (raw_string_literal)
                      (int_literal)
                      (float_literal)
                      (rune_literal)
                      (func_literal)
                    ] @prefix
                ]],
                query_lang = "go",
                select = "longest",
            },
        }, {
            ls.dynamic_node(1, function(_, parent)
                local node_content = table.concat(parent.snippet.env.LS_TSMATCH, "\n")
                local trimmed = vim.trim(node_content)

                local escaped_match = string.gsub(trimmed, '"', '\\"')
                local format_str = escaped_match .. " = %+v\\n"
                local result = string.format('fmt.Printf("%s", %s)', format_str, trimmed)

                return sn(nil, { t(vim.split(result, "\n")) })
            end),
        }),

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
