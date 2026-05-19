require('mini.icons').setup()
require('mini.files').setup()
require('mini.bufremove').setup()
require('mini.completion').setup({})
require('mini.git').setup()
require('mini.pairs').setup()
require('mini.diff').setup()

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
				'%<', -- truncate point
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
		enable = true,
		level = 'INFO',
		duration_last = 1000,
	},
})
vim.notify = require('mini.notify').make_notify()

require('mini.tabline').setup({
	show_icons = true,
	tabpage_section = 'left',
	format = function(buf_id, label)
		local prefix = vim.bo[buf_id].modified and '󰏫' or ''
		return prefix .. MiniTabline.default_format(buf_id, label)
	end,
})

require("mini.comment").setup({
	options = {
		ignore_blank_line = true,
	},
	mappings = {
		comment_line = '<leader>/',
		comment_visual = '<leader>/',
		textobject = '<leader>/',
	},
})
