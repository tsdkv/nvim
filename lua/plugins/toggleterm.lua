local M = {}

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

    -- Map shortcuts in normal mode only, preventing the lazygit typing issue
    require("which-key").add({
        { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Toggle Horizontal Terminal" },
        { "<leader>to", "<cmd>ToggleTerm direction=float<cr>", desc = "Toggle Floating Terminal" },
        { "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", desc = "Toggle Vertical Terminal" },
    })

    -- Exit terminal mode to normal mode to allow scrollback/motions
    vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

    -- Direct window focus switching from terminal mode
    vim.keymap.set("t", "<C-h>", "<Cmd>wincmd h<CR>", { desc = "Move focus left" })
    vim.keymap.set("t", "<C-j>", "<Cmd>wincmd j<CR>", { desc = "Move focus down" })
    vim.keymap.set("t", "<C-k>", "<Cmd>wincmd k<CR>", { desc = "Move focus up" })
    vim.keymap.set("t", "<C-l>", "<Cmd>wincmd l<CR>", { desc = "Move focus right" })
end

return M
