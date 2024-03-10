local M = {}

M.default = {
	win_opts = {
		title = 'LSP Info',
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
	escape_mappings = { 'q', '<esc>' },
	focus_on_open = true,
	close_on_leave = true,
	close_on_mouse_move = true,
}

local config = M.default

function M.setup(opts)
	config = vim.tbl_deep_extend('force', M.default, opts or {})
end

return setmetatable(M, {
	__index = function(_, k)
		return config[k]
	end,
})
