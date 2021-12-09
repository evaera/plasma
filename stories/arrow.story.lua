local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Plasma = require(ReplicatedStorage.Plasma)

return function(target)
	local root = Plasma.new(target)

	local checked = false

	local connection = RunService.Heartbeat:Connect(function()
		checked = not checked
		if checked then
			Plasma.start(root, function()
				Plasma.portal(workspace, function()
					Plasma.arrow(Vector3.new(0, 0, 0))
					Plasma.arrow(Vector3.new(5, 5, 5), Vector3.new(10, 10, 10))
				end)
			end)
		else
			Plasma.start(root, function() end)
		end
	end)

	return function()
		connection:Disconnect()
		Plasma.start(root, function() end)
	end
end
