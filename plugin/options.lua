vim.o.termguicolors = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.wrap = true
vim.o.undofile = true

vim.schedule(function()
    vim.o.clipboard = "unnamedplus"
end)
vim.o.list = true
vim.opt.listchars = { tab = "▏ ", trail = "·", nbsp = "␣" }

vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4

vim.o.updatetime = 250
vim.o.cmdheight = 1
vim.o.laststatus = 3
vim.o.cursorline = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = "yes"
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.scrolloff = 4
vim.o.confirm = true
vim.o.inccommand = "split" -- live preview of :s substitutions in a split
vim.o.smoothscroll = true -- smooth Ctrl-D/U scrolling (nvim 0.10+)
vim.o.mouse = "a" -- mouse in all modes

vim.o.foldlevel = 99
vim.o.foldlevelstart = 99

-- Enable and configure experimental ui2 (Neovim 0.12+)
if vim._core and vim._core.ui2 then
    require("vim._core.ui2").enable({
        enable = true,
        msg = {
            targets = {
                default = "cmd",
                progress = "msg",
                info = "msg",
                warning = "msg",
            },
            msg = {
                height = 0.4,
                timeout = 3000,
            },
        },
    })
end
