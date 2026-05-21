local gh   = require('utils').github
local load = require('core.load')

vim.pack.add({
    gh('nordtheme/vim'),
    gh('mason-org/mason.nvim'),
    gh('WhoIsSethDaniel/mason-tool-installer.nvim'),
    gh('folke/lazydev.nvim'),
    gh('nvim-lua/plenary.nvim'),
    gh('nvim-telescope/telescope.nvim'),
    gh('folke/which-key.nvim'),
    gh('folke/zen-mode.nvim'),
    gh('kdheepak/lazygit.nvim'),
    gh('lewis6991/gitsigns.nvim'),

    gh("MunifTanjim/nui.nvim"),
    gh("nvim-tree/nvim-web-devicons"),
    {
        src = gh('nvim-neo-tree/neo-tree.nvim'),
        version = vim.version.range('3')
    },

    { src = gh('nvim-treesitter/nvim-treesitter') },

    { src = gh('nvim-mini/mini.comment'),         version = 'stable' },
    { src = gh('nvim-mini/mini.bufremove'),       version = 'stable' },
    { src = gh('nvim-mini/mini.completion'),      version = 'stable' },
    { src = gh('nvim-mini/mini.tabline'),         version = 'stable' },
    { src = gh('nvim-mini/mini.statusline'),      version = 'stable' },
    { src = gh('nvim-mini/mini.notify'),          version = 'stable' },
    { src = gh('nvim-mini/mini.pairs'),           version = 'stable' },
})

-- Eager: must exist before any other plugin file registers keymaps or colors
load.now('nvim-web-devicons')
load.now('plugins.colorscheme')
load.now('plugins.which-key')
load.now('plugins.neo-tree')
load.now('plugins.treesitter') -- treesitter doesn't support lazy loading

-- Deferred: one per event-loop tick to keep startup responsive
load.later('plugins.mini')
load.later('plugins.git')

-- Filetype-driven
load.on_filetype('lua', 'plugins.lazydev')

-- Event-driven: LSP infrastructure loads on first file open;
-- it auto-discovers server modules under plugins/lsp/servers/ and
-- arranges its own FileType-driven lazy setup for each.
load.on_event({ 'BufReadPre', 'BufNewFile' }, 'plugins.lsp')

-- Key-driven: telescope lazy-loads on first telescope keypress
load.on_key('<leader>ff', 'plugins.telescope')
load.on_key('<leader>fg', 'plugins.telescope')
load.on_key('<leader>fb', 'plugins.telescope')
load.on_key('<leader>f<cr>', 'plugins.telescope')

-- Key-driven: zen-mode lazy-loads on first keypress
load.on_key('<leader>z', 'plugins.zen-mode')
