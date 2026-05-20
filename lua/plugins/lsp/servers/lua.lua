return {
    name      = 'lua_ls',
    filetypes = { 'lua' },
    tools     = { 'lua-language-server' },
    setup = function()
        vim.lsp.config('lua_ls', {
            cmd          = { 'lua-language-server' },
            filetypes    = { 'lua' },
            root_markers = { '.luarc.json', '.luarc.jsonc', '.git' },
            settings = {
                Lua = {
                    -- lazydev.nvim handles workspace library (Neovim API stubs)
                    completion = { callSnippet = 'Replace' },
                },
            },
        })
        vim.lsp.enable('lua_ls')
    end,
}
