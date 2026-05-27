local wk = require("which-key")

local M = {}

local function keymaps(bufnr)
    wk.add({
        { "gd", vim.lsp.buf.definition, desc = "Go to Definition" },
        { "gD", vim.lsp.buf.declaration, desc = "Go to Declaration" },
        { "gi", vim.lsp.buf.implementation, desc = "Go to Implementation" },
        { "gr", vim.lsp.buf.references, desc = "Go to References" },
        { "gt", vim.lsp.buf.type_definition, desc = "Go to Type Definition" },

        {
            "<leader>lh",
            function()
                vim.lsp.buf.hover({ border = "rounded" })
            end,
            desc = "Hover Documentation",
        },
        {
            "<leader>lk",
            function()
                vim.lsp.buf.signature_help({ border = "rounded" })
            end,
            desc = "Signature Help",
        },
        { "<leader>la", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "v" } },
        { "<leader>lr", vim.lsp.buf.rename, desc = "Rename Symbol" },
        { "<leader>ls", vim.lsp.buf.document_symbol, desc = "Document Symbols" },
        {
            "<leader>ld",
            function()
                local enabled = vim.diagnostic.is_enabled({ bufnr = bufnr })
                vim.diagnostic.enable(not enabled, { bufnr = bufnr })
            end,
            desc = "Toggle Diagnostics",
        },

        { "<leader>dd", vim.diagnostic.open_float, desc = "Line Diagnostics" },
        { "<leader>dq", vim.diagnostic.setloclist, desc = "Diagnostics List" },
        {
            "[d",
            function()
                vim.diagnostic.jump({ count = -1, float = true })
            end,
            desc = "Previous Diagnostic",
        },
        {
            "]d",
            function()
                vim.diagnostic.jump({ count = 1, float = true })
            end,
            desc = "Next Diagnostic",
        },
        {
            "[e",
            function()
                vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR, float = true })
            end,
            desc = "Previous Error",
        },
        {
            "]e",
            function()
                vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR, float = true })
            end,
            desc = "Next Error",
        },
    }, { noremap = true, silent = true, buffer = bufnr })
end

local function inlay_hints(bufnr)
    wk.add({
        "<leader>li",
        function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
        end,
        desc = "Toggle Inlay Hints",
    }, { noremap = true, silent = true, buffer = bufnr })
end

local function document_highlight(_, bufnr)
    local group = vim.api.nvim_create_augroup("LspDocumentHighlight_" .. bufnr, { clear = true })
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        group = group,
        buffer = bufnr,
        callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = group,
        buffer = bufnr,
        callback = vim.lsp.buf.clear_references,
    })
end

function M.on_attach(client, bufnr)
    keymaps(bufnr)

    if client:supports_method("textDocument/inlayHint", bufnr) then
        inlay_hints(bufnr)
    end

    if client:supports_method("textDocument/documentHighlight") then
        document_highlight(client, bufnr)
    end
end

return M
