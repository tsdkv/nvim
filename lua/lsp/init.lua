local M = {}

function M.setup()
	require("mason").setup({})
	require("mason-lspconfig").setup({
		ensure_installed = {
			"lua_ls",
			"gopls",
			"rust_analyzer",
		},
	})

	local keymaps = require("lsp.keymap")

	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(ev)
			local client = vim.lsp.get_client_by_id(ev.data.client_id)
			if not client then
				return
			end

			keymaps.attach(ev.buf)


			if client:supports_method("textDocument/inlayHint", ev.buf) then
				keymaps.attach_inlay_hints(ev.buf)
			end

			-- Highlight references of the word under the cursor when it holds, clear when it moves
			if client:supports_method("textDocument/documentHighlight") then
				local highlight_group = vim.api.nvim_create_augroup("LspDocumentHighlight", { clear = false })

				vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
					group = highlight_group,
					buffer = ev.buf,
					callback = vim.lsp.buf.document_highlight,
				})
				vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
					group = highlight_group,
					buffer = ev.buf,
					callback = vim.lsp.buf.clear_references,
				})
			end
		end,
	})
end

return M
