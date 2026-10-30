local M = {}

M.github = function(x)
    return "https://github.com/" .. x
end

M.check_type = function(name, val, ref, allow_nil)
    if type(val) == ref or (ref == "callable" and vim.is_callable(val)) or (allow_nil and val == nil) then
        return
    end

    error(string.format("`%s` should be %s, not %s", name, ref, type(val)))
end

M.restart_lsp = function(clients, opts)
    opts = opts or {}
    if #clients == 0 then
        vim.notify("No LSP clients to restart", vim.log.levels.WARN)
        return
    end

    -- Toggle via vim.lsp.enable so servers come back up with the current
    -- vim.lsp.config registry instead of a client.config captured at attach
    -- time. Re-enabling also re-attaches all open matching buffers, which a
    -- manual vim.lsp.start() does not.
    local names = {}
    for _, client in ipairs(clients) do
        if not vim.tbl_contains(names, client.name) then
            table.insert(names, client.name)
        end
    end

    for _, name in ipairs(names) do
        vim.lsp.enable(name, false)
    end

    vim.defer_fn(function()
        for _, name in ipairs(names) do
            vim.lsp.enable(name, true)
        end
        if opts.on_restart then
            opts.on_restart()
        end
    end, 200)

    vim.notify(opts.message or "LSP restarting...", vim.log.levels.INFO)
end

return M
