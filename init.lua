if vim.fn.has("nvim-0.12") == 0 then
    vim.notify("Error: Neovim >= 0.12 is required", vim.log.levels.ERROR)
    return
end

vim.g.mapleader = " "
vim.g.maplocalleader = " "
require("plugins")
