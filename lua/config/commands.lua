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

    local choice = vim.fn.confirm("Remove unused plugins?", "&Yes\n&No", 2)
    if choice == 1 then
        vim.pack.del(unused)
        print("Unused plugins removed.")
    end
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
