local M = {}

function M.modify_buffer(buffer, callback)
	local was_modifiable = vim.api.nvim_get_option_value('modifiable', { buf = buffer })
	local was_readonly = vim.api.nvim_get_option_value('readonly', { buf = buffer })

	vim.api.nvim_set_option_value('modifiable', true, { buf = buffer })
	vim.api.nvim_set_option_value('readonly', false, { buf = buffer })
	callback(buffer)
	vim.api.nvim_set_option_value('modifiable', was_modifiable, { buf = buffer })
	vim.api.nvim_set_option_value('readonly', was_readonly, { buf = buffer })
end

function M.has_lsp()
	local clients = vim.lsp.get_clients { method = 'textDocument/hover' }
	return #clients > 0
end

function M.get_lsp_info()
	if not M.has_lsp() then
		return {}
	end
	local result = {}
	local pos = vim.lsp.util.make_position_params()
	local lsp_results, err = vim.lsp.buf_request_sync(0, 'textDocument/hover', pos)
	if err then
		return {}
	end
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
