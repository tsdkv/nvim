local M = {}

M.keymap = {
    {
        "<leader>ft",
        function()
            require("plugins.telescope").ensure_setup()
            vim.cmd("TodoTelescope")
        end,
        desc = "Search TODO comments",
    },
    { "]t", function() require("todo-comments").jump_next() end, desc = "Next TODO comment" },
    { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous TODO comment" },
}

function M.setup()
    require("todo-comments").setup({
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
end

return M
