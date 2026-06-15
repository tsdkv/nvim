local has_local, local_config = pcall(require, "local.minuet")

if not has_local or type(local_config) ~= "table" then
    return {}
end

if not local_config.provider and not (local_config.presets and next(local_config.presets)) then
    return {}
end

local M = {}

M.keymap = {
    -- Configuration and Toggling
    { "<leader>ap", "<cmd>Minuet change_preset <CR>", desc = "Change AI Preset" },
    { "<leader>am", "<cmd>Minuet change_model <CR>", desc = "Change AI Model (Interactive)" },
    { "<leader>at", "<cmd>Minuet blink toggle<CR>", desc = "Toggle AI Completion" },

    -- Duet (Next Edit Prediction) Commands
    { "<leader>ad", "<cmd>Minuet duet predict<CR>", desc = "Duet Predict" },
    { "<leader>aa", "<cmd>Minuet duet apply<CR>", desc = "Duet Apply" },
    { "<leader>ax", "<cmd>Minuet duet dismiss<CR>", desc = "Duet Dismiss" },
}

M.setup = function()
    ---@module 'minuet.config'
    local config = {
        notify = "debug",
        request_timeout = 3,
        blink = {
            -- Controls if AI triggers automatically as you type.
            -- `true` by default. You can toggle this on the fly with `<leader>at`.
            enable_auto_complete = true,
        },
        provider_options = {},
        presets = {},
    }

    config = vim.tbl_deep_extend("force", config, local_config)
    require("minuet").setup(config)
end

return M
