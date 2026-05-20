local M = {}

function M.setup()
    require('mini.bufremove').setup()
    require('mini.completion').setup({})
    require('mini.pairs').setup()

    -- TODO: remove this plugin
    local statusline = require('mini.statusline')
    require('mini.statusline').setup({
        use_icons = true,

        content = {
            active = function()
                local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })
                local git           = statusline.section_git({ trunc_width = 40 })
                local diff          = statusline.section_diff({ trunc_width = 75 })
                local diagnostics   = statusline.section_diagnostics({ trunc_width = 75 })
                local filename      = statusline.section_filename({ trunc_width = 140 })
                local fileinfo      = statusline.section_fileinfo({ trunc_width = 120 })
                local location      = statusline.section_location({ trunc_width = 75 })
                local search        = statusline.section_searchcount({ trunc_width = 75 })

                local lsp_names     = ""
                if not statusline.is_truncated(75) then
                    local clients = vim.lsp.get_clients({ bufnr = 0 })
                    if #clients > 0 then
                        local names = {}
                        for _, client in ipairs(clients) do
                            table.insert(names, client.name)
                        end
                        lsp_names = "󰒋 [" .. table.concat(names, ", ") .. "]  "
                    end
                end

                return statusline.combine_groups({
                    { hl = mode_hl,                 strings = { mode } },
                    { hl = 'MiniStatuslineDevinfo', strings = { git, diff, diagnostics } },
                    '%<',
                    { hl = 'MiniStatuslineFilename', strings = { filename } },
                    '%=',
                    { hl = 'MiniStatuslineFileinfo', strings = { lsp_names, fileinfo } },
                    { hl = mode_hl,                  strings = { search, location } },
                })
            end,
        },
    })

    require('mini.notify').setup({
        window = {
            config = { border = 'rounded' },
        },
        lsp_progress = {
            enable        = true,
            level         = 'INFO',
            duration_last = 1000,
        },
    })
    vim.notify = require('mini.notify').make_notify()

    require('mini.tabline').setup({
        show_icons      = true,
        tabpage_section = 'left',
        format          = function(buf_id, label)
            local prefix = vim.bo[buf_id].modified and '󰏫' or ''
            return prefix .. MiniTabline.default_format(buf_id, label)
        end,
    })

    require('mini.comment').setup({
        options = {
            ignore_blank_line = true,
        },
        mappings = {
            comment_line   = '<leader>/',
            comment_visual = '<leader>/',
            textobject     = '<leader>/',
        },
    })

    -- Close buffers relative to current by buffer number (matches tabline order)
    local function close_bufs(predicate)
        local cur = vim.api.nvim_get_current_buf()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.bo[buf].buflisted and buf ~= cur and predicate(buf, cur) then
                require('mini.bufremove').delete(buf, false)
            end
        end
    end

    require('which-key').add({

        { '<leader>x',  function() require('mini.bufremove').delete(0, false) end,      desc = 'Delete Buffer' },
        { '<leader>bo', function() close_bufs(function() return true end) end,          desc = 'Close Other Buffers' },
        { '<leader>bl', function() close_bufs(function(b, cur) return b < cur end) end, desc = 'Close Buffers Left' },
        { '<leader>br', function() close_bufs(function(b, cur) return b > cur end) end, desc = 'Close Buffers Right' },
    })
end

return M
