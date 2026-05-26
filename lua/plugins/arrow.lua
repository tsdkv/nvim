local M = {}

M.setup = function()
    local arrow = require("arrow")

    arrow.setup({
        show_icons = true,
        leader_key = ";",
        buffer_leader_key = false,

        window = {
            width = "auto",
            height = "auto",
            row = "auto",
            col = "auto",
            border = "rounded",
        },
    })

    -- Force the Arrow floating window background to match the main editor background
    vim.api.nvim_create_autocmd("BufWinEnter", {
        group = vim.api.nvim_create_augroup("ArrowWindowStyle", { clear = true }),
        callback = function(ev)
            if vim.b[ev.buf].filename and vim.b[ev.buf].arrow_current_mode then
                vim.wo.winhighlight = "Normal:Normal,FloatBorder:Comment"
            end
        end,
    })
end

return M
