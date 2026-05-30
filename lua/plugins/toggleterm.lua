local M = {}

M.keymap = {
    { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Toggle Horizontal Terminal" },
    { "<leader>to", "<cmd>ToggleTerm direction=float<cr>", desc = "Toggle Floating Terminal" },
    { "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", desc = "Toggle Vertical Terminal" },
    { "<Esc><Esc>", "<C-\\><C-n>", desc = "Exit terminal mode", mode = "t" },
    { "<C-h>", "<Cmd>wincmd h<CR>", desc = "Move focus left", mode = "t" },
    { "<C-j>", "<Cmd>wincmd j<CR>", desc = "Move focus down", mode = "t" },
    { "<C-k>", "<Cmd>wincmd k<CR>", desc = "Move focus up", mode = "t" },
    { "<C-l>", "<Cmd>wincmd l<CR>", desc = "Move focus right", mode = "t" },
}

M.setup = function()
    require("toggleterm").setup({
        size = function(term)
            if term.direction == "horizontal" then
                return 15
            elseif term.direction == "vertical" then
                return vim.o.columns * 0.4
            end
        end,
        open_mapping = [[<c-\>]],
        hide_numbers = true,
        shade_filetypes = {},
        shade_terminals = true,
        shading_factor = 2,
        start_in_insert = true,
        insert_mappings = true,
        terminal_mappings = true,
        persist_size = true,
        direction = "horizontal",
        close_on_exit = true,
        shell = vim.o.shell,
        float_opts = {
            border = "rounded",
            winblend = 10,
        },
    })
end

return M
