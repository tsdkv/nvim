local M = {}

M.keymap = {
    { "<leader>dt", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Document Diagnostics (Trouble)" },
    { "<leader>dT", "<cmd>Trouble diagnostics toggle<cr>", desc = "Workspace Diagnostics (Trouble)" },
    { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Trouble)" },
    {
        "<leader>cl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions/References (Trouble)",
    },
    { "<leader>cL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
    { "<leader>cq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
}

function M.setup()
    require("trouble").setup({})
end

return M
