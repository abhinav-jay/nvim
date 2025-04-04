-- Usage: Press <leader>to to toggle the todo list
--  the file is sourced from ~/.todo.md

local M = {}

function M.setup()
	-- Set up the key mapping
	vim.api.nvim_set_keymap(
		"n",
		"<leader>to",
		':lua require("todo-floater").toggle_todo()<CR>',
		{ noremap = true, silent = true }
	)
end

function M.toggle_todo()
	-- Check if the buffer already exists
	local buf_exists = false
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_get_name(buf):find("todo.md$") then
			buf_exists = true
			-- Check if the window is already open
			for _, win in ipairs(vim.api.nvim_list_wins()) do
				if vim.api.nvim_win_get_buf(win) == buf then
					-- Window is open, close it
					vim.api.nvim_win_close(win, true)
					return
				end
			end
			break
		end
	end

	-- Get screen dimensions
	local width = vim.api.nvim_get_option("columns")
	local height = vim.api.nvim_get_option("lines")

	-- Calculate window dimensions (80% of screen)
	local win_width = math.floor(width * 0.8)
	local win_height = math.floor(height * 0.8)

	-- Calculate window position (centered)
	local row = math.floor((height - win_height) / 2)
	local col = math.floor((width - win_width) / 2)

	-- Create the floating window
	local buf
	if buf_exists then
		-- Find the existing buffer
		for _, b in ipairs(vim.api.nvim_list_bufs()) do
			if vim.api.nvim_buf_get_name(b):find("todo.md$") then
				buf = b
				break
			end
		end
	else
		-- Create a new buffer
		buf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_name(buf, "todo.md")
		vim.api.nvim_buf_set_option(buf, "buftype", "acwrite")
		vim.api.nvim_buf_set_option(buf, "bufhidden", "hide")
		vim.api.nvim_buf_set_option(buf, "swapfile", false)

		-- Try to read the todo file
		local todo_path = vim.fn.expand("~/.todo.md")
		local file = io.open(todo_path, "r")
		if file then
			local content = file:read("*a")
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(content, "\n"))
			file:close()
		else
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "# Todo List", "", "- [ ] Add your tasks here" })
		end

		-- Set up autocommand to save when the buffer is written
		vim.api.nvim_create_autocmd("BufWriteCmd", {
			buffer = buf,
			callback = function()
				local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
				local todo_path = vim.fn.expand("~/.todo.md")
				local file = io.open(todo_path, "w")
				if file then
					file:write(table.concat(lines, "\n"))
					buffer:close()
					vim.api.nvim_command("checktime") -- Refresh the buffer
				else
					vim.api.nvim_err_writeln("Could not save todo.md")
				end
			end,
		})
	end

	local opts = {
		style = "minimal",
		relative = "editor",
		width = win_width,
		height = win_height,
		row = row,
		col = col,
		border = "rounded",
	}

	local win = vim.api.nvim_open_win(buf, true, opts)

	-- Set some window options
	vim.api.nvim_win_set_option(win, "number", true)
	vim.api.nvim_win_set_option(win, "relativenumber", false)
	vim.api.nvim_win_set_option(win, "wrap", true)
	vim.api.nvim_win_set_option(win, "linebreak", true)

	-- Set up keymaps for the window
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"q",
		':lua require("todo-floater").toggle_todo()<CR>',
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"<Esc>",
		':lua require("todo-floater").toggle_todo()<CR>',
		{ noremap = true, silent = true }
	)
end

return M
