local M = {}

local function discover_servers()
    local servers = {}
    for _, path in ipairs(vim.api.nvim_get_runtime_file("lua/plugins/lsp/servers/*.lua", true)) do
        local mod_name = vim.fn.fnamemodify(path, ":t:r")
        servers[mod_name] = require("plugins.lsp.servers." .. mod_name)
    end
    return servers
end

local check_type = require("utils").check_type
local function check_server_config(config)
    check_type("config", config, "table", false)

    check_type("name", config.name, "string", false)
    check_type("filetypes", config.filetypes, "table", true)
    check_type("tools", config.tools, "table", true)
    check_type("setup", config.setup, "function", true)
    check_type("on_attach", config.on_attach, "function", true)
end

local load = require("core.load")

function M.setup()
    load.ensure("blink.cmp")

    -- Advertise extended blink.cmp capabilities to every LSP server.
    vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
    })

    vim.diagnostic.config({
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        virtual_text = { prefix = "●", spacing = 4 },
        float = { border = "rounded", source = true, header = "", prefix = "" },
    })

    local servers = discover_servers()
    local tools = {}
    local handlers = {}

    for _, mod in pairs(servers) do
        check_server_config(mod)

        vim.list_extend(tools, mod.tools or {})
        if mod.name and mod.on_attach then
            handlers[mod.name] = mod.on_attach
        end
        if mod.filetypes and mod.setup then
            load.on_filetype(mod.filetypes, mod.setup, "LSP: " .. mod.name)
        end
    end

    load.later(function()
        require("mason-tool-installer").setup({
            ensure_installed = tools,
            run_on_start = true,
        })
    end, "mason-tool-installer")

    local attach = require("plugins.lsp.attach")
    vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
            local client = vim.lsp.get_client_by_id(ev.data.client_id)
            if not client then
                return
            end

            attach.on_attach(client, ev.buf)

            local handler = handlers[client.name]
            if handler then
                handler(client, ev.buf)
            end
        end,
    })
end

return M
