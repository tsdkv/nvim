# nvim

Personal Neovim configuration. Requires **Neovim 0.12+**.

## Install

```sh
git clone https://github.com/tsdkv/nvim ~/.config/nvim
```

Open Neovim — plugins install automatically via the built-in `vim.pack` package manager.

## Architecture & Structure

This configuration leverages Neovim 0.12's native `vim.pack` functionality combined with a custom lightweight lazy-loading module (`core.load`, inspired by `mini.misc`) to manage startup without relying on third-party plugin managers.

```text
.
├── plugin/       # Global keymaps, autocmds, and commands (auto-loaded on startup)
├── ftplugin/     # Filetype-specific settings (e.g., indentation overrides)
├── lua/
│   ├── core/     # Core scheduler helpers (load.now, load.later, load.on_event)
│   └── plugins/  # One file per plugin; each exports a sterile `M.setup()`
└── init.lua      # Entry point (sets leader keys and initializes plugins)
```

## Requirements

- Neovim 0.12+
- Git
- A [Nerd Font](https://www.nerdfonts.com/) for icons
- `make` (to build Telescope FZF native extensions)
