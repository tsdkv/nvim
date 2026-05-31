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

    require("mini.notify").setup({
        window = {
            config = { border = "rounded" },
        },
        lsp_progress = {
            enable = true,
            level = "INFO",
            duration_last = 1000,
        },
    })
    vim.notify = require("mini.notify").make_notify()
end

return M
