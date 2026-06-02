local M = {}

M.keymap = {
    { "s", function() require("flash").jump() end, mode = { "n", "x", "o" }, desc = "Flash Jump" },
    { "gS", function() require("flash").treesitter() end, mode = { "n", "x", "o" }, desc = "Flash Treesitter" },
    { "r", function() require("flash").remote() end, mode = "o", desc = "Remote Flash" },
    { "R", function() require("flash").treesitter_search() end, mode = { "o", "x" }, desc = "Treesitter Search" },
    { "<c-s>", function() require("flash").toggle() end, mode = "c", desc = "Toggle Flash Search" },
}

M.setup = function()
    require("flash").setup({
        modes = {
            char = {
                enabled = false,
                jump_labels = true,
            },
        },
    })
end

return M
