local actions = require("telescope.actions")

local function cool_buffers()
    local opts = {
        previewer = false,
        sort_mru = false,
        sort_lastused = false,
        show_bufnr = false,
        ignore_current_buffer = true,
        prompt_title = false,
        results_title = false,
        layout_config = {
            width = 0.55,
            height = 0.35,
        },
        initial_mode = "insert",
    }

    opts.attach_mappings = function(prompt_bufnr, map)
        local action_state = require("telescope.actions.state")

        map("n", "d", actions.delete_buffer)
        map("i", "<C-d>", actions.delete_buffer)

        -- Automatically open the buffer if it is the only match remaining
        vim.api.nvim_buf_attach(prompt_bufnr, false, {
            on_lines = function()
                vim.schedule(function()
                    if not vim.api.nvim_buf_is_valid(prompt_bufnr) then
                        return
                    end
                    local picker = action_state.get_current_picker(prompt_bufnr)
                    if picker then
                        local prompt = picker:_get_prompt()
                        if #prompt > 0 and picker.manager:num_results() == 1 then
                            actions.select_default(prompt_bufnr)
                        end
                    end
                end)
            end,
        })

        return true
    end

    require("telescope.builtin").buffers(require("telescope.themes").get_dropdown(opts))
end

local M = {}

M.keymap = {
    { "<leader>f<cr>", "<cmd>Telescope resume<cr>", desc = "Resume last search" },
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
    { "<leader>fb", cool_buffers, desc = "Buffers" },
    { "<leader>fo", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
    { "<leader>fm", "<cmd>Telescope bookmarks list<cr>", desc = "Bookmarks" },
    { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document symbols" },
    { "<leader>fS", "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "Workspace symbols" },
    { "<leader>fr", "<cmd>Telescope lsp_references<cr>", desc = "LSP references" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
    { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
    { "<leader>fc", "<cmd>Telescope commands<cr>", desc = "Commands" },
    { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
    { "<leader>fw", "<cmd>Telescope grep_string<cr>", desc = "Grep word under cursor" },
    { "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Git status" },
    { "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Git commits" },
}

function M.setup()
    local ts = require("telescope")

    ts.setup({
        defaults = {
            prompt_prefix = "  ",
            selection_caret = "  ",
            path_display = { "truncate" },
            sorting_strategy = "ascending",
            layout_config = {
                horizontal = {
                    prompt_position = "top",
                    preview_width = 0.55,
                },
                vertical = {
                    prompt_position = "top",
                    mirror = true, -- keeps prompt on top in vertical layout
                },
            },
            mappings = {
                i = {
                    ["<C-f>"] = actions.to_fuzzy_refine,
                },
            },
        },
        extensions = {
            fzf = {
                fuzzy = true,
                override_generic_sorter = true,
                override_file_sorter = true,
                case_mode = "smart_case",
            },
            ["ui-select"] = {
                require("telescope.themes").get_dropdown({
                    winblend = 10,
                    borderchars = {
                        prompt = { "─", "│", " ", "│", "╭", "╮", "│", "│" },
                        results = { "─", "│", "─", "│", "├", "┤", "╯", "╰" },
                        preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
                    },
                }),
            },
        },
    })
    ts.load_extension("bookmarks")
    ts.load_extension("fzf")
    ts.load_extension("ui-select")
end

return M
