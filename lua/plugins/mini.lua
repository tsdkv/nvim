local M = {}

M.keymap = {
    {
        "<leader>uN",
        function()
            require("mini.notify").show_history()
        end,
        desc = "Show Notification History",
    },
}

function M.setup()
    require("mini.pairs").setup()

    require("mini.surround").setup({
        mappings = {
            add = "gza", -- Add surrounding in Normal and Visual modes
            delete = "gzd", -- Delete surrounding
            find = "gzf", -- Find surrounding (to the right)
            find_left = "gzF", -- Find surrounding (to the left)
            highlight = "gzh", -- Highlight surrounding
            replace = "gzr", -- Replace surrounding
            update_n_lines = "gzn", -- Update `n_lines`
        },
    })

    require("mini.notify").setup({
        window = {
            config = { border = "rounded" },
        },
        lsp_progress = {
            enable = false,
            level = "INFO",
            duration_last = 1000,
        },
    })
    vim.notify = require("mini.notify").make_notify()
end

return M
