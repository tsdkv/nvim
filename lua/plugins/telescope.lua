local M = {}

local setup_done = false
function M.ensure_setup()
    if setup_done then
        return
    end
    setup_done = true
    require("core.load").now(function()
        local ts = require("telescope")
        ts.setup({
            defaults = {
                prompt_prefix = "",
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
                        mirror = true,
                    },
                },
                mappings = {
                    i = {
                        ["<C-f>"] = function(...)
                            return require("telescope.actions").to_fuzzy_refine(...)
                        end,
                        ["<c-t>"] = function(...)
                            return require("trouble.sources.telescope").open(...)
                        end,
                    },
                    n = {
                        ["<c-t>"] = function(...)
                            return require("trouble.sources.telescope").open(...)
                        end,
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
    end, "telescope setup")
end

local function cool_buffers()
    M.ensure_setup()
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
        local actions = require("telescope.actions")
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

local function run_builtin(name)
    return function()
        M.ensure_setup()
        require("telescope.builtin")[name]()
    end
end

M.keymap = {
    { "<leader>f<cr>", run_builtin("resume"), desc = "Resume last search" },
    { "<leader>ff", run_builtin("find_files"), desc = "Find files" },
    { "<leader>fg", run_builtin("live_grep"), desc = "Live grep" },
    { "<leader>fb", cool_buffers, desc = "Buffers" },
    { "<leader>fo", run_builtin("oldfiles"), desc = "Recent files" },
    {
        "<leader>fm",
        function()
            M.ensure_setup()
            vim.cmd("Telescope bookmarks list")
        end,
        desc = "Bookmarks",
    },
    { "<leader>fs", run_builtin("lsp_document_symbols"), desc = "Document symbols" },
    { "<leader>fS", run_builtin("lsp_workspace_symbols"), desc = "Workspace symbols" },
    { "<leader>fr", run_builtin("lsp_references"), desc = "LSP references" },
    { "<leader>fh", run_builtin("help_tags"), desc = "Help tags" },
    { "<leader>fk", run_builtin("keymaps"), desc = "Keymaps" },
    { "<leader>fc", run_builtin("commands"), desc = "Commands" },
    { "<leader>fd", run_builtin("diagnostics"), desc = "Diagnostics" },
    { "<leader>fw", run_builtin("grep_string"), desc = "Grep word under cursor" },
    { "<leader>gs", run_builtin("git_status"), desc = "Git status" },
    { "<leader>gc", run_builtin("git_commits"), desc = "Git commits" },
}

function M.setup()
    -- Fallback: if the user types `:Telescope` manually, ensure it's set up
    vim.api.nvim_create_autocmd("CmdlineEnter", {
        pattern = ":",
        once = true,
        callback = function()
            vim.schedule(M.ensure_setup)
        end,
    })
end

return M
