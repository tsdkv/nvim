local M = {}

function M.setup()
    vim.diagnostic.config({
        signs            = true,
        underline        = true,
        update_in_insert = false,
        severity_sort    = true,
        virtual_text     = { prefix = '●', spacing = 4 },
        float            = { border = 'rounded', source = true, header = '', prefix = '' },
    })

    vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
        vim.lsp.handlers.hover, { border = 'rounded' }
    )
    vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
        vim.lsp.handlers.signature_help, { border = 'rounded' }
    )

    -- Format on save; async=false so the write waits for the format to complete
    vim.api.nvim_create_autocmd('BufWritePre', {
        group    = vim.api.nvim_create_augroup('LspFormatOnSave', { clear = true }),
        callback = function(ev)
            if #vim.lsp.get_clients({ bufnr = ev.buf }) > 0 then
                vim.lsp.buf.format({ bufnr = ev.buf, async = false })
            end
        end,
    })

    require("mason").setup({})
    require("mason-lspconfig").setup({
        ensure_installed = {
            "lua_ls",
            "gopls",
            "rust_analyzer",
        },
    })

    local keymaps = require("plugins.lsp.keymap")

    vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
            local client = vim.lsp.get_client_by_id(ev.data.client_id)
            if not client then return end

            keymaps.attach(ev.buf)

            if client:supports_method("textDocument/inlayHint", ev.buf) then
                keymaps.attach_inlay_hints(ev.buf)
            end

            if client:supports_method("textDocument/documentHighlight") then
                -- Per-buffer group with clear=true prevents autocmd duplication
                -- if multiple LSP clients attach to the same buffer.
                local group = vim.api.nvim_create_augroup(
                    'LspDocumentHighlight_' .. ev.buf, { clear = true }
                )
                vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                    group    = group,
                    buffer   = ev.buf,
                    callback = vim.lsp.buf.document_highlight,
                })
                vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                    group    = group,
                    buffer   = ev.buf,
                    callback = vim.lsp.buf.clear_references,
                })
            end
        end,
    })
end

return M
