local tools = require("lang.go.tools")
local api = vim.api

describe("Go tool mappings", function()
    local source, other, original_input, original_system, original_systemlist

    before_each(function()
        original_input, original_system, original_systemlist = vim.ui.input, vim.system, vim.fn.systemlist
        source = api.nvim_create_buf(true, false)
        other = api.nvim_create_buf(true, false)
        api.nvim_set_current_buf(source)
    end)

    after_each(function()
        vim.ui.input, vim.system, vim.fn.systemlist = original_input, original_system, original_systemlist
        for _, buf in ipairs({ source, other }) do
            if api.nvim_buf_is_valid(buf) then
                api.nvim_buf_delete(buf, { force = true })
            end
        end
    end)

    it("passes the unsaved buffer and its one-based byte position to iferr", function()
        local lines = { "package café", "func f() error {", "}" }
        api.nvim_buf_set_lines(source, 0, -1, false, lines)
        vim.bo[source].fileformat = "dos"
        api.nvim_win_set_cursor(0, { 2, 5 })
        vim.fn.systemlist = function(cmd, stdin)
            assert.are.same({ "iferr", "-pos", tostring(#lines[1] + 1 + 5 + 1) }, cmd)
            assert.are.equal(source, stdin)
            assert.are.same(lines, api.nvim_buf_get_lines(stdin, 0, -1, false))
            return { "if err != nil {", "\treturn err", "}" }
        end

        tools.iferr()
        assert.are.same(
            { lines[1], lines[2], "if err != nil {", "\treturn err", "}", lines[3] },
            api.nvim_buf_get_lines(source, 0, -1, false)
        )
    end)
end)
