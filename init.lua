if vim.fn.has("nvim-0.12") == 0 then
    vim.notify("Error: Neovim >= 0.12 is required", vim.log.levels.ERROR)
    return
end

_G.P = function(...)
    for _, v in ipairs({ ... }) do
        print(vim.inspect(v))
    end
    return ...
end

require("config.options")
require("config.keymap")
require("config.autocmds")
require("config.commands")
require("plugins")
