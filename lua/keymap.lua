local wk = require("which-key")

wk.add({
	{ '<leader>e', MiniFiles.open, desc = "Toggle explorer", mode = 'n' },
})

wk.add({
    { "<leader>w", "<cmd>w<cr>", desc = "Save File" },
    { "<leader>q", "<cmd>q<cr>", desc = "Quit Neovim" },

	{ "<", "<gv", desc = "Indent Left (Keep Selection)", mode = "v" },
    { ">", ">gv", desc = "Indent Right (Keep Selection)", mode = "v" },
})


local builtin = require('telescope.builtin')
wk.add({
   	{ "<leader>f", group = "Telescope / Find" },
   	{ '<leader>ff', builtin.find_files, desc = "Find files", mode = 'n' },
	{ '<leader>fg', builtin.live_grep,  desc = "Live grep",  mode = 'n' },
  	{ '<leader>fb', builtin.buffers,    desc = "Buffers",    mode = 'n' },
	{ '<leader>f<cr>', builtin.resume, desc = "Last search", mode = 'n' },
})

wk.add({
	{ '<leader>x', function()
		require('mini.bufremove').delete(0, false)
	end, desc = "Remove buffer"},
	{ '<leader>z', function()
		require("zen-mode").toggle({
			window = {
				width = .75 -- width will be 85% of the editor width
			}
		})
	end, desc = "Zen mode"}
})
