local utils = require 'boo.utils'
local get_lsp_info = utils.get_lsp_info
local modify_buffer = utils.modify_buffer

local config = require 'boo.config'

local M = {}

local boo_buffer = nil
local boo_win = nil

local close_callback = function()
	return M.close()
end

function M.boo()
	if boo_buffer ~= nil and vim.api.nvim_buf_is_valid(boo_buffer) then
		vim.api.nvim_buf_delete(boo_buffer, { force = true })
	end
	boo_buffer = vim.api.nvim_create_buf(false, true)

	for _, key in ipairs(config.escape_mappings) do
		vim.keymap.set('n', key, function()
			M.close()
		end, { buffer = boo_buffer })
	end
	if config.close_on_leave then
		vim.api.nvim_create_autocmd('BufLeave', {
			buffer = boo_buffer,
			desc = 'Closes boo when exiting the buffer',
			group = vim.api.nvim_create_augroup('Closeboo', { clear = true }),
			callback = close_callback,
		})
	end
	if config.close_on_mouse_move then
		vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
			buffer = 0,
			desc = 'Closes boo when moving the cursor',
			group = vim.api.nvim_create_augroup('Closeboo', { clear = true }),
			callback = close_callback,
		})
	end
	vim.api.nvim_buf_set_option(boo_buffer, 'buftype', 'nofile')
	vim.api.nvim_buf_set_option(boo_buffer, 'modifiable', false)
	vim.api.nvim_buf_set_option(boo_buffer, 'readonly', true)

	local lsp_info = get_lsp_info()
	if #lsp_info <= 0 then
		vim.notify('No info available', vim.log.levels.INFO, { title = 'boo' })
		return
	end

	modify_buffer(boo_buffer, function(buf)
		vim.lsp.util.stylize_markdown(buf, lsp_info, {})
	end)

	local width = 0
	local height = 0
	for _, line in ipairs(lsp_info) do
		width = math.max(width, vim.fn.strdisplaywidth(line))
	end
	width = math.min(config.max_width, width)
	height = math.min(config.max_height, vim.api.nvim_buf_line_count(boo_buffer))

	local win_config = vim.tbl_deep_extend('keep', config.win_opts, {
		width = width,
		height = height,
	})
	boo_win = vim.api.nvim_open_win(boo_buffer, config.focus_on_open, win_config)
end

function M.close()
	if boo_win == nil or not vim.api.nvim_win_is_valid(boo_win) then
		return false
	end
	vim.api.nvim_win_close(boo_win, true)
	return true
end

function M.setup(opts)
	config.setup(opts)
end

return M
