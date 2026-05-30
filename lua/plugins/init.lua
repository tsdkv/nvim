local gh = require("utils").github
local load = require("core.load")

-- Hook to automatically run make when telescope-fzf-native is installed/updated
vim.api.nvim_create_autocmd("PackChanged", {
    group = vim.api.nvim_create_augroup("PackChangedFZF", { clear = true }),
    callback = function(ev)
        if
            ev.data.spec.name == "telescope-fzf-native.nvim"
            and (ev.data.kind == "install" or ev.data.kind == "update")
        then
            vim.notify("Building telescope-fzf-native...", vim.log.levels.INFO)
            vim.system({ "make" }, { cwd = ev.data.path }):wait()
            vim.notify("Finished building telescope-fzf-native", vim.log.levels.INFO)
        end
    end,
})

vim.pack.add({
    gh("nordtheme/vim"),
})
load.now("plugins.colorscheme")

vim.pack.add({
    gh("nvim-tree/nvim-web-devicons"),
    gh("nvim-lua/plenary.nvim"),

    gh("folke/lazydev.nvim"),
    gh("folke/which-key.nvim"),
    gh("folke/zen-mode.nvim"),
    gh("folke/todo-comments.nvim"),
    gh("folke/flash.nvim"),
    gh("folke/persistence.nvim"),

    gh("mason-org/mason.nvim"),
    gh("WhoIsSethDaniel/mason-tool-installer.nvim"),

    gh("kdheepak/lazygit.nvim"),
    gh("lewis6991/gitsigns.nvim"),
    gh("karb94/neoscroll.nvim"),
    gh("akinsho/toggleterm.nvim"),

    gh("nvim-lualine/lualine.nvim"),

    gh("otavioschwanck/arrow.nvim"),

    gh("nvim-telescope/telescope.nvim"),
    gh("nvim-telescope/telescope-fzf-native.nvim"),
    gh("nvim-telescope/telescope-ui-select.nvim"),

    gh("m4xshen/hardtime.nvim"),

    gh("tomasky/bookmarks.nvim"),

    gh("MunifTanjim/nui.nvim"),
    {
        src = gh("nvim-neo-tree/neo-tree.nvim"),
        version = vim.version.range("3"),
    },

    gh("rafamadriz/friendly-snippets"),
    gh("stevearc/conform.nvim"),
    {
        src = gh("saghen/blink.cmp"),
        version = vim.version.range("1"),
    },

    { src = gh("nvim-treesitter/nvim-treesitter") },
    { src = gh("nvim-treesitter/nvim-treesitter-textobjects") },

    { src = gh("nvim-mini/mini.notify"), version = "stable" },
    { src = gh("nvim-mini/mini.pairs"), version = "stable" },
})

-- Eager: must exist before any other plugin file registers keymaps or colors
load.now("nvim-web-devicons")
load.now("plugins.which-key")
load.now("plugins.neo-tree")
load.now("plugins.treesitter") -- treesitter doesn't support lazy loading

-- Deferred: one per event-loop tick to keep startup responsive
load.later("plugins.persistence")
load.later("plugins.mini")
load.later("plugins.blink")
load.later("plugins.conform")
load.later("plugins.git")
load.later("mason")
load.later("hardtime")
load.later("plugins.bookmarks")
load.later("plugins.neoscroll")
load.later("plugins.telescope")
load.later("plugins.zen-mode")
load.later("plugins.todo-comments")
load.later("plugins.arrow")
load.later("plugins.flash")
load.later("plugins.toggleterm")
load.later("plugins.lualine")

-- Filetype-driven
load.on_filetype("lua", "lazydev")

-- Event-driven: LSP infrastructure loads on first file open;
-- it auto-discovers server modules under plugins/lsp/servers/ and
-- arranges its own FileType-driven lazy setup for each.
load.on_event({ "BufReadPre", "BufNewFile" }, "plugins.lsp")
