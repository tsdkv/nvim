local gh = require('utils').github

vim.pack.add({
	gh('nordtheme/vim'),
	gh('neovim/nvim-lspconfig'),
	gh('mason-org/mason.nvim'),
	gh('mason-org/mason-lspconfig.nvim'),

	-- neovim lua
	gh('folke/lazydev.nvim'),

	gh('nvim-lua/plenary.nvim'),

	gh('nvim-telescope/telescope.nvim'), -- TODO: consider using snacks.picker
	gh('folke/which-key.nvim'),
	gh('folke/zen-mode.nvim'),

	{ src = gh('nvim-mini/mini.comment'), version = 'stable' },
	{ src = gh('nvim-mini/mini.files'), version = 'stable' },
	{ src = gh('nvim-mini/mini.icons'), version = 'stable' },
	{ src = gh('nvim-mini/mini.bufremove'), version = 'stable' },
	{ src = gh('nvim-mini/mini.completion'), version = 'stable' },
	{ src = gh('nvim-mini/mini.tabline'), version = 'stable' },
	{ src = gh('nvim-mini/mini.statusline'), version = 'stable' },
	{ src = gh('nvim-mini/mini-git'), version = 'stable' },
	{ src = gh('nvim-mini/mini.diff'), version = 'stable' },
    { src = gh('nvim-mini/mini.notify'), version = 'stable' },
	{ src = gh('nvim-mini/mini.pairs'), version = 'stable' },
})

require('lazydev').setup({})

require("plugins.mini")

