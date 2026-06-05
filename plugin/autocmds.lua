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
local last_branch = nil

vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = branch_switch_group,
    callback = function()
        vim.system({ "git", "rev-parse", "--abbrev-ref", "HEAD" }, { text = true }, function(obj)
            if obj.code ~= 0 then
                return
            end
            local branch = vim.trim(obj.stdout)
            vim.schedule(function()
                if last_branch and branch ~= last_branch then
                    for _, client in ipairs(vim.lsp.get_clients()) do
                        client:stop()
                        vim.defer_fn(function()
                            vim.lsp.start(client.config, {
                                reuse_client = function()
                                    return false
                                end,
                            })
                        end, 200)
                    end
                    vim.notify("Branch → " .. branch .. " (LSP restarting)", vim.log.levels.INFO)
                end
                last_branch = branch
            end)
        end)
    end,
})
