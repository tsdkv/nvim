local M = {}

M.keymap = {
    { "<Tab>", "<cmd>QuickBuf<CR>", desc = "QuickBuf" },
    { "<leader>qt", "<cmd>QuickBufPinToggle<CR>", desc = "Pin toggle" },
    { "<S-h>", "<cmd>QuickBufPrevPinned<CR>", desc = "Prev pinned buffer" },
    { "<S-l>", "<cmd>QuickBufNextPinned<CR>", desc = "Next pinned buffer" },
}

M.setup = function()
    require("quickbuf").setup({
        fuzzy_backend = "telescope",
        window = {
            border = "rounded",
        },
        pin_display = "",
        highlights = {
            -- Nord orange: #d08770, Nord yellow: #ebcb8b, Nord blue: #88c0d0
            label = { fg = "#ebcb8b", bold = true, default = false },
            alternate = { fg = "#88c0d0", bold = true, default = false },
            pinned = { fg = "#a3be8c", bold = true, default = false },
            flags = { fg = "#4c566a", default = false },
        },
    })
end

return M
