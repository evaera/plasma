local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Plasma = require(ReplicatedStorage.Plasma)

return function(target)
	local root = Plasma.new(target)

	local headings = { "Name", "Count" }
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
					local entries = table.clone(items)
					table.insert(entries, 1, headings)

					local tbl = Plasma.table(entries, {
						headings = true,
						selectable = true,
					})

					local selectedHeading = tbl:selectedHeading()
					if headings[selectedHeading] == headings[1] then
						table.sort(items, function(a, b)
							return a[1] < b[1]
						end)
					elseif headings[selectedHeading] == headings[2] then
						table.sort(items, function(a, b)
							return a[2] < b[2]
						end)
					end

					local selectedRow, cellIndex = tbl:selected()
					if selectedRow then
						print(selectedRow, cellIndex)
					end

					if cellIndex == 1 then
						-- Remove row if click name
						table.remove(items, table.find(items, selectedRow))
					elseif cellIndex == 2 then
						-- Shuffle number if click count
						selectedRow[cellIndex] = Random.new():NextInteger(1, 100)
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
