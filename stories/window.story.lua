local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Plasma = require(ReplicatedStorage.Plasma)

return function(target)
	local root = Plasma.new(target)

	local movable = true
	local closable = true

	local connection = RunService.Heartbeat:Connect(function()
		Plasma.start(root, function()
			Plasma.window({
				title = "Hello there this is a really long title",
				closable = closable,
				movable = movable,
				minSize = Vector2.new(300, 300),
			}, function()
				movable = Plasma.checkbox("movable"):checked()
				closable = Plasma.checkbox("closable"):checked()
			end)
		end)
	end)

	return function()
		connection:Disconnect()
		Plasma.start(root, function() end)
	end
end
