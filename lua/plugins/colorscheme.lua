local M = {}

function M.setup()
    vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
            vim.api.nvim_set_hl(0, "LspInlayHint", { fg = "#616E88", bg = "NONE", italic = true })
            vim.api.nvim_set_hl(0, "NormalFloat", { fg = "#D8DEE9", bg = "#3b4252" })
            vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#4c566a", bg = "#3b4252" })
            vim.api.nvim_set_hl(0, "Pmenu", { fg = "#D8DEE9", bg = "#3b4252" })
            vim.api.nvim_set_hl(0, "PmenuSel", { fg = "#E5E9F0", bg = "#4c566a" })

            -- Underline LSP references: white for reads, bold orange for writes
            vim.api.nvim_set_hl(0, "LspReferenceText", { bg = "NONE", underline = true, sp = "#FFFFFF" })
            vim.api.nvim_set_hl(0, "LspReferenceRead", { bg = "NONE", underline = true, sp = "#FFFFFF" })
            vim.api.nvim_set_hl(0, "LspReferenceWrite", { bg = "NONE", underline = true, sp = "#D08770", bold = true })

            vim.api.nvim_set_hl(0, "MiniNotifyNormal", { fg = "#D8DEE9", bg = "#2e3440" })
            vim.api.nvim_set_hl(0, "MiniNotifyBorder", { fg = "#3B4252", bg = "#2e3440" })

            vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#d8dee9", bold = true })
            vim.api.nvim_set_hl(0, "CursorLine", { bg = "#3b4252" })

            -- NeoTree
            local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
            local panel_bg = vim.api.nvim_get_hl(0, { name = "NeoTreeNormal" }).bg
                or vim.api.nvim_get_hl(0, { name = "NormalFloat" }).bg

            vim.api.nvim_set_hl(0, "NeoTreeTabActive", { bg = panel_bg, fg = "#ffffff", bold = true })
            vim.api.nvim_set_hl(0, "NeoTreeTabInactive", {
                bg = normal_bg,
                fg = vim.api.nvim_get_hl(0, { name = "Comment" }).fg,
            })
            vim.api.nvim_set_hl(0, "NeoTreeTabSeparatorActive", { bg = panel_bg, fg = panel_bg })
            vim.api.nvim_set_hl(0, "NeoTreeTabSeparatorInactive", { bg = normal_bg, fg = normal_bg })
            vim.api.nvim_set_hl(0, "NeoTreeWinSeparator", { link = "WinSeparator" })

            -- bookmarks
            vim.api.nvim_set_hl(0, "BookMarksAdd", { fg = "#88c0d0", bg = "NONE", default = false })
            vim.api.nvim_set_hl(0, "BookMarksAnn", { fg = "#88c0d0", bg = "NONE", default = false })
        end,
    })

    vim.cmd.colorscheme("nord")
end

return M
