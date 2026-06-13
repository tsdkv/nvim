local M = {}

function M.setup()
    require("crates").setup({
        lsp = {
            enabled = true,
            actions = true,
            completion = true,
            hover = true,
        },
        completion = {
            cmp = { enabled = false },
        },
    })

    local group = vim.api.nvim_create_augroup("CratesKeymaps", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = "toml",
        callback = function(ev)
            require("core.load").keymap({
                -- { "<leader>rc", group = "Crates" },
                {
                    "<leader>rcu",
                    function()
                        require("crates").upgrade_crate()
                    end,
                    desc = "Upgrade Crate",
                },
                {
                    "<leader>rcU",
                    function()
                        require("crates").upgrade_all_crates()
                    end,
                    desc = "Upgrade All Crates",
                },
                {
                    "<leader>rci",
                    function()
                        require("crates").show_crate_popup()
                    end,
                    desc = "Crate Info",
                },
                {
                    "<leader>rcf",
                    function()
                        require("crates").show_features_popup()
                    end,
                    desc = "Crate Features",
                },
                {
                    "<leader>rcd",
                    function()
                        require("crates").show_dependencies_popup()
                    end,
                    desc = "Crate Dependencies",
                },
                {
                    "<leader>rcv",
                    function()
                        require("crates").show_versions_popup()
                    end,
                    desc = "Crate Versions",
                },
            }, { buffer = ev.buf })
        end,
    })
end

return M
