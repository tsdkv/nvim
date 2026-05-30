local M = {}

M.keymap = {
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
}

M.setup = function()
    require("persistence").setup({
        -- use git branch to save session
        branch = true,
    })

    -- Fix for missing Treesitter syntax highlight and LSP attach after session load
    vim.api.nvim_create_autocmd("SessionLoadPost", {
        group = vim.api.nvim_create_augroup("PersistenceLoadPost", { clear = true }),
        callback = function()
            vim.schedule(function()
                vim.cmd("silent! doautoall BufReadPost")
                vim.cmd("silent! doautoall FileType")
            end)
        end,
    })
end

return M
