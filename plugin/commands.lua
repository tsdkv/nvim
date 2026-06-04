vim.api.nvim_create_user_command("PackClean", function()
    local unused = {}

    for _, plugin in ipairs(vim.pack.get()) do
        if not plugin.active then
            table.insert(unused, plugin.spec.name)
        end
    end

    if #unused == 0 then
        print("No unused plugins.")
        return
    end

    vim.pack.del(unused)
    print("Removed " .. #unused .. " unused plugin(s).")
end, { desc = "Find and remove unused plugins" })

vim.api.nvim_create_user_command("PackUpdate", function(opts)
    local names = #opts.fargs > 0 and opts.fargs or nil
    local update_opts = {}
    if opts.bang then
        update_opts.force = true
    end
    vim.pack.update(names, update_opts)
end, {
    nargs = "*",
    bang = true,
    desc = "Update all or specific plugins (use ! to auto-apply without preview)",
    complete = function()
        local targets = {}
        for _, p in ipairs(vim.pack.get()) do
            table.insert(targets, p.spec.name)
        end
        return targets
    end,
})

local function show_loader_trace()
    local trace = require("core.load").get_trace()
    local lines = { "Configuration Loader Trace", string.rep("=", 60), "" }

    local totals = { now = 0, later = 0, event = 0, filetype = 0, ensure = 0 }
    local total_ms = 0

    for _, entry in ipairs(trace) do
        local status_str = entry.status == "success" and "✓" or entry.status == "failed" and "✗" or "○"
        local duration = entry.duration_ms or 0
        total_ms = total_ms + duration

        if totals[entry.phase] then
            totals[entry.phase] = totals[entry.phase] + duration
        end

        local dur_str = entry.duration_ms and string.format("(%.2fms)", duration) or ""
        table.insert(lines, string.format("[%s] %-8s | %-30s %10s", status_str, entry.phase, entry.target, dur_str))
        if entry.err then
            table.insert(lines, "  └─ Error: " .. entry.err)
        end
    end

    table.insert(lines, "")
    table.insert(lines, string.rep("-", 60))
    table.insert(lines, string.format("Total Load Time: %.2fms", total_ms))
    table.insert(lines, string.format("  Eager (now):   %.2fms", totals.now))
    table.insert(lines, string.format("  Deferred:      %.2fms", totals.later))
    table.insert(lines, string.format("  Event/FT:      %.2fms", totals.event + totals.filetype))

    -- Create a scratch buffer
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    -- Set buffer options
    vim.bo[buf].modifiable = false
    vim.bo[buf].filetype = "loadtrace"
    vim.bo[buf].bufhidden = "wipe"

    -- Open in a vertical split
    vim.cmd("vsplit")
    vim.api.nvim_win_set_buf(0, buf)
end

vim.api.nvim_create_user_command("LoadTrace", show_loader_trace, { desc = "Show configuration loader trace log" })
