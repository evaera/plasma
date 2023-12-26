local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Plasma = require(ReplicatedStorage.Plasma)

return function(target)
	local root = Plasma.new(target)

	local heading = { "Name", "Count" }
	local items = {}
	for index, letter in { "A", "B", "C", "D", "E" } do
		table.insert(items, { letter, 100 - index })
	end

	local connection = RunService.Heartbeat:Connect(function()
		Plasma.start(root, function()
			Plasma.window("Table", function()
				Plasma.row({
					alignment = Enum.HorizontalAlignment.Center,
				}, function()
					local entry = table.clone(items)
					table.insert(entry, 1, heading)

					local tbl = Plasma.table(entry, {
						headings = true,
						selectable = true,
					})

					local selectedHeading = tbl:selectedHeading()
					if selectedHeading == "Name" then
						table.sort(items, function(a, b)
							return a[1] < b[1]
						end)
					elseif selectedHeading == "Count" then
						table.sort(items, function(a, b)
							return a[2] < b[2]
						end)
					end

					local selectedRow, selectedCell = tbl:selected()
					if selectedCell then
						local index = table.find(selectedRow, selectedCell)
						if index == 2 then
							selectedRow[index] = Random.new():NextInteger(1, 100)
						end
					end
				end)
			end)
		end)
	end)

	return function()
		connection:Disconnect()
		Plasma.start(root, function() end)
	end
end
