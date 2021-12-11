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
					Plasma.spinner()
				end)
			end)
		end)
	end)

	return function()
		connection:Disconnect()
		Plasma.start(root, function() end)
	end
end
