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

    -- When <leader>qs fires before deferred plugins finish loading,
    -- restored buffers miss their FileType event. Re-trigger it manually.
    -- Only FileType is needed — BufReadPost would re-run cursor restore, checktime, etc.
    vim.api.nvim_create_autocmd("SessionLoadPost", {
        group = vim.api.nvim_create_augroup("PersistenceLoadPost", { clear = true }),
        callback = function()
            vim.schedule(function()
                for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype ~= "" then
                        vim.api.nvim_exec_autocmds("FileType", {
                            buffer = buf,
                            data = { filetype = vim.bo[buf].filetype },
                        })
                    end
                end
            end)
        end,
    })
end

return M
