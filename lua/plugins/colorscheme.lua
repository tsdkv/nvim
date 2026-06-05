local M = {}

function M.setup()
    require("nord").setup({
        on_highlights = function(hl, c)
            -- NeoTree (Link to native groups to save space)
            hl.NeoTreeNormal = { link = "Normal" }
            hl.NeoTreeNormalNC = { link = "NormalNC" }
            hl.NeoTreeTabActive = { bg = c.nord0, fg = c.nord6, bold = true }
            hl.NeoTreeTabInactive = { bg = c.nord1, fg = c.nord3_bright }
            hl.NeoTreeTabSeparatorActive = { fg = c.nord0, bg = c.nord0 }
            hl.NeoTreeTabSeparatorInactive = { fg = c.nord1, bg = c.nord1 }
            hl.NeoTreeWinSeparator = { link = "WinSeparator" }

            -- LSP (Fixed to use c.orange for Write)
            hl.LspInlayHint = { fg = c.comment, bg = c.none }
            hl.LspReferenceText = { bg = c.none, underline = true, sp = c.nord6 }
            hl.LspReferenceRead = { bg = c.none, underline = true, sp = c.nord6 }
            hl.LspReferenceWrite = { bg = c.none, underline = true, sp = c.orange, bold = true }

            -- Mini Notify
            hl.MiniNotifyNormal = { link = "Normal" }
            hl.MiniNotifyBorder = { fg = c.nord1, bg = c.nord0 }

            -- Bookmarks
            hl.BookMarksAdd = { fg = c.frost, bg = c.none }
            hl.BookMarksAnn = { fg = c.frost, bg = c.none }
        end,
    })

    vim.cmd.colorscheme("nord")
end

return M
