local M = {}

function M.setup()
    require("zen-mode").setup({})
    require("which-key").add({
        { "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen mode" },
    })
end

return M
