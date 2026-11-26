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

    it("inserts impl output in the original package and tracks edits during prompts and execution", function()
        local dir = vim.fn.tempname()
        api.nvim_buf_set_name(source, dir .. "/file.go")
        api.nvim_buf_set_lines(source, 0, -1, false, { "package p", "type R struct{}", "// tail" })
        api.nvim_win_set_cursor(0, { 2, 0 })
        local answer, finish
        vim.ui.input = function(_, callback)
            answer = callback
        end
        vim.system = function(cmd, opts, callback)
            assert.are.same({ "impl", "r R", "io.Reader" }, cmd)
            assert.are.equal(dir, opts.cwd)
            finish = callback
        end

        tools.impl()
        api.nvim_set_current_buf(other)
        answer("r R")
        answer("io.Reader")
        api.nvim_buf_set_lines(source, 0, 0, false, { "// header" })
        finish({ code = 0, stdout = "func (r R) Read() {}\n" })
        assert.is_true(vim.wait(500, function()
            return api.nvim_buf_line_count(source) == 5
        end))
        assert.are.same(
            { "// header", "package p", "type R struct{}", "func (r R) Read() {}", "// tail" },
            api.nvim_buf_get_lines(source, 0, -1, false)
        )
        assert.are.equal(other, api.nvim_get_current_buf())
        assert.are.same({ "" }, api.nvim_buf_get_lines(other, 0, -1, false))
    end)

    it("releases the insertion mark when the interface prompt is cancelled", function()
        local ns = api.nvim_get_namespaces()["go.impl"]
        local answer
        vim.ui.input = function(_, callback)
            answer = callback
        end
        vim.system = function()
            error("unexpected invocation of impl")
        end
        tools.impl()
        answer("r R")
        assert.are.equal(1, #api.nvim_buf_get_extmarks(source, ns, 0, -1, {}))
        answer(nil)
        assert.are.same({}, api.nvim_buf_get_extmarks(source, ns, 0, -1, {}))
    end)
end)
