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

    vim.ui.select({ "Yes", "No" }, {
        prompt = "Remove unused plugins?",
    }, function(choice)
        if choice == "Yes" then
            vim.pack.del(unused)
            print("Unused plugins removed.")
        end
    end)
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
    local lines = {}
    for _, entry in ipairs(trace) do
        local status_str = entry.status == "success" and "✓"
            or entry.status == "failed" and "✗"
            or "○"
        local duration = entry.duration_ms and string.format(" (%.2fms)", entry.duration_ms) or ""
        table.insert(lines, string.format("[%s] %-8s | %s%s", status_str, entry.phase, entry.target, duration))
        if entry.err then
            table.insert(lines, "  └─ Error: " .. entry.err)
        end
    end
    vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "Loader Trace" })
end

vim.api.nvim_create_user_command("LoadTrace", show_loader_trace, { desc = "Show configuration loader trace log" })

