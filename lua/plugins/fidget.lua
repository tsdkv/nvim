local M = {}

M.setup = function()
    require("fidget").setup({
        progress = {
            suppress_on_insert = true,
            ignore_done_already = true,
            display = {
                render_limit = 16,
                done_ttl = 3,
            },
        },
        notification = {
            window = {
                winblend = 0,
            },
        },
    })
end

return M
