local function workspace_root(bufnr, on_dir)
    local crate = vim.fs.root(bufnr, "Cargo.toml")
    if not crate then
        on_dir(vim.fs.root(bufnr, { "rust-project.json", ".git" }))
        return
    end
    if vim.fn.executable("cargo") == 0 then
        on_dir(crate)
        return
    end

    -- Cargo resolves workspace membership, including explicit package.workspace paths.
    vim.system(
        { "cargo", "locate-project", "--workspace", "--message-format", "plain" },
        { cwd = crate, text = true },
        vim.schedule_wrap(function(result)
            if vim.api.nvim_buf_is_loaded(bufnr) then
                local manifest = vim.trim(result.stdout or "")
                on_dir(result.code == 0 and manifest ~= "" and vim.fs.dirname(manifest) or crate)
            end
        end)
    )
end

return {
    name = "rust_analyzer",
    filetypes = { "rust" },
    tools = { "rust-analyzer" },
    setup = function()
        vim.lsp.config("rust_analyzer", {
            cmd = { "rust-analyzer" },
            filetypes = { "rust" },
            root_dir = workspace_root,
            settings = {
                ["rust-analyzer"] = {
                    check = { command = "check" },
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
