local M = {}

function M.setup()
    local neoscroll = require("neoscroll")
    neoscroll.setup({
        cursor_scrolls_alone = false, -- The cursor will keep on scrolling even if the window cannot scroll further
        stop_eof = false,
    })

    -- Map PageUp and PageDown to neoscroll smooth scroll
    vim.keymap.set({ "n", "v", "x" }, "<PageDown>", function()
        neoscroll.scroll(20, { move_cursor = true, duration = 200 })
    end, { desc = "Scroll Down (Page)" })
    vim.keymap.set({ "n", "v", "x" }, "<PageUp>", function()
        neoscroll.scroll(-20, { move_cursor = true, duration = 200 })
    end, { desc = "Scroll Up (Page)" })
end

return M
