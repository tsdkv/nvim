# nvim

Personal Neovim configuration. Requires **Neovim 0.12+**.

## Install

```sh
git clone https://github.com/tsdkv/nvim ~/.config/nvim
```

Open Neovim — plugins install automatically via the built-in `vim.pack` package manager.

## Structure

```text
lua/
├── core/load/    # scheduler helpers (now/later/on_event/on_key/on_filetype)
├── config/       # options, keymaps, autocmds, commands
└── plugins/      # one file per plugin, each exports M.setup()
```

## Requirements

- Neovim 0.12+
- Git
- A [Nerd Font](https://www.nerdfonts.com/) for icons
