local function iferr()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local offset = vim.fn.line2byte(row) + col
    local result = vim.fn.systemlist("iferr -pos " .. offset .. " " .. vim.fn.expand("%"))
    if vim.v.shell_error ~= 0 then
        vim.notify("iferr: " .. table.concat(result, "\n"), vim.log.levels.WARN)
        return
    end
    vim.api.nvim_put(result, "l", true, true)
end

-- Generate method stubs using the "impl" tool
local function go_impl()
    local receiver = vim.fn.input("Receiver (e.g. 'r *MyStruct'): ")
    if receiver == "" then
        return
    end
    local interface = vim.fn.input("Interface (e.g. 'io.Reader'): ")
    if interface == "" then
        return
    end

    local cmd = string.format("impl %q %q", receiver, interface)
    local result = vim.fn.systemlist(cmd)
    if vim.v.shell_error ~= 0 then
        vim.notify("impl failed: " .. table.concat(result, "\n"), vim.log.levels.ERROR)
        return
    end
    vim.api.nvim_put(result, "l", true, true)
end

-- Note: add modify tags in future (using gomodifytags CLI)

-- Toggle staticcheck dynamically for gopls in the current session
local function toggle_staticcheck()
    local gopls_client = nil
    for _, client in ipairs(vim.lsp.get_clients({ name = "gopls" })) do
        gopls_client = client
        break
    end
    if not gopls_client then
        vim.notify("gopls client not active", vim.log.levels.WARN)
        return
    end

    ---@type any
    local gopls_settings = gopls_client.config.settings.gopls
    local current = gopls_settings.staticcheck
    local new_val = not current
    gopls_settings.staticcheck = new_val

    -- Notify gopls of the didChangeConfiguration event
    gopls_client:notify("workspace/didChangeConfiguration", {
        settings = gopls_client.config.settings,
    })

    vim.notify("gopls staticcheck: " .. (new_val and "ON" or "OFF"), vim.log.levels.INFO)
end

return {
    name = "gopls",
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    tools = { "gopls", "iferr", "goimports", "gofumpt", "impl" },
    setup = function()
        vim.lsp.config("gopls", {
            cmd = { "gopls" },
            filetypes = { "go", "gomod", "gowork", "gotmpl" },
            root_markers = { "go.work", "go.mod", ".git" },
            settings = {
                gopls = {
                    -- Use gofumpt (stricter, opinionated formatter) instead of standard gofmt.
                    gofumpt = true,
                    -- Enable staticcheck static analysis to find code bugs and optimization issues.
                    staticcheck = true,
                    -- Enable autocomplete for packages that haven't been imported yet.
                    completeUnimported = true,
                    -- Show function parameter placeholders when autocompleting functions.
                    usePlaceholders = true,

                    -- Background diagnostic rules run by gopls
                    analyses = {
                        nilness = true, -- Warn about potential nil pointer dereferences.
                        unusedparams = true, -- Warn about unused function parameters.
                        unusedwrite = true, -- Warn about unused writes (variables written to but never read).
                        unusedvariable = true, -- Warn about unused variables.
                        useany = true, -- Recommend replacing interface{} with any.
                        shadow = true, -- Warn when a variable shadows another variable in an outer scope.
                        fieldalignment = true, -- Suggest struct field reorganization to minimize memory padding.
                    },

                    -- Inlay hints (inline virtual text showing types and parameter names in editor)
                    hints = {
                        assignVariableTypes = true, -- Show inferred types on variable assignment.
                        compositeLiteralFields = true, -- Show struct field names in composite literals.
                        compositeLiteralTypes = true, -- Show types in nested composite literals.
                        constantValues = true, -- Show underlying values of constants (e.g. iota values).
                        functionTypeParameters = true, -- Show type parameters on generic function calls.
                        parameterNames = true, -- Show parameter names in function call arguments.
                        rangeVariableTypes = true, -- Show types of variables defined in range loops.
                    },

                    -- Directory filters (optional): ignore folders you don't want gopls to index (saves CPU/memory)
                    -- directoryFilters = { "-**/node_modules", "-**/.git", "-**/.venv" },

                    -- Background vulnerability scanning (shows alerts for vulnerable packages in your imports)
                    -- vulncheck = "Imports",
                },
            },
        })
        vim.lsp.enable("gopls")
    end,
    on_attach = function(_, bufnr)
        local wk = require("which-key")
        wk.add({
            { "<leader>lI", iferr, desc = "iferr: generate error block" },
            { "<leader>lg", group = "Go Tools" },
            { "<leader>lgi", go_impl, desc = "Generate interface stubs (impl)" },
            { "<leader>lgs", toggle_staticcheck, desc = "Toggle staticcheck" },
        }, { buffer = bufnr })
    end,
}
