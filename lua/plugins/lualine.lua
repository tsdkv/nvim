local M = {}

M.setup = function()
    local lualine = require("lualine")
    local c = require("nord.palette")

    local colors = {
        bg = c.nord2,
        fg = c.nord6,
        text = c.nord4,
        yellow = c.yellow,
        cyan = c.nord8,
        darkblue = c.nord1,
        green = c.green,
        orange = c.orange,
        violet = c.purple,
        blue = c.nord9,
        red = c.error,
    }

    local mode_color = {
        n = colors.blue,
        i = colors.green,
        v = colors.violet,
        ["\22"] = colors.violet,
        V = colors.violet,
        c = colors.yellow,
        no = colors.red,
        s = colors.orange,
        S = colors.orange,
        ["\19"] = colors.orange,
        ic = colors.yellow,
        R = colors.violet,
        Rv = colors.violet,
        cv = colors.red,
        ce = colors.red,
        r = colors.cyan,
        rm = colors.cyan,
        ["r?"] = colors.cyan,
        ["!"] = colors.red,
        t = colors.red,
    }

    local conditions = {
        buffer_not_empty = function()
            return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
        end,
        hide_in_width = function()
            return vim.fn.winwidth(0) > 80
        end,
    }

    local config = {
        options = {
            component_separators = "",
            section_separators = "",
            theme = {
                normal = { c = { fg = colors.fg, bg = colors.bg } },
                inactive = { c = { fg = c.nord4, bg = c.nord1 } },
            },
            globalstatus = true,
            disabled_filetypes = {
                statusline = { "toggleterm", "telescope" },
            },
        },
        sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_y = {},
            lualine_z = {},
            lualine_c = {},
            lualine_x = {},
        },
        inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_y = {},
            lualine_z = {},
            lualine_c = {},
            lualine_x = {},
        },
        extensions = { "neo-tree", "mason", "quickfix", "trouble" },
    }

    local function ins_left(component)
        table.insert(config.sections.lualine_c, component)
    end

    local function ins_right(component)
        table.insert(config.sections.lualine_x, component)
    end

    ins_left({
        function()
            return string.upper(vim.api.nvim_get_mode().mode:sub(1, 1))
        end,
        color = function()
            return { fg = c.nord1, bg = mode_color[vim.api.nvim_get_mode().mode] or colors.blue, gui = "bold" }
        end,
        separator = { right = "" },
        padding = { left = 0, right = 0 },
    })

    ins_left({
        "filename",
        cond = conditions.buffer_not_empty,
        color = { fg = colors.fg, gui = "bold" },
        symbols = {
            modified = "", -- 
            readonly = "", -- 
            unnamed = "[No Name]",
            newfile = " [New]",
        },
    })

    ins_left({ "location" })

    ins_left({ "progress", color = { fg = colors.fg, gui = "bold" } })

    ins_left({
        "diagnostics",
        sources = { "nvim_diagnostic" },
        symbols = { error = " ", warn = " ", info = " " },
        diagnostics_color = {
            error = { fg = colors.red },
            warn = { fg = colors.yellow },
            info = { fg = colors.cyan },
        },
    })

    ins_left({
        function()
            return "%="
        end,
    })

    ins_left({
        function()
            local clients = vim.lsp.get_clients({ bufnr = 0 })
            if #clients == 0 then
                return " No Active LSP"
            end
            local names = vim.tbl_map(function(cl)
                return cl.name
            end, clients)
            return " " .. table.concat(names, ", ")
        end,
        color = { fg = colors.text, gui = "bold" },
    })

    ins_right({
        "fileformat",
        fmt = string.upper,
        icons_enabled = true,
        color = { fg = colors.green, gui = "bold" },
    })

    ins_right({
        "branch",
        icon = "",
        color = { fg = colors.blue, gui = "bold" },
    })

    ins_right({
        "diff",
        symbols = { added = " ", modified = "󰏫 ", removed = " " },
        diff_color = {
            added = { fg = colors.green },
            modified = { fg = colors.orange },
            removed = { fg = colors.red },
        },
        cond = conditions.hide_in_width,
    })

    lualine.setup(config)
end

return M
