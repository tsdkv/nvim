-- gopls settings. Returned by a function (not a plain table) because the
-- "local" import group depends on the buffer active at setup time.

local util = require("plugins.lsp.servers.go.util")

local M = {}

function M.get()
    return {
        gopls = {
            -- Use gofumpt (stricter, opinionated formatter) instead of standard gofmt.
            gofumpt = true,
            -- Enable staticcheck static analysis to find code bugs and optimization issues.
            staticcheck = true,
            -- Enable autocomplete for packages that haven't been imported yet.
            completeUnimported = true,
            -- Show function parameter placeholders when autocompleting functions.
            usePlaceholders = true,
            -- Treesitter already highlights Go; gopls semantic tokens are a
            -- redundant full-file LSP round-trip on every edit.
            semanticTokens = false,
            -- Recompute diagnostics only when saving a file instead of
            -- continuously while typing (biggest gopls CPU win,
            -- especially during branch switches).
            diagnosticsTrigger = "Save",

            -- Editor-side codelens support is removed; pin every lens
            -- off explicitly instead of relying on gopls defaults.
            codelenses = {
                generate = false,
                regenerate_cgo = false,
                test = false,
                tidy = false,
                upgrade_dependency = false,
                vendor = false,
                gc_details = false, -- the lens; the <leader>lgc command is unaffected
                run_govulncheck = false,
            },

            -- Background diagnostic rules run by gopls
            analyses = {
                nilness = true, -- Warn about potential nil pointer dereferences.
                unusedparams = true, -- Warn about unused function parameters.
                unusedwrite = true, -- Warn about unused writes (variables written to but never read).
                unusedvariable = true, -- Warn about unused variables.
                useany = true, -- Recommend replacing interface{} with any.
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

            -- Don't index/watch these folders (saves CPU and memory).
            directoryFilters = { "-**/node_modules", "-**/.git", "-**/.venv" },

            -- Group this module's imports after third-party ones.
            ["local"] = util.module_path() or "",
        },
    }
end

return M
