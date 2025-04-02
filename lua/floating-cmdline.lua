local M = {}

-- Default configuration
local default_config = {
	width = 0.6,
	height = 0.03,
	border = "rounded",
	style = "minimal",
	center_on_screen = true,
	highlight = {
		bg = "#1a1b26",
		fg = "#c0caf5",
		border = "#f7a237",
	},
	prompt = "  ",
	auto_trigger = true, -- Enable automatic opening on ':'
}

M.config = default_config
M.win_id = nil
M.buf_id = nil

function M.setup(user_config)
	M.config = vim.tbl_deep_extend("force", default_config, user_config or {})

	-- Set up autocommand if auto_trigger is enabled
	if M.config.auto_trigger then
		vim.api.nvim_create_autocmd("CmdlineEnter", {
			pattern = ":",
			callback = function()
				if vim.fn.mode() == "n" then -- Only trigger in normal mode
					M.open_floating_cmdline()
				end
			end,
		})
	end
end

function M.open_floating_cmdline()
	-- Close if already open
	if M.win_id and vim.api.nvim_win_is_valid(M.win_id) then
		vim.api.nvim_win_close(M.win_id, true)
	end

	local width = math.floor(vim.o.columns * M.config.width)
	local height = math.floor(vim.o.lines * M.config.height)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	-- Create a scratch buffer
	M.buf_id = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(M.buf_id, "buftype", "prompt")
	vim.api.nvim_buf_set_option(M.buf_id, "bufhidden", "wipe")

	-- Create the floating window
	M.win_id = vim.api.nvim_open_win(M.buf_id, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = M.config.style,
		border = M.config.border,
	})

	-- Apply styling
	vim.api.nvim_win_set_option(M.win_id, "winhl", "NormalFloat:FloatingCmdBG,FloatBorder:FloatingCmdBorder")
	vim.api.nvim_win_set_option(M.win_id, "winblend", 10)

	-- Set prompt
	vim.fn.prompt_setprompt(M.buf_id, M.config.prompt)

	-- Handle command submission
	vim.fn.prompt_setcallback(M.buf_id, function(text)
		if M.win_id and vim.api.nvim_win_is_valid(M.win_id) then
			vim.api.nvim_win_close(M.win_id, true)
		end
		vim.api.nvim_command(text)
	end)

	-- Auto-close on Escape
	vim.keymap.set("i", "<Esc>", function()
		if M.win_id and vim.api.nvim_win_is_valid(M.win_id) then
			vim.api.nvim_win_close(M.win_id, true)
		end
	end, { buffer = M.buf_id })

	-- Start insert mode automatically
	vim.cmd("startinsert")
end

-- Define highlight groups
vim.api.nvim_set_hl(0, "FloatingCmdBG", { bg = M.config.highlight.bg, fg = M.config.highlight.fg })
vim.api.nvim_set_hl(0, "FloatingCmdBorder", { fg = M.config.highlight.border })

-- Keybinding to trigger the floating command line manually
vim.api.nvim_set_keymap(
	"n",
	":",
	"<cmd>lua require('floating-cmdline').open_floating_cmdline()<CR>",
	{ noremap = true, silent = true }
)

return M
