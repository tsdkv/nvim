local term_state = {
    buf = nil,
    win = nil,
}

local function ensure_terminal_window()
    if term_state.win and vim.api.nvim_win_is_valid(term_state.win) then
        return
    end

    -- Open horizontal split at the bottom with 15 rows
    vim.cmd("botright 15split")
    term_state.win = vim.api.nvim_get_current_win()

    -- Create or reuse terminal buffer
    if not term_state.buf or not vim.api.nvim_buf_is_valid(term_state.buf) then
        -- Start terminal process
        vim.cmd("terminal")
        term_state.buf = vim.api.nvim_get_current_buf()

        -- Clean terminal buffer aesthetics
        vim.bo[term_state.buf].buflisted = false
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.signcolumn = "no"
        vim.opt_local.foldcolumn = "0"
    else
        -- Reuse the existing terminal buffer
        vim.api.nvim_win_set_buf(term_state.win, term_state.buf)
    end
end

local function toggle_horizontal_terminal()
    -- If the terminal window exists and is valid, close/hide it
    if term_state.win and vim.api.nvim_win_is_valid(term_state.win) then
        vim.api.nvim_win_close(term_state.win, true)
        term_state.win = nil
        return
    end

    ensure_terminal_window()
    vim.cmd("startinsert")
end

local function open_or_focus_terminal()
    ensure_terminal_window()
    vim.api.nvim_set_current_win(term_state.win)
    vim.cmd("startinsert")
end

-- Keymaps to toggle or open/focus from normal or terminal mode
vim.keymap.set({ "n", "t" }, "<leader>th", toggle_horizontal_terminal, { desc = "Toggle Horizontal Terminal" })
vim.keymap.set({ "n", "t" }, "<leader>to", open_or_focus_terminal, { desc = "Open/Focus Terminal" })

-- User commands to control the terminal
vim.api.nvim_create_user_command("TerminalToggle", toggle_horizontal_terminal, { desc = "Toggle Horizontal Terminal" })
vim.api.nvim_create_user_command("TerminalOpen", open_or_focus_terminal, { desc = "Open/Focus Terminal" })

-- Exit terminal mode to normal mode to allow scrollback/motions
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Direct window focus switching from terminal mode
vim.keymap.set("t", "<C-h>", "<Cmd>wincmd h<CR>", { desc = "Move focus left" })
vim.keymap.set("t", "<C-j>", "<Cmd>wincmd j<CR>", { desc = "Move focus down" })
vim.keymap.set("t", "<C-k>", "<Cmd>wincmd k<CR>", { desc = "Move focus up" })
vim.keymap.set("t", "<C-l>", "<Cmd>wincmd l<CR>", { desc = "Move focus right" })

local term_group = vim.api.nvim_create_augroup("TerminalErgonomics", { clear = true })

-- Auto-enter insert mode when entering/focusing a terminal window
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
    group = term_group,
    pattern = "term://*",
    callback = function()
        vim.cmd("startinsert")
    end,
})

-- Auto-close terminal split when shell process exits
vim.api.nvim_create_autocmd("TermClose", {
    group = term_group,
    pattern = "term://*",
    callback = function(ev)
        if vim.api.nvim_buf_is_valid(ev.buf) then
            vim.api.nvim_buf_delete(ev.buf, { force = true })
            if term_state.win and vim.api.nvim_win_is_valid(term_state.win) then
                term_state.win = nil
            end
        end
    end,
})

-- Disable terminal escapes and window focus switching inside lazygit
vim.api.nvim_create_autocmd("FileType", {
    group = term_group,
    pattern = "lazygit",
    callback = function(args)
        vim.keymap.set("t", "<Esc>", "<Esc>", { buffer = args.buf, nowait = true })
        vim.keymap.set("t", "<Esc><Esc>", "<Esc><Esc>", { buffer = args.buf, nowait = true })
        vim.keymap.set("t", "<C-h>", "<C-h>", { buffer = args.buf })
        vim.keymap.set("t", "<C-j>", "<C-j>", { buffer = args.buf })
        vim.keymap.set("t", "<C-k>", "<C-k>", { buffer = args.buf })
        vim.keymap.set("t", "<C-l>", "<C-l>", { buffer = args.buf })
    end,
})
