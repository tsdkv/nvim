vim.opt.termguicolors  = true          -- Enable 24-bit RGB colors
vim.opt.number         = true          -- Show absolute line numbers
vim.opt.relativenumber = true          -- Show relative line numbers
vim.opt.wrap           = true          -- Wrap long lines
vim.o.undofile         = true          -- Enable persistent undo
vim.opt.clipboard      = "unnamedplus" -- Use system clipboard

vim.g.mapleader        = " "           -- Space as leader key
vim.g.maplocalleader   = " "           -- Space as local leader key

vim.o.expandtab        = true          -- Convert tabs to spaces
vim.opt.tabstop        = 4             -- Number of spaces for a tab
vim.opt.shiftwidth     = 4             -- Indent size for auto-formatting

vim.opt.updatetime     = 250           -- Faster completion and CursorHold events
vim.opt.cmdheight      = 0             -- Hide command line when not in use
vim.opt.laststatus     = 3             -- Use a single global statusline
vim.opt.cursorline     = true          -- Highlight the current line
