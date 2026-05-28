local M = {}

M.setup = function()
    local flash = require("flash")

    flash.setup({
        modes = {
            char = {
                enabled = true,
                jump_labels = true,
            },
        },
    })

    require("which-key").add({
        { "s", flash.jump, mode = { "n", "x", "o" }, desc = "Flash Jump" },
        { "gS", flash.treesitter, mode = { "n", "x", "o" }, desc = "Flash Treesitter" },
        { "r", flash.remote, mode = "o", desc = "Remote Flash" },
        { "R", flash.treesitter_search, mode = { "o", "x" }, desc = "Treesitter Search" },
        { "<c-s>", flash.toggle, mode = "c", desc = "Toggle Flash Search" },
    })
end

return M
