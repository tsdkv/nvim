vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = true
vim.opt.undofile = true

vim.schedule(function()
    vim.o.clipboard = "unnamedplus"
end)
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

vim.opt.updatetime = 250
vim.opt.cmdheight = 1
vim.opt.laststatus = 3
vim.opt.cursorline = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.scrolloff = 4
vim.opt.confirm = true
vim.opt.inccommand = "split" -- live preview of :s substitutions in a split
vim.opt.smoothscroll = true -- smooth Ctrl-D/U scrolling (nvim 0.10+)
vim.opt.mouse = "a" -- mouse in all modes

vim.o.foldlevel = 99
vim.o.foldlevelstart = 99

-- Enable and configure experimental ui2 (Neovim 0.12+)
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
