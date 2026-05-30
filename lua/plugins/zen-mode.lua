local M = {}

M.keymap = {
    { "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen mode" },
}

function M.setup()
    require("zen-mode").setup({})
end

return M
