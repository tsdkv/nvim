local load_lib = function()
    package.loaded["core.load"] = nil
    return require("core.load")
end

describe("Configuration Loader Framework", function()
    it("should execute M.now immediately", function()
        local load = load_lib()
        local executed = false

        load.now(function()
            executed = true
        end)

        assert.is_true(executed)
    end)

    it("M.later waits for VimEnter", function()
        local load = load_lib()
        local order = {}

        load.later(function()
            table.insert(order, 1)
        end)
        load.later(function()
            table.insert(order, 2)
        end)

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
        local load = load_lib()

        local order = {}

        local original_v = vim.v
        vim.v = { vim_did_enter = 1 }

        -- Since "vim_did_enter == 1", it should immediately call drain(),
        -- which in turn queues the tasks into the vim.schedule event loop.
        load.later(function()
            table.insert(order, 1)
        end)
        load.later(function()
            table.insert(order, 2)
        end)

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
        local load = load_lib()

        -- Call later() multiple times to simulate a heavy init.lua loading many plugins
        load.later(function() end)
        load.later(function() end)
        load.later(function() end)

        assert(vim.v.vim_did_enter == 0, "check vim_did_enter == 0")

        local autocmds = vim.api.nvim_get_autocmds({
            group = "CoreLoadLaterStart",
            event = "VimEnter",
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
            group = "CoreLoadLaterStart",
            event = "VimEnter",
        })

        assert.is_false(group_exists, "The group was completely deleted, which is a successful cleanup")
    end)

    it("should safeguard M.on_event against duplicate execution", function()
        local load = load_lib()

        local execution_count = 0
        local target_fn = function()
            execution_count = execution_count + 1
        end

        load.on_event("User", target_fn, "TestEvent")

        vim.api.nvim_exec_autocmds("User", { pattern = "TestEvent" })
        vim.api.nvim_exec_autocmds("User", { pattern = "TestEvent" })
        vim.api.nvim_exec_autocmds("User", { pattern = "TestEvent" })

        assert.are.equal(1, execution_count)
    end)
end)

