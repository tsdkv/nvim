vim.bo.tabstop = 2
vim.bo.shiftwidth = 2
vim.b.undo_ftplugin = "setlocal tabstop< shiftwidth< | " .. (vim.b.undo_ftplugin or "")
