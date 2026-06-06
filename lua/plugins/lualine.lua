local M = {}

local function lsp_clients()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients == 0 then
        return "No Active LSP"
    end
    local names = {}
    for _, client in ipairs(clients) do
        table.insert(names, client.name)
    end
    return "  " .. table.concat(names, ", ")
end

M.setup = function()
    local custom_nord = require("lualine.themes.nord")
    local c = require("nord.palette")
    custom_nord.insert.a.bg = c.green
    custom_nord.insert.a.fg = c.nord0

    require("lualine").setup({
        options = {
            theme = custom_nord,
            icons_enabled = true,
            component_separators = { left = "│", right = "│" },
            section_separators = { left = "", right = "" },
            globalstatus = true,
            disabled_filetypes = {
                statusline = { "toggleterm", "telescope" },
            },
        },
        sections = {
            lualine_a = {
                {
                    "mode",
                    fmt = function(str)
                        return str:sub(1, 1)
                    end,
                },
            },
            lualine_b = {

                "branch",
                {
                    "diff",
                    -- symbols = { added = "+", modified = "~", removed = "-" },
                    diff_color = {
                        added = { fg = c.green },
                        modified = { fg = c.orange },
                        removed = { fg = c.error },
                    },
                    cond = function()
                        return vim.fn.winwidth(0) > 60
                    end,
                },
            },
            lualine_c = {
                {
                    "filename",
                    path = 1,
                    symbols = {
                        modified = " ", -- Unsaved changes
                        readonly = " ", -- Readonly file
                        unnamed = "[No Name]",
                        newfile = " 󰎔",
                    },
                    fmt = function(str)
                        if vim.fn.winwidth(0) < 90 then
                            return vim.fn.fnamemodify(str, ":t")
                        end
                        return str
                    end,
                },
            },
            lualine_x = {
                {
                    lsp_clients,
                    color = { fg = c.nord4, gui = "bold" },
                },
                {
                    "diagnostics",
                    symbols = { error = " ", warn = " ", info = " ", hint = "󰌵 " },
                },
            },
            lualine_y = { "searchcount", "progress" },
            lualine_z = { "location" },
        },
        extensions = { "neo-tree", "mason", "quickfix", "trouble" },
    })
end

return M
