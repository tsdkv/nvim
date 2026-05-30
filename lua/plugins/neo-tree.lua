local M = {}

M.keymap = {
    { "<leader>e", "<Cmd>Neotree<CR>", desc = "Toggle explorer" },
}

M.setup = function()
    local git_available = vim.fn.executable("git") == 1

    require("neo-tree").setup({
        close_if_last_window = true,
        enable_git_status = git_available,
        auto_clean_after_session_restore = true,
        enable_diagnostics = false,

        source_selector = {
            winbar = true,
            content_layout = "center",
            truncation_character = "",
            sources = {
                { source = "filesystem", display_name = " 󰉓 Files " },
                { source = "git_status", display_name = " 󰊢 Git " },
            },
        },

        default_component_configs = {
            indent = {
                padding = 0,
                with_markers = true,
                indent_marker = "│",
                last_indent_marker = "└",
                with_expanders = true,
                expander_collapsed = "",
                expander_expanded = "",
            },
            modified = { symbol = " •" },
            icon = {
                folder_closed = "",
                folder_open = "",
                folder_empty = "󰜌",
                folder_empty_open = "󰜌",
                default = "*",
                use_filtered_colors = true,
            },
        },

        renderers = {
            directory = {
                { "indent" },
                { "icon" },
                { "name", is_name_only = true },
            },
            file = {
                { "indent" },
                { "icon" },
                { "name", is_name_only = true },
                { "modified" },
            },
        },

        commands = {
            system_open = function(state)
                vim.ui.open(state.tree:get_node():get_id())
            end,
        },

        window = {
            width = 30,
            mappings = {
                ["<esc>"] = function()
                    vim.cmd("wincmd p")
                end,
                ["<Space>"] = false,
                ["h"] = function(state)
                    local node = state.tree:get_node()
                    if node:has_children() and node:is_expanded() then
                        state.commands.toggle_node(state)
                    else
                        require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
                    end
                end,
                ["l"] = function(state)
                    local node = state.tree:get_node()
                    if node:has_children() then
                        if not node:is_expanded() then
                            state.commands.toggle_node(state)
                        else
                            if node.type == "file" then
                                state.commands.open(state)
                            else
                                require("neo-tree.ui.renderer").focus_node(state, node:get_child_ids()[1])
                            end
                        end
                    else
                        state.commands.open(state)
                    end
                end,
                ["O"] = "system_open",
                ["[b"] = "prev_source",
                ["]b"] = "next_source",
            },
            fuzzy_finder_mappings = {
                ["<C-J>"] = "move_cursor_down",
                ["<C-K>"] = "move_cursor_up",
            },
        },

        filesystem = {
            follow_current_file = { enabled = true },
            filtered_items = {
                hide_gitignored = git_available,
                hide_dotfiles = true,
            },
            hijack_netrw_behavior = "open_current",
            use_libuv_file_watcher = vim.fn.has("win32") ~= 1,
        },

        event_handlers = {
            {
                event = "neo_tree_buffer_enter",
                handler = function(_)
                    vim.opt_local.signcolumn = "no"
                    vim.opt_local.foldcolumn = "0"
                end,
            },
        },
    })
end

return M
