local M = {}

function M.setup()
	vim.keymap.set("n", "<leader>pe", require("PE").main)
end

function M.main()
	print("function main is called!")
	local file = io.open("~/.config/nvim/lua/PE/number.txt", "r")
	if not file then
		print("Error: Could not open number.txt for reading")
		return
	end
	local n = file:read("*a")
	file:close()
	n = n + 1
	file = io.open("number.txt", "w")
	if not file then
		print("Error: Could not open number.txt for writing")
		return
	end

	file:write(tostring(n))
	file:close()
	local filename = n .. ".cpp"
	vim.notify(filename, nil)
	vim.cmd("e ~/coding/PE/" .. filename)

	print("Number incremented successfully. New value: " .. n)
end

return M
