local M = {}

-- Nord palette — single source of truth for all overrides
local p = {
    origin  = "#2e3440", -- nord0
    polar1  = "#3b4252", -- nord1
    polar3  = "#4c566a", -- nord3
    comment = "#616E88", -- dimmed nord3
    snow0   = "#d8dee9", -- nord4
    snow1   = "#e5e9f0", -- nord5
    white   = "#ffffff",
    red     = "#bf616a", -- nord11
    orange  = "#d08770", -- nord12
    green   = "#a3be8c", -- nord14
    teal    = "#8fbcbb", -- nord7
    frost   = "#88c0d0", -- nord8
}

local hl = function(name, opts)
    vim.api.nvim_set_hl(0, name, opts)
end

function M.setup()
    vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("CustomColorscheme", { clear = true }),
        callback = function()
            hl("LspInlayHint", { fg = p.comment, bg = "NONE", italic = true })
            hl("NormalFloat", { fg = p.snow0, bg = p.polar1 })
            hl("FloatBorder", { fg = p.polar3, bg = p.polar1 })
            hl("Pmenu", { fg = p.snow0, bg = p.polar1 })
            hl("PmenuSel", { fg = p.snow1, bg = p.polar3 })

            -- Underline LSP references: white for reads, bold orange for writes
            hl("LspReferenceText", { bg = "NONE", underline = true, sp = p.white })
            hl("LspReferenceRead", { bg = "NONE", underline = true, sp = p.white })
            hl("LspReferenceWrite", { bg = "NONE", underline = true, sp = p.orange, bold = true })

            hl("MiniNotifyNormal", { fg = p.snow0, bg = p.origin })
            hl("MiniNotifyBorder", { fg = p.polar1, bg = p.origin })

            hl("CursorLineNr", { fg = p.snow0, bold = true })
            hl("CursorLine", { bg = p.polar1 })

            -- NeoTree
            local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
            local panel_bg = vim.api.nvim_get_hl(0, { name = "NeoTreeNormal" }).bg
                or vim.api.nvim_get_hl(0, { name = "NormalFloat" }).bg

            hl("NeoTreeTabActive", { bg = panel_bg, fg = p.white, bold = true })
            hl("NeoTreeTabInactive", {
                bg = normal_bg,
                fg = vim.api.nvim_get_hl(0, { name = "Comment" }).fg,
            })
            hl("NeoTreeTabSeparatorActive", { bg = panel_bg, fg = panel_bg })
            hl("NeoTreeTabSeparatorInactive", { bg = normal_bg, fg = normal_bg })
            hl("NeoTreeWinSeparator", { link = "WinSeparator" })

            -- Bookmarks
            hl("BookMarksAdd", { fg = p.frost, bg = "NONE", default = false })
            hl("BookMarksAnn", { fg = p.frost, bg = "NONE", default = false })
        end,
    })

    vim.cmd.colorscheme("nord")
end

return M