describe("Loader registrations and traces", function()
    local name = "test.core_load_module"
    local load, original_notify, buffers

    before_each(function()
        load = load_lib()
        original_notify = vim.notify
        buffers = {}
    end)

    after_each(function()
        vim.notify = original_notify
        package.preload[name], package.loaded[name] = nil, nil
        for _, buf in ipairs(buffers) do
            if vim.api.nvim_buf_is_valid(buf) then
                vim.api.nvim_buf_delete(buf, { force = true })
            end
        end
    end)

    local function drain_queue()
        local done = false
        load.later(function()
            done = true
        end, "end of test queue")
        vim.api.nvim_exec_autocmds("VimEnter", {})
        assert.is_true(vim.wait(1000, function()
            return done
        end, 1))
    end

    it("runs same-line closures and repeated registrations of one function independently", function()
        local order = {}
        for i = 1, 2 do
            load.later(function()
                table.insert(order, i)
            end)
        end
        local function refresh()
            table.insert(order, "refresh")
        end
        load.later(refresh, "refresh")
        load.later(refresh, "refresh")
        drain_queue()

        assert.are.same({ 1, 2, "refresh", "refresh" }, order)
        local trace = load.get_trace()
        assert.are.equal(5, #trace)
        assert.are.equal(trace[1].target, trace[2].target)
        assert.are.equal(trace[3].target, trace[4].target)
        for _, entry in ipairs(trace) do
            assert.are.equal("loaded", entry.status)
            assert.are.equal("later", entry.trigger)
        end
        assert.is_true(load.loaded(refresh))
    end)

    it("releases a completed callback and its captures while retaining its trace", function()
        local weak = setmetatable({}, { __mode = "v" })
        local function enqueue()
            local payload = {}
            local function job()
                payload.ran = true
            end
            weak[1], weak[2] = job, payload
            load.later(job, "temporary callback")
        end
        enqueue()
        drain_queue()
        collectgarbage("collect")
        assert.is_nil(weak[1])
        assert.is_nil(weak[2])
        assert.are.equal("loaded", load.get_trace()[1].status)
    end)

    it("tracks registration, the winning trigger, and its parent for a named module", function()
        local attempts, during, state = 0
        package.preload[name] = function()
            return {
                setup = function()
                    attempts = attempts + 1
                    during, state = load.loaded(name), load.get_trace()[1].status
                    load.ensure(name) -- re-entering setup must not run it again
                end,
            }
        end
        load.later(name, "queued dependency")
        assert.is_false(load.loaded(name))
        local entry = load.get_trace()[1]
        assert.are.equal("registered", entry.status)
        assert.is_nil(entry.trigger)
        load.now(function()
            load.ensure(name, "different label")
        end, "LSP setup")
        drain_queue()
        load.now(name)

        assert.are.equal(1, attempts)
        assert.is_false(during)
        assert.are.equal("running", state)
        assert.is_true(load.loaded(name))
        assert.are.equal(3, #load.get_trace()) -- module, parent, test queue marker
        assert.are.equal("later", entry.phase)
        assert.are.equal("ensure", entry.trigger)
        assert.are.equal("LSP setup", entry.parent)
        assert.are.equal("now", load.get_trace()[2].reason)
        assert.is_nil(load.get_trace()[3].parent)
    end)

    it("keeps independent one-shot event registrations and records the matching event", function()
        local count = 0
        local function callback()
            count = count + 1
        end
        for _ = 1, 2 do
            load.on_event({ "User", "BufEnter" }, callback, "LoaderSpec", "same label")
        end
        vim.api.nvim_exec_autocmds("User", { pattern = "LoaderSpec" })
        vim.api.nvim_exec_autocmds("BufEnter", { pattern = "LoaderSpec" })
        assert.are.equal(2, count)
        assert.are.equal(2, #load.get_trace())
        for _, entry in ipairs(load.get_trace()) do
            assert.are.equal("event", entry.trigger)
            assert.are.equal("User LoaderSpec", entry.reason)
        end
    end)

    it("treats labels as display text across modules and callbacks", function()
        local calls = {}
        package.preload[name] = function()
            return {
                setup = function()
                    table.insert(calls, "module")
                end,
            }
        end
        load.on_event("User", name, "SharedLabel", "shared")
        load.now(function()
            table.insert(calls, "callback")
        end, "shared")
        vim.api.nvim_exec_autocmds("User", { pattern = "SharedLabel" })
        load.ensure(name)

        assert.are.same({ "callback", "module" }, calls)
        assert.are.equal(2, #load.get_trace())
        assert.is_true(load.loaded(name))
        assert.are.equal("User SharedLabel", load.get_trace()[1].reason)
    end)

    it("distinguishes a matching FileType event from a filetype already open", function()
        local buf = vim.api.nvim_create_buf(false, true)
        table.insert(buffers, buf)
        local count = 0
        local function callback()
            count = count + 1
        end
        for _ = 1, 2 do
            load.on_filetype({ "otherft", "loaderspec" }, callback, "same label")
        end
        vim.bo[buf].filetype = "loaderspec"
        load.on_filetype("loaderspec", callback, "same label")
        vim.api.nvim_exec_autocmds("FileType", { buffer = buf })
        assert.is_true(vim.wait(1000, function()
            return count == 3
        end, 1))
        local trace = load.get_trace()
        assert.are.equal(3, #trace)
        assert.are.equal("FileType loaderspec", trace[1].reason)
        assert.are.equal("FileType loaderspec", trace[2].reason)
        assert.are.equal("existing loaderspec buffer", trace[3].reason)
        assert.are.equal("filetype", trace[3].trigger)
    end)

    it("preserves a failed attempt, continues the queue, and retries only on explicit ensure", function()
        local attempts = 0
        vim.notify = function() end
        package.preload[name] = function()
            return {
                setup = function()
                    attempts = attempts + 1
                    if attempts == 1 then
                        error("setup failed")
                    end
                end,
            }
        end
        load.later(name)
        load.now(name)
        drain_queue()
        local failed = load.get_trace()[1]
        assert.are.equal(1, attempts)
        assert.is_false(load.loaded(name))
        assert.are.equal("failed", failed.status)
        assert.are.equal("now", failed.trigger)
        assert.matches("stack traceback:", failed.err)

        load.ensure(name)
        assert.are.equal(2, attempts)
        assert.is_true(load.loaded(name))
        assert.are.equal("failed", failed.status)
        assert.are.equal("loaded", load.get_trace()[3].status)
        assert.are.equal("ensure", load.get_trace()[3].trigger)
    end)

    it("allows an explicit retry after require itself raises", function()
        vim.notify = function() end
        package.preload[name] = function()
            error("broken module body")
        end
        load.now(name)
        assert.is_false(load.loaded(name))
        package.preload[name] = function()
            return {}
        end
        load.ensure(name)
        assert.is_true(load.loaded(name))
        assert.are.equal(2, #load.get_trace())
    end)

    it("records a callback failure without blocking other queued registrations", function()
        vim.notify = function() end
        local attempts = 0
        local function refresh()
            attempts = attempts + 1
            if attempts == 1 then
                error("first refresh failed")
            end
        end
        local loaded_after_failure
        load.later(refresh)
        load.later(function()
            loaded_after_failure = load.loaded(refresh)
        end)
        load.later(refresh)
        drain_queue()

        assert.is_false(loaded_after_failure)
        assert.is_true(load.loaded(refresh))
        assert.are.equal("failed", load.get_trace()[1].status)
        assert.matches("stack traceback:", load.get_trace()[1].err)
        assert.are.equal("loaded", load.get_trace()[3].status)
    end)
end)
