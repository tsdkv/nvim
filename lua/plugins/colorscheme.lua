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

            vim.api.nvim_set_hl(0, "MiniStatuslineModeNormal", { fg = "#2E3440", bg = "#81A1C1", bold = true })
            vim.api.nvim_set_hl(0, "MiniStatuslineModeInsert", { fg = "#2E3440", bg = "#A3BE8C", bold = true })
            vim.api.nvim_set_hl(0, "MiniStatuslineModeVisual", { fg = "#2E3440", bg = "#B48EAD", bold = true })
            vim.api.nvim_set_hl(0, "MiniStatuslineModeReplace", { fg = "#2E3440", bg = "#BF616A", bold = true })
            vim.api.nvim_set_hl(0, "MiniStatuslineModeCommand", { fg = "#2E3440", bg = "#EBCB8B", bold = true })
            vim.api.nvim_set_hl(0, "MiniStatuslineModeOther", { fg = "#2E3440", bg = "#8FBCBB", bold = true })
            vim.api.nvim_set_hl(0, "MiniStatuslineDevinfo", { fg = "#E5E9F0", bg = "#3B4252" })
            vim.api.nvim_set_hl(0, "MiniStatuslineFilename", { fg = "#D8DEE9", bg = "#3B4252" })
            vim.api.nvim_set_hl(0, "MiniStatuslineFileinfo", { fg = "#E5E9F0", bg = "#434C5E" })
            vim.api.nvim_set_hl(0, "MiniStatuslineInactive", { fg = "#4C566A", bg = "#2E3440" })

            -- NeoTree
            local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
            local panel_bg  = vim.api.nvim_get_hl(0, { name = "NeoTreeNormal" }).bg or
                vim.api.nvim_get_hl(0, { name = "NormalFloat" }).bg

            vim.api.nvim_set_hl(0, "NeoTreeTabActive", { bg = panel_bg, fg = "#ffffff", bold = true })
            vim.api.nvim_set_hl(0, "NeoTreeTabInactive",
                { bg = normal_bg, fg = vim.api.nvim_get_hl(0, { name = "Comment" }).fg })

            vim.api.nvim_set_hl(0, "NeoTreeTabSeparatorActive", { bg = panel_bg, fg = panel_bg })
            vim.api.nvim_set_hl(0, "NeoTreeTabSeparatorInactive", { bg = normal_bg, fg = normal_bg })

            vim.api.nvim_set_hl(0, "NeoTreeWinSeparator", { link = "WinSeparator" })

            -- bookmarks
            vim.api.nvim_set_hl(0, "BookMarksAdd", { fg = '#88c0d0', bg = "NONE", default = false })
            vim.api.nvim_set_hl(0, "BookMarksAnn", { fg = '#88c0d0', bg = "NONE", default = false })

            --mini.jump2d TODO
            -- Обычные точки прыжка: белый текст на бирюзовом фоне (Nord Frost)
            vim.api.nvim_set_hl(0, 'MiniJump2dSpot', { fg = '#ECEFF4', bg = '#8FBCBB', bold = true })
            -- Уникальные точки (в один клик): белый текст на зеленом фоне (Nord Aurora Green)
            vim.api.nvim_set_hl(0, 'MiniJump2dSpotUnique', { fg = '#ECEFF4', bg = '#A3BE8C', bold = true })
            -- Дальние точки прыжка: просто синеватый текст без фона (Nord Frost Deep)
            vim.api.nvim_set_hl(0, 'MiniJump2dSpotAhead', { fg = '#81A1C1', bg = 'NONE' })
            -- Приглушение остального кода: уводим в мягкий серый (Nord Polar Night)
            vim.api.nvim_set_hl(0, 'MiniJump2dDim', { fg = '#4C566A', nocombine = true })
        end,
    })

    vim.cmd.colorscheme("nord")
end

return M
