-- gopls LSP commands invoked from keymaps.

local M = {}

-- Switch the attached workspace between full and disabled Staticcheck.
function M.toggle_staticcheck()
    local gopls_client = vim.lsp.get_clients({ name = "gopls", bufnr = 0 })[1]
    if not gopls_client then
        vim.notify("gopls not attached to this buffer", vim.log.levels.WARN)
        return
    end

    ---@type any
    local gopls_settings = gopls_client.settings.gopls
    local new_val = not gopls_settings.staticcheck
    gopls_settings.staticcheck = new_val

    -- Notify gopls of the didChangeConfiguration event
    gopls_client:notify("workspace/didChangeConfiguration", {
        settings = gopls_client.settings,
    })

    vim.notify("gopls staticcheck: " .. (new_val and "ON" or "OFF"), vim.log.levels.INFO)
end

-- Toggle compiler optimization details (inline/escape analysis annotations)
-- for the current package. Sent again, the command turns them off.
function M.gc_details()
    local client = vim.lsp.get_clients({ name = "gopls", bufnr = 0 })[1]
    if not client then
        vim.notify("gopls not attached to this buffer", vim.log.levels.WARN)
        return
    end
    client:exec_cmd({
        title = "Toggle GC details",
        command = "gopls.gc_details",
        arguments = { vim.uri_from_bufnr(0) },
    }, { bufnr = 0 })
end

return M
