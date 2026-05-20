local M = {}

function M.setup()
    require('zen-mode').setup({})

    require('which-key').add({
        { '<leader>z', function()
            require('zen-mode').toggle({ window = { width = .75 } })
        end, desc = 'Zen mode' },
    })
end

return M
