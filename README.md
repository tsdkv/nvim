# nvim

Personal Neovim configuration. Requires **Neovim 0.12+**.

## Install

```sh
git clone https://github.com/tsdkv/nvim ~/.config/nvim
```

Open Neovim — plugins install automatically via the built-in `vim.pack` package manager.

## Structure

```
lua/
├── lib/          # scheduler helpers (now/later/on_event/on_key)
├── config/       # options, keymaps, autocmds, commands
└── plugins/      # one file per plugin, each exports M.setup()
```

## Requirements

- Neovim 0.12+
- Git
- A [Nerd Font](https://www.nerdfonts.com/) for icons
