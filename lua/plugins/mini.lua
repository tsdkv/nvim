local M = {}

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

    require("which-key").add({
        {
            "<leader>uN",
            function()
                MiniNotify.show_history()
            end,
            desc = "Show Notification History",
        },
    })
end

return M
