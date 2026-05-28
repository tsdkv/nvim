local M = {}

function M.setup()
    require("mini.bufremove").setup()
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

    require("mini.comment").setup({
        options = {
            ignore_blank_line = true,
        },
        mappings = {
            comment_line = "<leader>/",
            comment_visual = "<leader>/",
            textobject = "<leader>/",
        },
    })

    -- Close buffers relative to current by buffer number (matches tabline order)
    local function close_bufs(predicate)
        local cur = vim.api.nvim_get_current_buf()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.bo[buf].buflisted and buf ~= cur and predicate(buf, cur) then
                require("mini.bufremove").delete(buf, false)
            end
        end
    end

    require("which-key").add({
        {
            "<leader>uN",
            function()
                MiniNotify.show_history()
            end,
            desc = "Show Notification History",
        },
        {
            "<leader>x",
            function()
                require("mini.bufremove").delete(0, false)
            end,
            desc = "Delete Buffer",
        },
        {
            "<leader>bo",
            function()
                close_bufs(function()
                    return true
                end)
            end,
            desc = "Close Other Buffers",
        },
        {
            "<leader>bl",
            function()
                close_bufs(function(b, cur)
                    return b < cur
                end)
            end,
            desc = "Close Buffers Left",
        },
        {
            "<leader>br",
            function()
                close_bufs(function(b, cur)
                    return b > cur
                end)
            end,
            desc = "Close Buffers Right",
        },
    })
end

return M
