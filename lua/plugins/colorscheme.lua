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

            -- Diffview
            hl.DiffviewDim1 = { link = "Comment" }
            hl.DiffviewPrimary = { fg = c.keyword }
            hl.DiffviewSecondary = { fg = c.green }
            hl.DiffviewNormal = { fg = c.fg, bg = c.bg }
            hl.DiffviewWinSeparator = { fg = c.bg, bg = c.bg }
            hl.DiffviewFilePanelTitle = { fg = c.keyword, bold = true }
            hl.DiffviewFilePanelCounter = { fg = c.fg }
            hl.DiffviewFilePanelRootPath = { fg = c.purple, bold = true }
            hl.DiffviewFilePanelFileName = { fg = c.fg }
            hl.DiffviewFilePanelSelected = { fg = c.yellow }
            hl.DiffviewFilePanelPath = { link = "Comment" }
            hl.DiffviewFilePanelInsertions = { fg = c.green, bg = c.none }
            hl.DiffviewFilePanelDeletions = { fg = c.error, bg = c.none }
            hl.DiffviewFilePanelConflicts = { fg = c.yellow, bg = c.none }
            hl.DiffviewFolderName = { fg = c.keyword, bold = true }
            hl.DiffviewFolderSign = { fg = c.keyword }
            hl.DiffviewHash = { fg = c.orange }
            hl.DiffviewReference = { fg = c.keyword, bold = true }
            hl.DiffviewReflogSelector = { fg = c.purple }
            hl.DiffviewStatusAdded = { fg = c.green, bg = c.none }
            hl.DiffviewStatusUntracked = { fg = c.green, bg = c.none }
            hl.DiffviewStatusModified = { fg = c.yellow, bg = c.none }
            hl.DiffviewStatusRenamed = { fg = c.yellow, bg = c.none }
            hl.DiffviewStatusCopied = { fg = c.yellow, bg = c.none }
            hl.DiffviewStatusTypeChange = { fg = c.yellow, bg = c.none }
            hl.DiffviewStatusUnmerged = { fg = c.yellow, bg = c.none }
            hl.DiffviewStatusUnknown = { fg = c.error, bg = c.none }
            hl.DiffviewStatusDeleted = { fg = c.error, bg = c.none }
            hl.DiffviewStatusBroken = { fg = c.error, bg = c.none }
            hl.DiffviewStatusIgnored = { fg = c.comment, bg = c.none }
        end,
    })

    vim.cmd.colorscheme("nord")
end

return M
