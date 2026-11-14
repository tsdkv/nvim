local M = {}

M.keymap = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Open diff view" },
    { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Close diff view" },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Current file history" },
}

M.setup = function()
    require("diffview").setup({
        enhanced_diff_hl = true,
    })
end

return M
