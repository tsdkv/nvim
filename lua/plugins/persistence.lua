local M = {}

M.setup = function()
    require("persistence").setup({
        -- use git branch to save session
        branch = true,
    })

    require("which-key").add({
        {
            "<leader>qs",
            function()
                require("persistence").load()
            end,
            desc = "Restore Session",
        },
        {
            "<leader>qS",
            function()
                require("persistence").select()
            end,
            desc = "Select Session",
        },
        {
            "<leader>qd",
            function()
                require("persistence").stop()
            end,
            desc = "Don't Save Current Session",
        },
        {
            "<leader>ql",
            function()
                require("persistence").load({ last = true })
            end,
            desc = "Restore Last Session",
        },
    })
end

return M
