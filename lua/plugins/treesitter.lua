local M = {}

local function setup_treesitter_objects()
    vim.g.no_plugin_maps = true

    -- Setup basic options
    require("nvim-treesitter-textobjects").setup({
        select = {
            enable = true,
            lookahead = true,
            include_surrounding_whitespace = false,
            selection_modes = {
                ["@parameter.outer"] = "v",
                ["@function.outer"] = "V",
                ["@class.outer"] = "V",
            },
        },
    })

    local move = require("nvim-treesitter-textobjects.move")
    local swap = require("nvim-treesitter-textobjects.swap")
    local repeat_move = require("nvim-treesitter-textobjects.repeatable_move")
    local load = require("core.load")
    local tselect = require("nvim-treesitter-textobjects.select")

    -- Wrap move functions to make them repeatable
    local goto_next_start = repeat_move.make_repeatable_move(move.goto_next_start)
    local goto_next_end = repeat_move.make_repeatable_move(move.goto_next_end)
    local goto_previous_start = repeat_move.make_repeatable_move(move.goto_previous_start)
    local goto_previous_end = repeat_move.make_repeatable_move(move.goto_previous_end)

    -- Define move mappings declaratively
    local move_maps = {
        {
            "]",
            {
                { "f", goto_next_start, "@function.outer", "Next function start" },
                { "F", goto_next_end, "@function.outer", "Next function end" },
                { "]", goto_next_start, "@class.outer", "Next class start" },
                { "[", goto_next_end, "@class.outer", "Next class end" },
                { "o", goto_next_start, { "@loop.inner", "@loop.outer" }, "Next loop start" },
                { "i", goto_next_start, "@conditional.outer", "Next conditional start" },
                { "a", goto_next_start, "@parameter.inner", "Next argument start" },
                { "A", goto_next_end, "@parameter.inner", "Next argument end" },
                { "c", goto_next_start, "@call.outer", "Next call start" },
                { "=", goto_next_start, "@assignment.outer", "Next assignment start" },
            },
        },
        {
            "[",
            {
                { "f", goto_previous_start, "@function.outer", "Prev function start" },
                { "F", goto_previous_end, "@function.outer", "Prev function end" },
                { "[", goto_previous_start, "@class.outer", "Prev class start" },
                { "]", goto_previous_end, "@class.outer", "Prev class end" },
                { "o", goto_previous_start, { "@loop.inner", "@loop.outer" }, "Prev loop start" },
                { "i", goto_previous_start, "@conditional.outer", "Prev conditional start" },
                { "a", goto_previous_start, "@parameter.inner", "Prev argument start" },
                { "A", goto_previous_end, "@parameter.inner", "Prev argument end" },
                { "c", goto_previous_start, "@call.outer", "Prev call start" },
                { "=", goto_previous_start, "@assignment.outer", "Prev assignment start" },
            },
        },
    }

    local wk_specs = {
        { "]", group = "Next Textobject" },
        { "[", group = "Prev Textobject" },
        { "<leader>s", group = "Swap Textobject" },
    }

    -- Populate move mappings
    for _, group_info in ipairs(move_maps) do
        local prefix = group_info[1]
        for _, map in ipairs(group_info[2]) do
            local key = prefix .. map[1]
            local fn = map[2]
            local query = map[3]
            local desc = map[4]
            table.insert(wk_specs, {
                key,
                function()
                    fn(query, "textobjects")
                end,
                desc = desc,
                mode = { "n", "x", "o" },
            })
        end
    end

    -- Populate swap mappings
    local swap_maps = {
        { "<leader>sn", swap.swap_next, "@parameter.inner", "Swap parameter next" },
        { "<leader>sp", swap.swap_previous, "@parameter.inner", "Swap parameter prev" },
    }
    for _, map in ipairs(swap_maps) do
        local key = map[1]
        local fn = map[2]
        local query = map[3]
        local desc = map[4]
        table.insert(wk_specs, {
            key,
            function()
                fn(query)
            end,
            desc = desc,
            mode = { "n", "x", "o" },
        })
    end

    -- Populate selection mappings
    local select_maps = {
        -- Around
        { "af", "@function.outer", "Around function" },
        { "ac", "@class.outer", "Around class" },
        { "aa", "@parameter.outer", "Around argument" },
        { "ai", "@conditional.outer", "Around conditional" },
        { "al", "@loop.outer", "Around loop" },
        { "a=", "@assignment.outer", "Around assignment" },
        { "aC", "@call.outer", "Around function call" },
        { "a/", "@comment.outer", "Around comment" },
        -- Inside
        { "if", "@function.inner", "Inside function" },
        { "ic", "@class.inner", "Inside class" },
        { "ia", "@parameter.inner", "Inside argument" },
        { "ii", "@conditional.inner", "Inside conditional" },
        { "il", "@loop.inner", "Inside loop" },
        { "i=", "@assignment.inner", "Inside assignment" },
        { "l=", "@assignment.lhs", "LHS of assignment" },
        { "r=", "@assignment.rhs", "RHS of assignment" },
        { "iC", "@call.inner", "Inside function call" },
        { "i/", "@comment.inner", "Inside comment" },
    }

    local select_wk = {
        mode = { "x", "o" },
        { "a", group = "Around Textobject" },
        { "i", group = "Inside Textobject" },
    }

    for _, map in ipairs(select_maps) do
        local key = map[1]
        local query = map[2]
        local desc = map[3]
        table.insert(select_wk, {
            key,
            function()
                tselect.select_textobject(query, "textobjects")
            end,
            desc = desc,
            mode = { "x", "o" },
        })
    end

    load.keymap(wk_specs)
    load.keymap(select_wk)

    -- Configure repeatable moves for ; and ,
    vim.keymap.set({ "n", "x", "o" }, ";", repeat_move.repeat_last_move_next, { desc = "Repeat last move forward" })
    vim.keymap.set(
        { "n", "x", "o" },
        ",",
        repeat_move.repeat_last_move_previous,
        { desc = "Repeat last move backward" }
    )

    -- Make standard f, F, t, T movement keys repeatable with ; and ,
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
