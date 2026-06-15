local M = {}

M.keymap = {
    {
        "<leader>bb",
        function()
            require("bookmarks").bookmark_toggle()
        end,
        desc = "Toggle Bookmark",
    },
    {
        "<leader>bi",
        function()
            require("bookmarks").bookmark_ann()
        end,
        desc = "Add/Edit Annotation",
    },
    {
        "<leader>bc",
        function()
            require("bookmarks").bookmark_clean()
        end,
        desc = "Clean Buffer Bookmarks",
    },
    {
        "<leader>bn",
        function()
            require("bookmarks").bookmark_next()
        end,
        desc = "Next Bookmark",
    },
    {
        "<leader>bp",
        function()
            require("bookmarks").bookmark_prev()
        end,
        desc = "Prev Bookmark",
    },
    {
        "<leader>bl",
        function()
            require("bookmarks").bookmark_list()
        end,
        desc = "List Bookmarks (Quickfix)",
    },
    {
        "<leader>bx",
        function()
            require("bookmarks").bookmark_clear_all()
        end,
        desc = "Clear All Bookmarks (Project)",
    },
}

M.setup = function()
    require("bookmarks").setup({
        save_file = vim.fn.stdpath("data") .. "/bookmarks",
        keywords = {
            ["@t"] = "󰄲 ",
            ["@w"] = "󰀪 ",
            ["@f"] = " ",
            ["@n"] = "󰎚 ",
        },
        signs = {
            add = { text = "" },
        },
    })
end

return M
