return {
    name = "rust_analyzer",
    filetypes = { "rust" },
    tools = { "rust-analyzer" },
    setup = function()
        vim.lsp.config("rust_analyzer", {
            cmd = { "rust-analyzer" },
            filetypes = { "rust" },
            root_markers = { "Cargo.toml", "rust-project.json", ".git" },
            settings = {
                ["rust-analyzer"] = {
                    check = { command = "clippy" },
                    inlayHints = {
                        closingBraceHints = { enable = true },
                        lifetimeElisionHints = { enable = "always" },
                        reborrowHints = { enable = "always" },
                    },
                    completion = {
                        fullFunctionSignatures = { enable = true },
                        postfix = { enable = true },
                        snippets = {
                            custom = {
                                ["Parentheses"] = {
                                    postfix = "par",
                                    body = "(${receiver})",
                                    description = "Wrap expression in parentheses",
                                },
                            },
                        },
                    },
                    diagnostics = {
                        styleLints = { enable = true },
                    },
                    procMacro = { enable = true },
                },
            },
        })
        vim.lsp.enable("rust_analyzer")
    end,
}
