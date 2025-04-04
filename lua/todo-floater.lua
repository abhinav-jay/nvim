local M = {}

function M.setup()
	vim.api.nvim_set_keymap(
		"n",
		"<leader>to",
		':lua require("todo-floater").toggle_todo()<CR>',
		{ noremap = true, silent = true }
	)
end

function M.setup_completion(bufnr)
	if not vim.fn.exists(":CmpSetup") then
		return
	end

	local cmp = require("cmp")
	cmp.setup.buffer({
		sources = {
			{ name = "nvim_lsp" },
			{ name = "luasnip" },
			{ name = "buffer" },
			{ name = "path" },
			{ name = "emoji" },
			{ name = "spell" },
		},
		mapping = cmp.mapping.preset.insert({
			["<CR>"] = cmp.mapping.confirm({ select = true }),
			["<Tab>"] = cmp.mapping.select_next_item(),
			["<S-Tab>"] = cmp.mapping.select_prev_item(),
			["<C-e>"] = cmp.mapping.abort(),
		}),
		window = {
			completion = cmp.config.window.bordered(),
			documentation = cmp.config.window.bordered(),
		},
	})
end

function M.toggle_todo()
	-- Check if buffer already exists
	local buf, win
	for _, b in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_get_name(b):find("todo.md$") then
			buf = b
			for _, w in ipairs(vim.api.nvim_list_wins()) do
				if vim.api.nvim_win_get_buf(w) == buf then
					win = w
					break
				end
			end
			break
		end
	end

	if win and vim.api.nvim_win_is_valid(win) then
		-- Save before closing
		if vim.api.nvim_buf_get_option(buf, "modified") then
			vim.api.nvim_buf_call(buf, function()
				vim.cmd("w")
			end)
		end
		vim.api.nvim_win_close(win, true)
		return
	end

	-- Create new floating window
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	buf = buf or vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_name(buf, "todo.md")
	vim.api.nvim_buf_set_option(buf, "buftype", "acwrite")
	vim.api.nvim_buf_set_option(buf, "bufhidden", "hide")
	vim.api.nvim_buf_set_option(buf, "swapfile", false)
	vim.api.nvim_buf_set_option(buf, "modified", false)
	vim.api.nvim_buf_set_option(buf, "filetype", "md")

	-- Read todo file
	local todo_path = vim.fn.expand("~/md/todo.md")
	local file = io.open(todo_path, "r")
	if file then
		local content = file:read("*a")
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(content, "\n"))
		file:close()
	else
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "# Todo List", "", "- [ ] Add your tasks here" })
	end

	-- Set up autocommands
	vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
		buffer = buf,
		callback = function()
			vim.api.nvim_buf_set_option(buf, "modified", true)
		end,
	})

	vim.api.nvim_create_autocmd("BufWriteCmd", {
		buffer = buf,
		callback = function()
			local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
			local todo_path = vim.fn.expand("~/md/todo.md")
			local file = io.open(todo_path, "w")
			if file then
				file:write(table.concat(lines, "\n"))
				file:close()
				vim.api.nvim_buf_set_option(buf, "modified", false)
				vim.api.nvim_command("checktime")
			else
				vim.api.nvim_err_writeln("Could not save todo.md")
			end
		end,
	})

	local opts = {
		style = "minimal",
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		border = "rounded",
	}

	-- Window options
	win = vim.api.nvim_open_win(buf, true, opts)
	vim.api.nvim_win_set_option(win, "number", true)
	vim.api.nvim_win_set_option(win, "relativenumber", false)
	vim.api.nvim_win_set_option(win, "wrap", true)
	vim.api.nvim_win_set_option(win, "linebreak", true)
	vim.api.nvim_win_set_option(win, "conceallevel", 2) -- Better markdown rendering

	-- Setup completion
	M.setup_completion(buf)

	-- Keymaps
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
