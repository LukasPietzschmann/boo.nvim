local M = {}

function M.modify_buffer(buffer, callback)
	local was_modifiable = vim.api.nvim_buf_get_option(buffer, 'modifiable')
	local was_readonly = vim.api.nvim_buf_get_option(buffer, 'readonly')

	vim.api.nvim_buf_set_option(buffer, 'modifiable', true)
	vim.api.nvim_buf_set_option(buffer, 'readonly', false)
	callback(buffer)
	vim.api.nvim_buf_set_option(buffer, 'modifiable', was_modifiable)
	vim.api.nvim_buf_set_option(buffer, 'readonly', was_readonly)
end

function M.has_lsp()
	local clients = vim.lsp.get_active_clients()
	for _, client in ipairs(clients) do
		if client.supports_method 'textDocument/hover' then
			return true
		end
	end
	return false
end

function M.get_lsp_info()
	if not M.has_lsp() then
		return {}
	end
	local result = {}
	local pos = vim.lsp.util.make_position_params()
	local lsp_results = vim.lsp.buf_request_sync(0, 'textDocument/hover', pos)
	for _, lsp_result in ipairs(lsp_results) do
		if lsp_result.result and lsp_result.result.contents then
			local md = vim.lsp.util.convert_input_to_markdown_lines(lsp_result.result.contents)
			for _, md_line in ipairs(md) do
				table.insert(result, md_line)
			end
		end
	end
	return result
end

return M
