local M = {}

M.setup = function()
    require("smart-splits").setup({
        mux = {
            backend = "smart-splits-backend-rex",
            warn_if_unusable = true,
        },
    })
end

M.keymap = {
    { "<C-h>", function() require("smart-splits").move_cursor_left() end, desc = "Move focus left" },
    { "<C-j>", function() require("smart-splits").move_cursor_down() end, desc = "Move focus down" },
    { "<C-k>", function() require("smart-splits").move_cursor_up() end, desc = "Move focus up" },
    { "<C-l>", function() require("smart-splits").move_cursor_right() end, desc = "Move focus right" },
    { "<A-h>", function() require("smart-splits").resize_left() end, desc = "Resize split left" },
    { "<A-j>", function() require("smart-splits").resize_down() end, desc = "Resize split down" },
    { "<A-k>", function() require("smart-splits").resize_up() end, desc = "Resize split up" },
    { "<A-l>", function() require("smart-splits").resize_right() end, desc = "Resize split right" },
}

return M
