local M = {}

function M.setup()
    local ts = require('telescope')
    ts.setup({})
    ts.load_extension('bookmarks')

    local builtin = require('telescope.builtin')
    require('which-key').add({
        { '<leader>ff',    builtin.find_files,                             desc = 'Find files' },
        { '<leader>fg',    builtin.live_grep,                              desc = 'Live grep' },
        { '<leader>fb',    builtin.buffers,                                desc = 'Buffers' },
        { '<leader>f<cr>', builtin.resume,                                 desc = 'Last search' },
        { '<leader>fb',    require('telescope').extensions.bookmarks.list, desc = 'Bookmarks' }
    })
end

return M
