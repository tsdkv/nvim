local M = {}

local function setup_treesitter_objects()
    vim.g.no_plugin_maps = true

    require("nvim-treesitter-textobjects").setup({
        select = {
            lookahead = true,
            include_surrounding_whitespace = false,
            selection_modes = {
                ["@parameter.outer"] = "v",
                ["@function.outer"] = "V",
                ["@class.outer"] = "V",
            },
        },
        move = {
            set_jumps = true, -- Add jumps to jumplist (<C-o> / <C-i>)
        },
    })

    local move = require("nvim-treesitter-textobjects.move")
    local swap = require("nvim-treesitter-textobjects.swap")
    local repeat_move = require("nvim-treesitter-textobjects.repeatable_move")
    local wk = require("which-key")
    local tselect = require("nvim-treesitter-textobjects")

    wk.add({
        { "]", group = "Next Textobject" },
        {
            "]m",
            function()
                move.goto_next_start("@function.outer", "textobjects")
            end,
            desc = "Next function start",
        },
        {
            "]M",
            function()
                move.goto_next_end("@function.outer", "textobjects")
            end,
            desc = "Next function end",
        },
        {
            "]]",
            function()
                move.goto_next_start("@class.outer", "textobjects")
            end,
            desc = "Next class start",
        },
        {
            "][",
            function()
                move.goto_next_end("@class.outer", "textobjects")
            end,
            desc = "Next class end",
        },
        {
            "]o",
            function()
                move.goto_next_start({ "@loop.inner", "@loop.outer" }, "textobjects")
            end,
            desc = "Next loop",
        },
        {
            "]i",
            function()
                move.goto_next_start("@conditional.outer", "textobjects")
            end,
            desc = "Next conditional (if)",
        },

        { "[", group = "Prev Textobject" },
        {
            "[m",
            function()
                move.goto_previous_start("@function.outer", "textobjects")
            end,
            desc = "Prev function start",
        },
        {
            "[M",
            function()
                move.goto_previous_end("@function.outer", "textobjects")
            end,
            desc = "Prev function end",
        },
        {
            "[[",
            function()
                move.goto_previous_start("@class.outer", "textobjects")
            end,
            desc = "Prev class start",
        },
        {
            "[]",
            function()
                move.goto_previous_end("@class.outer", "textobjects")
            end,
            desc = "Prev class end",
        },
        {
            "[o",
            function()
                move.goto_previous_start({ "@loop.inner", "@loop.outer" }, "textobjects")
            end,
            desc = "Prev loop",
        },
        {
            "[i",
            function()
                move.goto_previous_start("@conditional.outer", "textobjects")
            end,
            desc = "Prev conditional (if)",
        },
    })

    wk.add({
        { "<leader>s", group = "Swap Textobject" },
        {
            "<leader>sn",
            function()
                swap.swap_next("@parameter.inner")
            end,
            desc = "Swap parameter with next",
        },
        {
            "<leader>sp",
            function()
                swap.swap_previous("@parameter.inner")
            end,
            desc = "Swap parameter with prev",
        },
    })

    wk.add({
        mode = { "x", "o" },
        { "a", group = "Around Textobject" },
        {
            "af",
            function()
                tselect.select_textobject("@function.outer", "textobjects")
            end,
            desc = "Around function",
        },
        {
            "ac",
            function()
                tselect.select_textobject("@class.outer", "textobjects")
            end,
            desc = "Around class",
        },
        {
            "aa",
            function()
                tselect.select_textobject("@parameter.outer", "textobjects")
            end,
            desc = "Around argument",
        },
        {
            "ai",
            function()
                tselect.select_textobject("@conditional.outer", "textobjects")
            end,
            desc = "Around conditional",
        },
        {
            "al",
            function()
                tselect.select_textobject("@loop.outer", "textobjects")
            end,
            desc = "Around loop",
        },

        { "i", group = "Inside Textobject" },
        {
            "if",
            function()
                tselect.select_textobject("@function.inner", "textobjects")
            end,
            desc = "Inside function",
        },
        {
            "ic",
            function()
                tselect.select_textobject("@class.inner", "textobjects")
            end,
            desc = "Inside class",
        },
        {
            "ia",
            function()
                tselect.select_textobject("@parameter.inner", "textobjects")
            end,
            desc = "Inside argument",
        },
        {
            "ii",
            function()
                tselect.select_textobject("@conditional.inner", "textobjects")
            end,
            desc = "Inside conditional",
        },
        {
            "il",
            function()
                tselect.select_textobject("@loop.inner", "textobjects")
            end,
            desc = "Inside loop",
        },
    })

    vim.keymap.set({ "n", "x", "o" }, ";", repeat_move.repeat_last_move_next, { desc = "Repeat last move forward" })
    vim.keymap.set(
        { "n", "x", "o" },
        ",",
        repeat_move.repeat_last_move_previous,
        { desc = "Repeat last move backward" }
    )

    vim.keymap.set({ "n", "x", "o" }, "f", repeat_move.builtin_f_expr, { expr = true, desc = "Find forward" })
    vim.keymap.set({ "n", "x", "o" }, "F", repeat_move.builtin_F_expr, { expr = true, desc = "Find backward" })
    vim.keymap.set({ "n", "x", "o" }, "t", repeat_move.builtin_t_expr, { expr = true, desc = "Till forward" })
    vim.keymap.set({ "n", "x", "o" }, "T", repeat_move.builtin_T_expr, { expr = true, desc = "Till backward" })
end

M.setup = function()
    require("core.load").later(function()
        require("nvim-treesitter").install({
            "c",
            "cpp",
            "go",
            "rust",
            "lua",
            "yaml",
            "json",
            "markdown",
            "markdown_inline",
        })
    end)

    vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("CoreTreesitter", { clear = true }),
        pattern = "*",
        callback = function(args)
            -- Start syntax highlighting safely (ignores files without parsers)
            pcall(vim.treesitter.start, args.buf)

            -- Enable AST-based folding for the current window
            vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
            vim.wo[0][0].foldmethod = "expr"
            vim.wo[0][0].foldtext = ""

            -- Enable AST-based indentation for the current buffer
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
    })

    setup_treesitter_objects()
end

return M
