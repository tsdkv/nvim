-- Plugin-free keymaps only. Plugin-specific maps live next to their plugin file.
vim.keymap.set('n', '<leader>w', '<cmd>w<cr>',            { desc = 'Save File' })
vim.keymap.set('n', '<leader>W', '<cmd>noautocmd w<cr>',  { desc = 'Save without format' })
vim.keymap.set('n', '<leader>q', '<cmd>q<cr>',            { desc = 'Quit Neovim' })
vim.keymap.set('v', '<',         '<gv',                   { desc = 'Indent Left (Keep Selection)' })
vim.keymap.set('v', '>',         '>gv',                   { desc = 'Indent Right (Keep Selection)' })

-- Buffer navigation (bracket motions — no plugin needed)
vim.keymap.set('n', ']b', '<cmd>bnext<cr>',     { desc = 'Next Buffer' })
vim.keymap.set('n', '[b', '<cmd>bprevious<cr>', { desc = 'Prev Buffer' })

-- UI toggles (<leader>u — group label in plugins/which-key.lua)
vim.keymap.set('n', '<leader>ui', function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = 'Toggle Inlay Hints' })

vim.keymap.set('n', '<leader>un', function()
    vim.opt.relativenumber = not vim.opt.relativenumber:get()
end, { desc = 'Toggle Relative Numbers' })

vim.keymap.set('n', '<leader>uw', function()
    vim.opt.wrap = not vim.opt.wrap:get()
end, { desc = 'Toggle Wrap' })

vim.keymap.set('n', '<leader>us', function()
    vim.opt.spell = not vim.opt.spell:get()
end, { desc = 'Toggle Spell Check' })

vim.keymap.set('n', '<leader>ud', function()
    local enabled = vim.diagnostic.is_enabled({ bufnr = 0 })
    vim.diagnostic.enable(not enabled, { bufnr = 0 })
end, { desc = 'Toggle Diagnostics' })
