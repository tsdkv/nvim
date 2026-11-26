local commands = require("plugins.lsp.servers.go.commands")
local settings = require("plugins.lsp.servers.go.settings")
local tools = require("plugins.lsp.servers.go.tools")

local function use_launch_root(config, launch_dir)
    -- Equal priority here keeps a parent Go module from crossing a checkout boundary.
    local boundaries = { config.root_markers }
    local project = vim.fs.root(launch_dir, boundaries)
    if not project or not (vim.uv.fs_stat(project .. "/go.mod") or vim.uv.fs_stat(project .. "/go.work")) then
        return
    end

    config.root_dir = function(bufnr, on_dir)
        local file = vim.fn.resolve(vim.api.nvim_buf_get_name(bufnr))
        if vim.fs.relpath(launch_dir, file) and vim.fs.root(file, boundaries) == project then
            on_dir(launch_dir)
        else
            on_dir(vim.fs.root(bufnr, config.root_markers))
        end
    end
    config.before_init = function(_, client_config)
        if launch_dir ~= project and client_config.root_dir == launch_dir then
            client_config.settings.gopls.expandWorkspaceToModule = false
        end
    end
end

return {
    name = "gopls",
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    tools = { "gopls", "iferr", "goimports", "gofumpt", "impl", "gomodifytags" },
    setup = function()
        local config = {
            cmd = { "gopls" },
            filetypes = { "go", "gomod", "gowork", "gotmpl" },
            root_markers = { "go.work", "go.mod", ".git" },
            -- Send didChange notifications to gopls at most every 300ms
            -- instead of the default 150ms (halves LSP traffic while typing).
            flags = { debounce_text_changes = 300 },
            settings = settings.get(),
        }
        if vim.g.nvim_launch_dir then
            use_launch_root(config, vim.g.nvim_launch_dir)
        end
        vim.lsp.config("gopls", config)
        vim.lsp.enable("gopls")
    end,
    on_attach = function(_, bufnr)
        require("core.load").keymap({
            { "<leader>lg", group = "Go Tools" },
            { "<leader>lge", tools.iferr, desc = "iferr: generate error block" },
            { "<leader>lgi", tools.impl, desc = "Generate interface stubs (impl)" },
            { "<leader>lgs", commands.toggle_staticcheck, desc = "Toggle staticcheck" },
            { "<leader>lgc", commands.gc_details, desc = "Toggle gc details (escape/inline analysis)" },
            {
                "<leader>lgt",
                function()
                    tools.modify_tags(false)
                end,
                desc = "Add Struct Tags",
            },
            {
                "<leader>lgT",
                function()
                    tools.modify_tags(true)
                end,
                desc = "Clear Struct Tags",
            },
        }, { buffer = bufnr })
    end,
}
