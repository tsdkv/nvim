local M = {}

function M.setup()
    -- Trigger which-key on bookmarks
    require("which-key").setup({
        triggers = {
            { "<auto>", mode = "nxso" },
            { "m", mode = { "n", "v" } },
        },
    })

    -- Group labels only. Individual maps are registered by each plugin file natively,
    -- but which-key can still pick up their descriptions.
    require("which-key").add({
        { "<leader>g", group = "Git" },
        { "<leader>f", group = "Find" },
        { "<leader>l", group = "LSP / Code" },
        { "<leader>d", group = "Diagnostics" },
        { "<leader>u", group = "UI" },
        { "<leader>t", group = "Terminal" },
        { "<leader>q", group = "Quit / Session" },
        { "m", group = "Bookmarks" },
    })
end

return M
