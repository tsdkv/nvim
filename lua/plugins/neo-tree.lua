local M = {}

M.setup = function()
    require('neo-tree').setup({
        close_if_last_window = true,
    })

    require('which-key').add({
        { '<leader>e', '<Cmd>Neotree<CR>', desc = 'Toggle explorer' }
    })
end

return M
