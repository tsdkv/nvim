local load_lib = function()
    package.loaded['lib'] = nil
    return require('lib')
end

describe("Configuration Loader Framework", function()
    it('safe_require', function()
        local lib = load_lib()
        local result = lib.safe_require("plugin_that_does_not_exist_123")

        assert.is_nil(result)
    end)

    it("should execute M.now immediately", function()
        local lib = load_lib()
        local executed = false

        lib.now(function()
            executed = true
        end)

        assert.is_true(executed)
    end)

    it("M.later waits for VimEnter", function()
        local lib = load_lib()
        local order = {}

        lib.later(function() table.insert(order, 1) end)
        lib.later(function() table.insert(order, 2) end)

        assert.are.same({}, order, "The queue should not execute before VimEnter")

        vim.api.nvim_exec_autocmds("VimEnter", {})

        assert(vim.v.vim_did_enter == 0, "check vim_did_enter == 0")

        -- Convert the human-readable "<Ignore>" string into Neovim's internal byte code.
        -- We send this "invisible" keypress to safely force the Event Loop to process
        -- pending vim.schedule() tasks without typing actual characters into a buffer.
        local ignore_key = vim.api.nvim_replace_termcodes("<Ignore>", true, false, true)
        vim.wait(100, function()
            vim.api.nvim_feedkeys(ignore_key, "x", false)
            return #order == 2
        end, 1)

        assert.are.same({ 1, 2 }, order, "The queue should execute strictly in order")
    end)

    it("M.later should immediately schedule tasks if the editor has already entered", function()
        local lib = load_lib()

        local order = {}

        local original_v = vim.v
        vim.v = { vim_did_enter = 1 }

        -- Since "vim_did_enter == 1", it should immediately call drain(),
        -- which in turn queues the tasks into the vim.schedule event loop.
        lib.later(function() table.insert(order, 1) end)
        lib.later(function() table.insert(order, 2) end)

        assert.are.same({}, order, "Tasks should be deferred via vim.schedule, not executed synchronously")

        -- Push the Event Loop forward so the scheduled tasks can run.
        local ignore_key = vim.api.nvim_replace_termcodes("<Ignore>", true, false, true)
        vim.wait(100, function()
            vim.api.nvim_feedkeys(ignore_key, "x", false)
            return #order == 2
        end, 1)

        assert.are.same({ 1, 2 }, order, "The queue should execute correctly in order")

        -- cleanup
        vim.v = original_v
    end)

    it("M.later should register exactly one VimEnter autocmd regardless of multiple calls", function()
        local lib = load_lib()

        -- Call later() multiple times to simulate a heavy init.lua loading many plugins
        lib.later(function() end)
        lib.later(function() end)
        lib.later(function() end)

        assert(vim.v.vim_did_enter == 0, "check vim_did_enter == 0")

        local autocmds = vim.api.nvim_get_autocmds({
            group = "LibLaterStart",
            event = "VimEnter"
        })

        assert.are.equal(1, #autocmds, "There should be exactly one VimEnter autocmd registered")
        assert.is_true(autocmds[1].once, "The autocmd must be registered with 'once = true'")

        vim.api.nvim_exec_autocmds("VimEnter", {})

        -- Flush the Event Loop to clear the schedule
        local ignore_key = vim.api.nvim_replace_termcodes("<Ignore>", true, false, true)
        vim.wait(100, function()
            vim.api.nvim_feedkeys(ignore_key, "x", false)
            -- We don't have an order array to check here, so we just return true immediately
            -- after pushing the key, to avoid waiting the full 100ms.
            return true
        end, 1)

        -- Since the group might be completely deleted from Neovim's memory (which is great!),
        -- nvim_get_autocmds will throw an error if called directly. We use pcall to catch it.
        local group_exists = pcall(vim.api.nvim_get_autocmds, {
            group = "LibLaterStart",
            event = "VimEnter"
        })

        assert.is_false(group_exists, "The group was completely deleted, which is a successful cleanup")
    end)

    it("should safeguard M.on_event against duplicate execution", function()
        local lib = load_lib()

        local execution_count = 0
        local target_fn = function()
            execution_count = execution_count + 1
        end

        lib.on_event("User", target_fn, "TestEvent")

        vim.api.nvim_exec_autocmds("User", { pattern = "TestEvent" })
        vim.api.nvim_exec_autocmds("User", { pattern = "TestEvent" })
        vim.api.nvim_exec_autocmds("User", { pattern = "TestEvent" })

        assert.are.equal(1, execution_count)
    end)
end
)
