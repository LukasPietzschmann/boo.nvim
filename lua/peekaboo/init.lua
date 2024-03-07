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

function M.peekaboo()
	if buffer then
		vim.api.nvim_buf_delete(buffer, { force = true })
	end
	buffer = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(buffer, 'buftype', 'nofile')
	vim.api.nvim_buf_set_option(buffer, 'modifiable', false)
	vim.api.nvim_buf_set_option(buffer, 'readonly', true)

	vim.api.nvim_open_win(buffer, true, config.win_opts)
end

function M.setup(opts)
	config = vim.tbl_deep_extend('force', default_config, opts or {})
end

return M
