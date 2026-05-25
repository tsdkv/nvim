local M = {}

function M.register()
    require("which-key").add({
        { "<leader>f<cr>", "<cmd>Telescope resume<cr>", desc = "Resume last search" },
        { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
        { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
        { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
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
    })
end

function M.setup()
    local ts = require("telescope")
    local actions = require("telescope.actions")

    ts.setup({
        defaults = {
            path_display = { "truncate" },
            sorting_strategy = "ascending",
            layout_config = {
                horizontal = {
                    prompt_position = "top",
                    preview_width = 0.55,
                },
            },
            mappings = {
                i = {
                    ["<C-f>"] = actions.to_fuzzy_refine,
                },
            },
        },
    })
    ts.load_extension("bookmarks")
end

return M
