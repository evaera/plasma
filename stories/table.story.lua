local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Plasma = require(ReplicatedStorage.Plasma)

return function(target)
	local root = Plasma.new(target)
	local heading = { "Name", "Count" }
	local items = {
		{ "Test", 3 },
		{ "More Test", 4 },
	}

	local connection = RunService.Heartbeat:Connect(function()
		Plasma.start(root, function()
			Plasma.window("Spinner", function()
				Plasma.row({
					alignment = Enum.HorizontalAlignment.Center,
				}, function()
					local selectedHeading

					local entry = table.clone(items)
					table.insert(entry, 1, heading)

					local tbl = Plasma.table(entry, {
						headings = true,
						selectable = true,
					})

					_, selectedHeading = tbl:selectedHeading()
					if selectedHeading == "Name" then
						table.sort(items, function(a, b)
							return a[1] < b[1]
						end)
					elseif selectedHeading == "Count" then
						table.sort(items, function(a, b)
							return a[2] < b[2]
						end)
					end
					--print(tbl:selected())
				end)
			end)
		end)
	end)

	return function()
		connection:Disconnect()
		Plasma.start(root, function() end)
	end
end
