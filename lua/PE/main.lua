local M = {}

function M.main()
	-- Open the file for reading
	local file = io.open("number.txt", "r")
	if not file then
		print("Error: Could not open number.txt for reading")
		return
	end

	-- Read the content and convert to number
	local content = file:read("*a")
	file:close()
	local number = tonumber(content)

	if not number then
		print("Error: Could not convert file content to a number")
		return
	end
	require("PE.confirm").boolean_prompt("Do you want to continue?", function(result)
		if result then
			vim.notify("yes")
			vim.call(":e ~/programming/project-euler/" .. number(".cpp"))
		else
			vim.notify("no")
			require("PE.init").setup()
		end
	end)

	-- Increment the number
	number = number + 1

	-- Open the file for writing (this will overwrite the file)
	file = io.open("number.txt", "w")
	if not file then
		print("Error: Could not open number.txt for writing")
		return
	end

	-- Write the new number back to the file
	file:write(tostring(number))
	file:close()

	print("Number incremented successfully. New value: " .. number)
end

return M
