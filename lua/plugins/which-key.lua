local M = {}

function M.setup()
    -- Neovim 0.10+ adds default gr mappings. We delete them immediately before Which-Key
    -- is initialized so that it doesn't cache `gr` as a prefix, which would cause a delay.
    pcall(vim.keymap.del, "n", "grr")
    pcall(vim.keymap.del, "n", "gra")
    pcall(vim.keymap.del, "n", "grn")
    pcall(vim.keymap.del, "n", "gri")
    pcall(vim.keymap.del, "n", "grt")
    pcall(vim.keymap.del, "n", "grx")

    require("which-key").setup({})

    -- Leader-group prefixes only. Individual maps are registered by each plugin file.
    require("which-key").add({
        { "<leader>g", group = "Git" },
        { "<leader>f", group = "Find" },
        { "<leader>l", group = "LSP / Code" },
        { "<leader>d", group = "Diagnostics" },
        { "<leader>u", group = "UI" },
        { "<leader>t", group = "Terminal" },
        { "<leader>q", group = "Quit / Session" },
    })
end

return M
