-- ~/.config/nvim/lua/PE/init.lua
local w3m = require("PE.floaterm")

local M = {}

function M.setup()
	-- Set up the keymap
	vim.keymap.set("n", "<leader>pe", require("PE.main").main(), {
		desc = "project euler plugin start",
	})
end

return M
