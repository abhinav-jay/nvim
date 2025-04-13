-- ~/.config/nvim/lua/todo/init.lua

local M = {}

local ns = vim.api.nvim_create_namespace("todo_highlight")
local todo_path = vim.fn.expand("~/.config/nvim/lua/todo/todo.txt")

-- Use theme-compatible colors
vim.api.nvim_set_hl(0, "TodoHighPriority", { fg = "#f7768e", bg = "NONE" })
vim.api.nvim_set_hl(0, "TodoMediumPriority", { fg = "#e0af68", bg = "NONE" })
vim.api.nvim_set_hl(0, "TodoLowPriority", { fg = "#9ece6a", bg = "NONE" })

local function apply_highlighting(buf)
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	for i, line in ipairs(lines) do
		if line:match("^#high") then
			vim.api.nvim_buf_add_highlight(buf, ns, "TodoHighPriority", i - 1, 0, -1)
		elseif line:match("^#medium") then
			vim.api.nvim_buf_add_highlight(buf, ns, "TodoMediumPriority", i - 1, 0, -1)
		elseif line:match("^#low") then
			vim.api.nvim_buf_add_highlight(buf, ns, "TodoLowPriority", i - 1, 0, -1)
		end
	end
end

function M.open_todo_window()
	local buf = vim.api.nvim_create_buf(false, true)
	local width = math.floor(vim.o.columns * 0.6)
	local height = math.floor(vim.o.lines * 0.6)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	})

	vim.cmd("edit " .. todo_path)
	vim.bo[buf].filetype = "todo"
	vim.bo[buf].modifiable = true
	vim.bo[buf].bufhidden = "wipe"
	vim.keymap.set("n", "<Esc>", "<cmd>wq<CR>", { buffer = buf })

	-- Apply highlighting after slight delay to ensure buffer is fully loaded
	vim.defer_fn(function()
		apply_highlighting(buf)
	end, 50)
end

function M.fuzzy_find_tasks()
	local lines = {}
	for line in io.lines(todo_path) do
		table.insert(lines, line)
	end

	table.sort(lines, function(a, b)
		local function get_priority(line)
			if line:match("^#high") then
				return 1
			elseif line:match("^#medium") then
				return 2
			elseif line:match("^#low") then
				return 3
			else
				return 4
			end
		end
		return get_priority(a) < get_priority(b)
	end)

	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	pickers
		.new({}, {
			prompt_title = "Todo Tasks",
			finder = finders.new_table({
				results = lines,
			}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()[1]

					local linenum = nil
					for i, line in ipairs(lines) do
						if line == selection then
							linenum = i
							break
						end
					end

					M.open_todo_window()

					vim.defer_fn(function()
						vim.api.nvim_win_set_cursor(0, { linenum, 0 })
					end, 100)
				end)
				return true
			end,
		})
		:find()
end

-- Keymap to fuzzy find todo tasks
vim.keymap.set("n", "<leader>tdf", M.fuzzy_find_tasks)
vim.keymap.set("n", "<leader>tdo", M.open_todo_window)

return M
