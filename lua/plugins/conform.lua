local M = {}

M.keymap = {
    {
        "<leader>lf",
        function()
            require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        desc = "Format Document",
        mode = { "n", "v" },
    },
}

function M.setup()
    require("conform").setup({
        formatters_by_ft = {
            -- Run goimports first (fixes imports), then gofumpt (stricter formatting)
            go = { "goimports", "gofumpt" },
            lua = { "stylua" },
            rust = { "rustfmt" },

            -- Common config/data formats
            json = { "prettier", stop_after_first = true },
            jsonc = { "prettier", stop_after_first = true },
            yaml = { "prettier", stop_after_first = true },
            toml = { "taplo" },

            -- Fallback: trim trailing whitespace on any filetype without a formatter
            ["_"] = { "trim_whitespace" },
        },

        -- Format on save; lsp_format = "fallback" means: use LSP only when no
        -- conform formatter is configured for the filetype (e.g. for unknown types).
        format_on_save = {
            timeout_ms = 500,
            lsp_format = "fallback",
        },

        -- Only notify on actual errors, not when no formatter is found
        notify_on_error = true,
        notify_no_formatters = false,
    })
end

return M
