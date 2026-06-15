local M = {}

M.setup = function()
    local arrow = require("arrow")

    arrow.setup({
        show_icons = true,
        leader_key = "'",
        buffer_leader_key = false,

        window = {
            width = "auto",
            height = "auto",
            row = "auto",
            col = "auto",
            border = "rounded",
        },
    })
end

return M
