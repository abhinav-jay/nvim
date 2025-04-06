local M = {}

function M.open_w3m()
	-- Calculate dimensions (80% of editor size)
	local file = io.read("number.txt", "r")
	local content = file:read("*a")
	file:close()
	local number = tonumber(content)
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2)

	-- Create floating window
	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal",
		border = "rounded",
	})

	-- Open w3m in terminal
	vim.fn.termopen("w3m projecteuler.net/problem=" .. number, {
		on_exit = function()
			vim.api.nvim_win_close(win, true)
		end,
	})

	-- Enter insert mode automatically
	vim.cmd("startinsert")
end

return M
