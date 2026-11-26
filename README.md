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

> **Note:** You can run `:LoadTrace` at any time to open a detailed breakdown of the startup sequence, background task execution, and total initialization times.

## LSP workspaces

Start Neovim in a service directory inside a Go module to focus gopls diagnostics on that directory. Start at the `go.mod` or `go.work` root for the full workspace. Neovim remembers the launch directory across `:cd` and session restores. Files outside it, including those in another worktree, use normal root detection. Nested Go modules also use normal root detection.

In a Go buffer, `<leader>lgs` switches its gopls client from the default Staticcheck subset to full checks, then toggles full checks off or on.

Rust crates in the same Cargo workspace share a rust-analyzer client. Saves run `cargo check`. Run `cargo clippy` in the workspace when you want the additional lints. Use `<leader>lR` to restart the clients attached to the current buffer.

## Requirements

- Neovim 0.12+
- Git
- A [Nerd Font](https://www.nerdfonts.com/) for icons
- `make` (to build Telescope FZF native extensions)
