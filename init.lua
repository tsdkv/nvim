_G.P = function(...)
    for _, v in ipairs({ ... }) do
        print(vim.inspect(v))
    end
    return ...
end

require('config.options')
require('config.keymap')
require('config.autocmds')
require('config.commands')
require('plugins')
