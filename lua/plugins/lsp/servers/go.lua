local lib = require('lib')

local function iferr()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local offset   = vim.fn.line2byte(row) + col
    local result   = vim.fn.systemlist('iferr -pos ' .. offset .. ' ' .. vim.fn.expand('%'))
    if vim.v.shell_error ~= 0 then
        vim.notify('iferr: ' .. table.concat(result, '\n'), vim.log.levels.WARN)
        return
    end
    vim.api.nvim_put(result, 'l', true, true)
end

local function organize_imports(bufnr)
    local params = vim.lsp.util.make_range_params(nil, 'utf-8')
    params.context = { only = { 'source.organizeImports' }, diagnostics = {} }
    local result = vim.lsp.buf_request_sync(bufnr, 'textDocument/codeAction', params, 3000)
    for _, res in pairs(result or {}) do
        for _, action in pairs(res.result or {}) do
            if action.edit then
                vim.lsp.util.apply_workspace_edit(action.edit, 'utf-8')
            elseif type(action.command) == 'table' then
                vim.lsp.buf.execute_command(action.command)
            end
        end
    end
end

return {
    name      = 'gopls',
    filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
    tools     = { 'gopls', 'iferr', 'goimports', 'gofumpt' },
    setup     = function()
        vim.lsp.config('gopls', {
            cmd          = { 'gopls' },
            filetypes    = { 'go', 'gomod', 'gowork', 'gotmpl' },
            root_markers = { 'go.work', 'go.mod', '.git' },
            settings     = {
                gopls = {
                    gofumpt            = true,
                    staticcheck        = true,
                    completeUnimported = true,
                    usePlaceholders    = true,
                    analyses           = {
                        nilness        = true,
                        unusedparams   = true,
                        unusedwrite    = true,
                        unusedvariable = true,
                        useany         = true,
                    },
                    hints              = {
                        assignVariableTypes    = true,
                        compositeLiteralFields = true,
                        compositeLiteralTypes  = true,
                        constantValues         = true,
                        functionTypeParameters = true,
                        parameterNames         = true,
                        rangeVariableTypes     = true,
                    },
                },
            },
        })
        vim.lsp.enable('gopls')
    end,
    on_attach = function(_client, bufnr)
        vim.api.nvim_create_autocmd('BufWritePre', {
            group    = lib.augroup('GoOrganizeImports_' .. bufnr),
            buffer   = bufnr,
            callback = function() organize_imports(bufnr) end,
        })

        vim.keymap.set('n', '<leader>lI', iferr,
            { buffer = bufnr, silent = true, desc = 'iferr: generate error block' })
    end,
}
