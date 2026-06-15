local M = {}

M.keymap = {
    -- Substitute: Replaces text with yanked text (keeps yanked text in register)
    {
        "gs",
        function()
            require("substitute").operator()
        end,
        desc = "Substitute (motion) - e.g. gsiw (word), gsa' (quotes)",
    },
    {
        "gss",
        function()
            require("substitute").line()
        end,
        desc = "Substitute line - e.g. gss (entire line)",
    },
    {
        "gS",
        function()
            require("substitute").eol()
        end,
        desc = "Substitute to EOL - e.g. gS (cursor to end of line)",
    },
    {
        "gs",
        function()
            require("substitute").visual()
        end,
        mode = "x",
        desc = "Substitute selection - e.g. select text, press gs",
    },

    -- Exchange: Swaps two text regions
    {
        "gsx",
        function()
            require("substitute.exchange").operator()
        end,
        desc = "Exchange (motion) - e.g. gsxiw on word1, gsxiw on word2",
    },
    {
        "gsxx",
        function()
            require("substitute.exchange").line()
        end,
        desc = "Exchange line - e.g. gsxx on line1, gsxx on line2",
    },
    {
        "gsxc",
        function()
            require("substitute.exchange").cancel()
        end,
        desc = "Exchange cancel - clears marked text",
    },
    {
        "gsX",
        function()
            require("substitute.exchange").visual()
        end,
        mode = "x",
        desc = "Exchange selection - e.g. select text, gsX, select other, gsX",
    },
}

M.setup = function()
    require("substitute").setup()
end

return M
