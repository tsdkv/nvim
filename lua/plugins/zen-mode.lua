local M = {}

function M.register()
    require('which-key').add({
        { '<leader>z', '<cmd>ZenMode<cr>', desc = 'Zen mode' },
    })
end

function M.setup()
    require('zen-mode').setup({})
end

return M
