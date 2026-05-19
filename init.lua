_G.Config = {}

_G.P = function(...)
    for _, v in ipairs({ ... }) do
        print(vim.inspect(v))
    end
    return ...
end

require('plugins')
require('options')
require('keymap')
require('colorscheme')

local core = require('core')
core.on_event("BufReadPre", function()
    require('lsp').setup()
end)

