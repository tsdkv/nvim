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

    for _, client in ipairs(clients) do
        client:stop()
    end

    vim.defer_fn(function()
        if opts.on_restart then
            opts.on_restart()
            return
        end

        for _, client in ipairs(clients) do
            vim.lsp.start(client.config, {
                reuse_client = function()
                    return false
                end,
            })
        end
    end, 200)

    vim.notify(opts.message or "LSP restarting...", vim.log.levels.INFO)
end

return M
