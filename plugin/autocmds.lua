local restart_lsp = require("core.utils").restart_lsp

-- Yank highlight
vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
    callback = function()
        vim.hl.on_yank()
    end,
})

-- Restore cursor to last known position when reopening a file
vim.api.nvim_create_autocmd("BufReadPost", {
    group = vim.api.nvim_create_augroup("RestoreCursor", { clear = true }),
    callback = function(ev)
        local exclude = { "gitcommit", "gitrebase" }
        if vim.tbl_contains(exclude, vim.bo[ev.buf].filetype) then
            return
        end
        local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
        if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(ev.buf) then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- Reload buffers changed on disk when nvim regains focus
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = vim.api.nvim_create_augroup("CheckTime", { clear = true }),
    command = "checktime",
})

-- Equalize splits when the terminal window is resized
vim.api.nvim_create_autocmd("VimResized", {
    group = vim.api.nvim_create_augroup("ResizeWindows", { clear = true }),
    command = "wincmd =",
})

-- Close utility/readonly windows with just q
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("CloseWithQ", { clear = true }),
    pattern = { "help", "qf", "man", "notify", "lspinfo", "startuptime", "checkhealth", "loadtrace" },
    callback = function(ev)
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true })
    end,
})

-- Prevent Neovim from automatically inserting comment leaders on new lines
vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("DisableAutoComment", { clear = true }),
    callback = function()
        vim.opt.formatoptions:remove({ "c", "r", "o" })
    end,
})

-- Detect git branch switches and gracefully restart LSP
local branch_switch_group = vim.api.nvim_create_augroup("BranchSwitchLSP", { clear = true })
-- Per-cwd state: avoids spawning git on every focus event in non-repo
-- directories, and prevents false "branch switch" detections when moving
-- between windows of two different projects.
local repo_cache = {} ---@type table<string, boolean>
local last_branch = {} ---@type table<string, string>

vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = branch_switch_group,
    callback = function()
        if vim.bo.buftype ~= "" then
            return
        end
        local cwd = vim.fn.getcwd()
        if repo_cache[cwd] == false then
            return
        end
        vim.system({ "git", "rev-parse", "--abbrev-ref", "HEAD" }, { text = true }, function(obj)
            if obj.code ~= 0 then
                -- Not a repo (or git missing): stop retrying for this cwd
                repo_cache[cwd] = false
                return
            end
            repo_cache[cwd] = true
            local branch = vim.trim(obj.stdout)
            vim.schedule(function()
                if last_branch[cwd] and branch ~= last_branch[cwd] then
                    restart_lsp(vim.lsp.get_clients(), {
                        message = "Branch → " .. branch .. " (LSP restarting)",
                    })
                end
                last_branch[cwd] = branch
            end)
        end)
    end,
})
