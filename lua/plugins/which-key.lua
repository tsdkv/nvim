local M = {}

function M.setup()
    require("which-key").setup({})

    -- Leader-group prefixes only. Individual maps are registered by each plugin file.
    require("which-key").add({
        { "<leader>b", group = "Buffer" },
        { "<leader>g", group = "Git" },
        { "<leader>f", group = "Find" },
        { "<leader>l", group = "LSP / Code" },
        { "<leader>d", group = "Diagnostics" },
        { "<leader>u", group = "UI" },
    })
end

return M
