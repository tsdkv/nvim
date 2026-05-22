local M = {}

function M.setup()
    local ts = require('telescope')
    local actions = require('telescope.actions')

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
            }
        }
    })
    ts.load_extension('bookmarks')

    local builtin = require('telescope.builtin')
    require('which-key').add({
        { '<leader>ff',    builtin.find_files,            desc = 'Find files' },
        { '<leader>fg',    builtin.live_grep,             desc = 'Live grep' },
        { '<leader>fb',    builtin.buffers,               desc = 'Buffers' },
        { '<leader>f<cr>', builtin.resume,                desc = 'Resume last search' },

        { '<leader>fm',    ts.extensions.bookmarks.list,  desc = 'Bookmarks (Marks)' },

        { '<leader>fs',    builtin.lsp_document_symbols,  desc = 'Document symbols' },
        { '<leader>fS',    builtin.lsp_workspace_symbols, desc = 'Workspace symbols' },
        { '<leader>fr',    builtin.lsp_references,        desc = 'LSP references' },

        { '<leader>gs',    builtin.git_status,            desc = 'Git status' },
    })
end

return M
