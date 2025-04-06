local M = {}

function M.boolean_prompt(question, callback)
	vim.ui.select({ "Yes", "No" }, { prompt = question }, function(choice)
		callback(choice == "Yes")
	end)
end

-- Usage:
-- boolean_prompt("Do you want to continue?", function(result)
--   if result then
--     print("User chose YES")
--     -- Do something
--   else
--     print("User chose NO")
--     -- Do something else
--   end
-- end)
return M
