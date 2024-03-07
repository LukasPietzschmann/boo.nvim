local utils = require 'peekaboo.utils'
local get_lsp_info = utils.get_lsp_info
local modify_buffer = utils.modify_buffer

local config = require 'peekaboo.config'

local M = {}

local peekaboo_buffer = nil
local peekaboo_win = nil
function M.peekaboo()
	if peekaboo_buffer then
		if vim.api.nvim_buf_is_valid(peekaboo_buffer) then
			vim.api.nvim_buf_delete(peekaboo_buffer, { force = true })
		else
			peekaboo_buffer = nil
		end
	end
	peekaboo_buffer = vim.api.nvim_create_buf(false, true)
	for _, key in ipairs(config.escape_mappings) do
		vim.keymap.set('n', key, function()
			vim.api.nvim_win_close(peekaboo_win, true)
		end, { buffer = peekaboo_buffer })
	end
	if config.close_on_leave then
		vim.api.nvim_create_autocmd('BufLeave', {
			buffer = peekaboo_buffer,
			desc = 'Closes peekaboo when exiting the buffer',
			group = vim.api.nvim_create_augroup('ClosePeekaboo', { clear = true }),
			callback = function()
				vim.api.nvim_win_close(peekaboo_win, true)
			end,
		})
	end
	vim.api.nvim_buf_set_option(peekaboo_buffer, 'buftype', 'nofile')
	vim.api.nvim_buf_set_option(peekaboo_buffer, 'modifiable', false)
	vim.api.nvim_buf_set_option(peekaboo_buffer, 'readonly', true)

	local lsp_info = get_lsp_info()
	if #lsp_info <= 0 then
		vim.notify('No info available', vim.log.levels.INFO, { title = 'Peekaboo' })
		return
	end

	modify_buffer(peekaboo_buffer, function(buf)
		vim.lsp.util.stylize_markdown(buf, lsp_info, {})
	end)

	local width = 0
	for _, line in ipairs(lsp_info) do
		width = math.max(width, vim.fn.strdisplaywidth(line))
	end
	width = math.min(config.max_width, width)
	local height = math.min(config.max_height, vim.api.nvim_buf_line_count(peekaboo_buffer))

	local win_config = vim.tbl_deep_extend('keep', config.win_opts, {
		width = width,
		height = height,
	})
	peekaboo_win = vim.api.nvim_open_win(peekaboo_buffer, true, win_config)
end

function M.setup(opts)
	config.setup(opts)
end

return M
