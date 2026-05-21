M = {}

M.setup = function()
    require('core.load').later(function()
        require('nvim-treesitter').install({
            'c', 'cpp', 'go', 'rust', 'lua',
            'yaml', 'json',
            'markdown', 'markdown_inline',
        })
    end)

    vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('CoreTreesitter', { clear = true }),
        pattern = '*',
        callback = function(args)
            -- Start syntax highlighting safely (ignores files without parsers)
            pcall(vim.treesitter.start, args.buf)

            -- Enable AST-based folding for the current window
            vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
            vim.wo[0][0].foldmethod = 'expr'
            vim.wo[0][0].foldtext = ''

            -- Enable AST-based indentation for the current buffer
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
    })
end

return M
