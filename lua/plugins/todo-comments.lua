local M = {}

function M.setup()
    local tc = require("todo-comments")

    tc.setup({
        signs = true, -- show icons in the sign column
        merge_keywords = true, -- merge custom keywords with default ones
        highlight = {
            multiline = true, -- enable multiline todo comments
            multiline_pattern = "^[ \t]*", -- lua pattern to match lines
            multiline_context = 10, -- number of lines to search for multiline context
            before = "", -- "fg" or "bg" or empty
            keyword = "wide", -- "fg", "bg", "wide" or empty
            after = "fg", -- "fg" or "bg" or empty
            pattern = [[.*<(KEYWORDS)\s*:]], -- pattern used for highlighting (must include KEYWORDS)
            comments_only = true, -- highlight only inside comments
            max_line_len = 400, -- ignore lines longer than this
            exclude = {}, -- list of file types to exclude
        },
    })

    require("which-key").add({
        { "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Search TODO comments" },
        { "]t", tc.jump_next, desc = "Next TODO comment" },
        { "[t", tc.jump_prev, desc = "Previous TODO comment" },
    })
end

return M
