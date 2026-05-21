# AI Agent Guide: Neovim Configuration Maintenance

Welcome! This document provides information on the structure, design patterns, and conventions of this Neovim configuration to help you (and other AI agents) maintain and extend it efficiently.

## Design Philosophy
This configuration is designed to be **highly modular, responsive, and fast-starting**. It leverages a custom lazy-loading/deferring scheduler framework under `lua/core/load/init.lua` to defer loading heavy plugins until they are actually needed (e.g. by filetype, keypress, command, or editor event).

---

## Directory Structure

```text
.
├── init.lua              # Editor entry point
├── Makefile              # Helper tasks (e.g., test suite execution)
├── lua/
│   ├── core/load/        # Core scheduling & lazy-loading framework
│   ├── config/           # General Neovim options, mappings, commands, autocmds
│   │   ├── options.lua
│   │   ├── keymap.lua
│   │   ├── autocmds.lua
│   │   └── commands.lua
│   └── plugins/          # Plugin definitions (each file returns a setup module)
│       ├── init.lua      # Plugin registry (vim.pack.add and lazy bindings)
│       ├── neo-tree.lua
│       ├── treesitter.lua
│       └── ...
└── tests/                # Test suite (Busted specs)
    └── load_spec.lua     # Core loader tests
```

---

## The Core Loader (`core.load`)

The `core.load` module (located in [lua/core/load/init.lua](file:///Users/tmac/.config/nvim/lua/core/load/init.lua)) provides robust scheduler helpers that wrap plugin loading in `pcall` to prevent config crashes.

### API Summary

| Function | Signature | Use Case |
| :--- | :--- | :--- |
| `now` | `load.now(target)` | Eagerly require/load a module during startup. |
| `later` | `load.later(target)` | Defer loading to a one-per-tick queue starting after `VimEnter`. |
| `on_event` | `load.on_event(events, target, pattern)` | Load a module when specific autocommand events fire (e.g., `BufReadPre`). |
| `on_filetype` | `load.on_filetype(filetypes, target)` | Defer loading until a specific filetype buffer is opened. |
| `on_key` | `load.on_key(lhs, target, mode)` | Lazy-load on keypress. Removes stub, runs setup, and replays keypress. |
| `on_cmd` | `load.on_cmd(name, target)` | Lazy-load on user command. Removes stub, runs setup, and replays command. |

### target resolution
A `target` can be:
- **A string**: Re-directed to safe-require the module and automatically invoke its `.setup()` function if it exists.
- **A function**: Executed directly.

---

## How to Add or Modify Plugins

To integrate a new plugin, follow these steps:

1. **Register the Plugin**:
   Open [lua/plugins/init.lua](file:///Users/tmac/.config/nvim/lua/plugins/init.lua) and append the GitHub repository name to `vim.pack.add`. Use the `gh` helper:
   ```lua
   vim.pack.add({
       -- ... existing plugins
       { src = gh('username/repo-name') },
   })
   ```

2. **Configure the Plugin**:
   Create a new file `lua/plugins/<plugin_name>.lua`. The file must return a module containing a `setup` function:
   ```lua
   local M = {}

   M.setup = function()
       require('plugin-name').setup({
           -- configuration options
       })
   end

   return M
   ```

3. **Schedule the Loading**:
   In [lua/plugins/init.lua](file:///Users/tmac/.config/nvim/lua/plugins/init.lua), schedule how the plugin configuration is resolved using `core.load`:
   - **Eager/Immediate** (rare, only for themes or core UI):
     ```lua
     load.now('plugins.plugin_name')
     ```
   - **Deferred** (common for minor status/utility plugins):
     ```lua
     load.later('plugins.plugin_name')
     ```
   - **On FileType** (common for language-specific plugins/linters):
     ```lua
     load.on_filetype('markdown', 'plugins.plugin_name')
     ```
   - **On Event**:
     ```lua
     load.on_event({ 'BufReadPre', 'BufNewFile' }, 'plugins.plugin_name')
     ```
   - **On Keypress** (common for exploratory/heavy tools like fuzzy finders):
     ```lua
     load.on_key('<leader>p', 'plugins.plugin_name')
     ```

---

## Testing Configurations

Unit tests for `core.load` are located in [tests/load_spec.lua](file:///Users/tmac/.config/nvim/tests/load_spec.lua). 

You can run the test suite by running the following command from the root directory:
```sh
make test
```
Always ensure tests pass before committing changes.
