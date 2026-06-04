local M = {}

function M.setup()
    require("nord").setup({
        on_highlights = function(hl, c)
            -- Editor
            hl.WinSeparator = { fg = c.fg, bg = c.bg }
            hl.VertSplit = { fg = c.fg, bg = c.bg }

            -- NeoTree
            hl.NeoTreeNormal = { fg = c.fg, bg = c.bg }
            hl.NeoTreeNormalNC = { fg = c.fg, bg = c.bg }
            hl.NeoTreeTabActive = { bg = c.bg, fg = c.nord6, bold = true }
            hl.NeoTreeTabInactive = { bg = c.bg_dim, fg = c.comment }
            hl.NeoTreeTabSeparatorActive = { bg = c.bg, fg = c.bg }
            hl.NeoTreeTabSeparatorInactive = { bg = c.bg_dim, fg = c.bg_dim }
            hl.NeoTreeWinSeparator = { link = "WinSeparator" }

            -- LSP
            hl.LspInlayHint = { fg = c.comment, bg = c.none, italic = true }
            hl.LspReferenceText = { bg = c.none, underline = true, sp = c.nord6 }
            hl.LspReferenceRead = { bg = c.none, underline = true, sp = c.nord6 }
            hl.LspReferenceWrite = { bg = c.none, underline = true, sp = c.warn, bold = true }

            -- Mini Notify
            hl.MiniNotifyNormal = { fg = c.fg, bg = c.bg }
            hl.MiniNotifyBorder = { fg = c.bg_dim, bg = c.bg }

            -- Bookmarks
            hl.BookMarksAdd = { fg = c.frost, bg = c.none }
            hl.BookMarksAnn = { fg = c.frost, bg = c.none }
        end,
    })

    vim.cmd.colorscheme("nord")
end

return M
