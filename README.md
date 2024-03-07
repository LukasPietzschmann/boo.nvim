# Boo 👻
Quickly pop-up some lsp-powered information of the thing your cursor is on.

<p align="center">
  <img src="https://github.com/LukasPietzschmann/boo.nvim/assets/49213919/2a54bb7d-cf7a-4248-bd5a-64dfbe2d776a" width="900px" />
</p>

## Installation
Install boo with your favorite package manager.

#### lazy.nvim
```lua
{
	'LukasPietzschmann/boo.nvim',
	opts = {
		-- here goes your config :)
	},
}
```

#### Others
With other package managers, you probably need to call the setup function yourself:
```lua
require('boo').setup({
  -- here goes your config :)
})
```

## Usage
1. You have to load boo
```lua
local boo = require('boo')
```
2. Then, you can call the `boo` function, which will show the pop-up
```lua
boo.boo()
```

## Configuration
Here comes the default configuration with some explanation:
```lua
{
  -- win_opts will be used when creating the window. You can put everything here,
  -- that vim.api.nvim_open_win (https://neovim.io/doc/user/api.html#nvim_open_win())
  -- can handle.
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
  -- The window will not be wider than max_width (in character cells)
  max_width = 80,
  -- The window will not be taller than max_height (in character cells)
  max_height = 20,
  -- When the boo window is focused, pressing one of these will close it.
  -- They will only be mapped in normalmode
  escape_mappings = { 'q', '<esc>' },
  -- When the boo window is focused, and you'll focus another buffer,
  -- the window will be closed when this is set to true
  close_on_leave = true,
}
```
