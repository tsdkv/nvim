local M = {}

M.setup = function()
    require('bookmarks').setup({
        keywords = {
            ["@t"] = '󰄲 ',
            ["@w"] = '󰀪 ',
            ["@f"] = ' ',
            ["@n"] = '󰎚 ',
        },

        on_attach = function(bufnr)
            local bm = require("bookmarks")
            local wk = require("which-key")
            wk.add({
                { "m",  group = "Bookmarks" },
                { "mm", bm.bookmark_toggle,    desc = "Toggle Bookmark" },
                { "mi", bm.bookmark_ann,       desc = "Add/Edit Annotation" },
                { "mc", bm.bookmark_clean,     desc = "Clean Buffer Bookmarks" },
                { "mn", bm.bookmark_next,      desc = "Next Bookmark" },
                { "mp", bm.bookmark_prev,      desc = "Prev Bookmark" },
                { "ml", bm.bookmark_list,      desc = "List Bookmarks (Quickfix)" },
                { "mx", bm.bookmark_clear_all, desc = "Clear All Bookmarks (Project)" },
            }, { buffer = bufnr })
        end
    })
end

return M
