local default_config = {
	win_opts = {
		title = 'Info',
		title_pos = 'center',
		relative = 'cursor',
		width = 50,
		height = 6,
		row = 1,
		col = 0,
		style = 'minimal',
		border = 'rounded',
		focusable = true,
	},
}

local config = {}

local M = {}

local buffer = nil

local function modify_buffer(buffer, callback)
	local was_modifiable = vim.api.nvim_buf_get_option(buffer, 'modifiable')
	local was_readonly = vim.api.nvim_buf_get_option(buffer, 'readonly')

	vim.api.nvim_buf_set_option(buffer, 'modifiable', true)
	vim.api.nvim_buf_set_option(buffer, 'readonly', false)
	callback(buffer)
	vim.api.nvim_buf_set_option(buffer, 'modifiable', was_modifiable)
	vim.api.nvim_buf_set_option(buffer, 'readonly', was_readonly)
end

local function has_lsp()
	local clients = vim.lsp.get_active_clients()
	for _, client in ipairs(clients) do
		if client.supports_method 'textDocument/hover' then
			return true
		end
	end
	return false
end

local function get_lsp_info()
	if not has_lsp() then
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

local function get_diagnostics()
	local result = {}
	local row = vim.api.nvim_win_get_cursor(0)[1]
	local diagnostics = vim.diagnostic.get(0, { lnum = row })
	for _, diagnostic in ipairs(diagnostics) do
		table.insert(result, diagnostic.message)
	end
	return result
end

function M.peekaboo()
	if buffer then
		if vim.api.nvim_buf_is_valid(buffer) then
			vim.api.nvim_buf_delete(buffer, { force = true })
		else
			buffer = nil
		end
	end
	buffer = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(buffer, 'buftype', 'nofile')
	vim.api.nvim_buf_set_option(buffer, 'modifiable', false)
	vim.api.nvim_buf_set_option(buffer, 'readonly', true)

	local infos = vim.tbl_deep_extend('keep', get_lsp_info(), get_diagnostics())
	modify_buffer(buffer, function(buf)
		vim.lsp.util.stylize_markdown(buf, infos, {})
	end)

	vim.api.nvim_open_win(buffer, true, config.win_opts)
end

function M.setup(opts)
	config = vim.tbl_deep_extend('force', default_config, opts or {})
end

return M
