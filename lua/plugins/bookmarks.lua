local M = {}

M.keymap = {
    { "mm", function() require("bookmarks").bookmark_toggle() end, desc = "Toggle Bookmark" },
    { "mi", function() require("bookmarks").bookmark_ann() end, desc = "Add/Edit Annotation" },
    { "mc", function() require("bookmarks").bookmark_clean() end, desc = "Clean Buffer Bookmarks" },
    { "mn", function() require("bookmarks").bookmark_next() end, desc = "Next Bookmark" },
    { "mp", function() require("bookmarks").bookmark_prev() end, desc = "Prev Bookmark" },
    { "ml", function() require("bookmarks").bookmark_list() end, desc = "List Bookmarks (Quickfix)" },
    { "mx", function() require("bookmarks").bookmark_clear_all() end, desc = "Clear All Bookmarks (Project)" },
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
