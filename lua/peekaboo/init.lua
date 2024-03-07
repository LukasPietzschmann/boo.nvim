local default_config = {
	win_opts = {
		title = 'Info',
		title_pos = 'center',
		relative = 'cursor',
		row = 1,
		col = 0,
		style = 'minimal',
		border = 'rounded',
		focusable = true,
	},
	max_width = 80,
	max_height = 20,
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

	local raw_lsp_info = get_lsp_info()
	local lsp_info = {}
	if #raw_lsp_info > 0 then
		lsp_info = vim.list_extend({ '# LSP Info', '---' }, raw_lsp_info)
	end

	local raw_diagnostics = get_diagnostics()
	local diagnostics = {}
	if #raw_diagnostics > 0 then
		diagnostics = vim.list_extend({ '# Diagnostics', '---' }, raw_diagnostics)
	end

	if #raw_lsp_info <= 0 and #raw_diagnostics <= 0 then
		vim.notify('No info available', vim.log.levels.INFO, { title = 'Peekaboo' })
		return
	end

	local infos = vim.tbl_deep_extend('keep', lsp_info, diagnostics)
	modify_buffer(buffer, function(buf)
		vim.lsp.util.stylize_markdown(buf, infos, {})
	end)

	local width = 0
	for _, line in ipairs(infos) do
		width = math.max(width, vim.fn.strdisplaywidth(line))
	end
	width = math.min(config.max_width, width)
	local height = math.min(config.max_height, vim.api.nvim_buf_line_count(buffer))

	local win_config = vim.tbl_deep_extend('keep', config.win_opts, {
		width = width,
		height = height,
	})
	vim.api.nvim_open_win(buffer, true, win_config)
end

function M.setup(opts)
	config = vim.tbl_deep_extend('force', default_config, opts or {})
end

return M
