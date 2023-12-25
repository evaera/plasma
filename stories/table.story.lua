local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Plasma = require(ReplicatedStorage.Plasma)

return function(target)
	local root = Plasma.new(target)

	local connection = RunService.Heartbeat:Connect(function()
		Plasma.start(root, function()
			Plasma.window("Spinner", function()
				Plasma.row({
					alignment = Enum.HorizontalAlignment.Center,
				}, function()
					local tbl = Plasma.table({
						{ "Name", "Count" },
						{ "Test", "3" },
						{ " More Test", "4" },
					}, {
						headings = true,
						selectable = true,
					})

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
