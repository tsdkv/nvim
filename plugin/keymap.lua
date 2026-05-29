-- Plugin-free keymaps only. Plugin-specific maps live next to their plugin file.
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Save File" })
vim.keymap.set("n", "<leader>W", "<cmd>noautocmd w<cr>", { desc = "Save without format" })
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit Neovim" })
vim.keymap.set("v", "<", "<gv", { desc = "Indent Left (Keep Selection)" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent Right (Keep Selection)" })

vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Buffer navigation (bracket motions — no plugin needed)
vim.keymap.set("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })
vim.keymap.set("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })

-- UI toggles (<leader>u — group label in plugins/which-key.lua)
vim.keymap.set("n", "<leader>un", function()
    vim.opt.relativenumber = not vim.opt.relativenumber:get()
end, { desc = "Toggle Relative Numbers" })

vim.keymap.set("n", "<leader>uw", function()
    vim.opt.wrap = not vim.opt.wrap:get()
end, { desc = "Toggle Wrap" })

vim.keymap.set("n", "<leader>us", function()
    vim.opt.spell = not vim.opt.spell:get()
end, { desc = "Toggle Spell Check" })


-- UI2: view collapsed message logs
vim.keymap.set("n", "<leader>um", "g<", { desc = "View Collapsed Messages" })
