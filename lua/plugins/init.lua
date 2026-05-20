local gh  = require('utils').github
local lib = require('lib')

vim.pack.add({
    gh('nordtheme/vim'),
    gh('neovim/nvim-lspconfig'),
    gh('mason-org/mason.nvim'),
    gh('mason-org/mason-lspconfig.nvim'),
    gh('folke/lazydev.nvim'),
    gh('nvim-lua/plenary.nvim'),
    gh('nvim-telescope/telescope.nvim'),
    gh('folke/which-key.nvim'),
    gh('folke/zen-mode.nvim'),
    { src = gh('nvim-mini/mini.comment'),    version = 'stable' },
    { src = gh('nvim-mini/mini.files'),      version = 'stable' },
    { src = gh('nvim-mini/mini.icons'),      version = 'stable' },
    { src = gh('nvim-mini/mini.bufremove'),  version = 'stable' },
    { src = gh('nvim-mini/mini.completion'), version = 'stable' },
    { src = gh('nvim-mini/mini.tabline'),    version = 'stable' },
    { src = gh('nvim-mini/mini.statusline'), version = 'stable' },
    { src = gh('nvim-mini/mini-git'),        version = 'stable' },
    { src = gh('nvim-mini/mini.diff'),       version = 'stable' },
    { src = gh('nvim-mini/mini.notify'),     version = 'stable' },
    { src = gh('nvim-mini/mini.pairs'),      version = 'stable' },
})

-- Eager: must exist before any other plugin file registers keymaps or colors
lib.now('plugins.colorscheme')
lib.now('plugins.which-key')

-- Deferred: one per event-loop tick to keep startup responsive
lib.later('plugins.mini')

-- Filetype-driven
lib.on_filetype('lua', 'plugins.lazydev')

-- Event-driven: LSP attaches on first file open
lib.on_event({ 'BufReadPre', 'BufNewFile' }, 'plugins.lsp')

-- Key-driven: telescope lazy-loads on first telescope keypress
lib.on_key('<leader>ff',    'plugins.telescope')
lib.on_key('<leader>fg',    'plugins.telescope')
lib.on_key('<leader>fb',    'plugins.telescope')
lib.on_key('<leader>f<cr>', 'plugins.telescope')

-- Key-driven: zen-mode lazy-loads on first keypress
lib.on_key('<leader>z', 'plugins.zen-mode')
