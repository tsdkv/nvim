local wk = require("which-key")

local M = {}

local function lsp_keymap(bufnr)
    wk.add({
        { "gd",         vim.lsp.buf.definition,      desc = "Go to Definition"   },
        { "gD",         vim.lsp.buf.declaration,     desc = "Go to Declaration"  },
        { "gi",         vim.lsp.buf.implementation,  desc = "Go to Implementation" },
        { "gr",         vim.lsp.buf.references,      desc = "Go to References"   },
        { "gt",         vim.lsp.buf.type_definition, desc = "Go to Type Definition" },
        { "<C-k>",      vim.lsp.buf.signature_help,  desc = "Signature Help", mode = "i" },

        { "<leader>lh", vim.lsp.buf.hover,           desc = "Hover Documentation" },
        { "<leader>la", vim.lsp.buf.code_action,     desc = "Code Action", mode = { "n", "v" } },
        { "<leader>lr", vim.lsp.buf.rename,          desc = "Rename Symbol"      },
        { "<leader>ls", vim.lsp.buf.document_symbol, desc = "Document Symbols"   },
        {
            "<leader>lf",
            function() vim.lsp.buf.format({ async = true }) end,
            desc = "Format Document",
        },

        { "<leader>dd", vim.diagnostic.open_float, desc = "Line Diagnostics"  },
        { "<leader>dq", vim.diagnostic.setloclist, desc = "Diagnostics List"  },
        {
            "[d",
            function() vim.diagnostic.jump({ count = -1, float = true }) end,
            desc = "Previous Diagnostic",
        },
        {
            "]d",
            function() vim.diagnostic.jump({ count = 1, float = true }) end,
            desc = "Next Diagnostic",
        },
    }, { noremap = true, silent = true, buffer = bufnr })
end

function M.attach(bufnr)
    lsp_keymap(bufnr)
end

function M.attach_inlay_hints(bufnr)
    wk.add({
        "<leader>li",
        function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
        end,
        desc = "Toggle Inlay Hints",
    }, { noremap = true, silent = true, buffer = bufnr })
end

return M
