local M = {}

local lazygit = nil
local function toggle_lazygit()
    if not lazygit then
        lazygit = require("toggleterm.terminal").Terminal:new({
            cmd = "lazygit",
            direction = "float",
            float_opts = { border = "rounded" },
        })
    end
    lazygit:toggle()
end

M.keymap = {
    { "<leader>gg", toggle_lazygit, desc = "LazyGit" },
    {
        "<leader>gb",
        function()
            require("gitsigns").toggle_current_line_blame()
        end,
        desc = "Toggle current line blame",
    },
    {
        "<leader>]h",
        function()
            require("gitsigns").nav_hunk("next")
        end,
        desc = "Next hunk",
    },
    {
        "<leader>[h",
        function()
            require("gitsigns").nav_hunk("prev")
        end,
        desc = "Prev hunk",
    },
}

M.setup = function()

    local gitsigns = require("gitsigns")
    gitsigns.setup({
        signs = {
            add = { text = "┃" },
            change = { text = "┃" },
            delete = { text = "_" },
            topdelete = { text = "‾" },
            changedelete = { text = "~" },
            untracked = { text = "┆" },
        },
        signs_staged = {
            add = { text = "┃" },
            change = { text = "┃" },
            delete = { text = "_" },
            topdelete = { text = "‾" },
            changedelete = { text = "~" },
            untracked = { text = "┆" },
        },
        signs_staged_enable = true,
        signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
        numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
        linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
        word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
        watch_gitdir = {
            follow_files = true,
        },
        auto_attach = true,
        attach_to_untracked = false,
        current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
        current_line_blame_opts = {
            virt_text = true,
            virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
            delay = 1000,
            ignore_whitespace = false,
            virt_text_priority = 100,
            use_focus = true,
        },
        current_line_blame_formatter = "<author>, <author_time:%R> - <summary>",
        blame_formatter = nil, -- Use default
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil, -- Use default
        max_file_length = 40000, -- Disable if file is longer than this (in lines)
        preview_config = {
            -- Options passed to nvim_open_win
            style = "minimal",
            relative = "cursor",
            row = 0,
            col = 1,
        },
    })
end

return M
