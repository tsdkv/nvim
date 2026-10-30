local tools = require("plugins.lsp.servers.go.tools")
local commands = require("plugins.lsp.servers.go.commands")
local settings = require("plugins.lsp.servers.go.settings")

return {
    name = "gopls",
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    tools = { "gopls", "iferr", "goimports", "gofumpt", "impl", "gomodifytags" },
    setup = function()
        vim.lsp.config("gopls", {
            cmd = { "gopls" },
            filetypes = { "go", "gomod", "gowork", "gotmpl" },
            root_markers = { "go.work", "go.mod", ".git" },
            -- Send didChange notifications to gopls at most every 300ms
            -- instead of the default 150ms (halves LSP traffic while typing).
            flags = { debounce_text_changes = 300 },
            settings = settings.get(),
        })
        vim.lsp.enable("gopls")
    end,
    on_attach = function(_, bufnr)
        require("core.load").keymap({
            { "<leader>lg", group = "Go Tools" },
            { "<leader>lge", tools.iferr, desc = "iferr: generate error block" },
            { "<leader>lgi", tools.impl, desc = "Generate interface stubs (impl)" },
            { "<leader>lgs", commands.toggle_staticcheck, desc = "Toggle staticcheck" },
            { "<leader>lgc", commands.gc_details, desc = "Toggle gc details (escape/inline analysis)" },
            {
                "<leader>lgt",
                function()
                    tools.modify_tags(false)
                end,
                desc = "Add Struct Tags",
            },
            {
                "<leader>lgT",
                function()
                    tools.modify_tags(true)
                end,
                desc = "Clear Struct Tags",
            },
        }, { buffer = bufnr })
    end,
}
