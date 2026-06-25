local M = {}

function M.setup()
    require("blink.cmp").setup({
        keymap = {
            preset = "default",
            ["<CR>"] = { "fallback" }, -- Ensure Enter always inserts a newline
        },

        appearance = {
            -- 'mono' for Nerd Font Mono, 'normal' for Nerd Font
            nerd_font_variant = "mono",
        },

        completion = {
            trigger = { prefetch_on_insert = false },
            documentation = {
                auto_show = true,
                auto_show_delay_ms = 500,
                window = { border = "rounded" },
            },
            menu = {
                border = "rounded",
                draw = {
                    -- kind_icon | label  label_description        kind   source
                    columns = {
                        { "kind_icon" },
                        { "label", "label_description", gap = 1 },
                        { "kind" },
                        { "source_name" },
                    },
                    components = {
                        -- Right-align the source name and dim it slightly
                        source_name = {
                            width = { max = 10 },
                            text = function(ctx)
                                return "[" .. ctx.source_name .. "]"
                            end,
                            highlight = "BlinkCmpSource",
                        },
                    },
                },
            },
        },

        sources = {
            default = { "lsp", "path", "snippets", "buffer" },

            -- lazydev: Neovim API completions with type info for Lua files
            per_filetype = {
                lua = { inherit_defaults = true, "lazydev" },
            },
            providers = {
                lazydev = {
                    name = "LazyDev",
                    module = "lazydev.integrations.blink",
                    score_offset = 100, -- prioritise lazydev over LSP for Lua
                },
            },
        },

        -- Use built-in vim.snippet engine — loads friendly-snippets automatically
        snippets = { preset = "luasnip" },

        -- Signature help: shows function signature when typing arguments
        -- Triggers on ( and , — toggle manually with C-k
        signature = { enabled = true },

        fuzzy = { implementation = "prefer_rust_with_warning" },
    })
end

return M
