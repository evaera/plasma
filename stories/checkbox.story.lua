local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Plasma = require(ReplicatedStorage.Plasma)

return function(target)
	local root = Plasma.new(target)

	local checked = false

	local connection = RunService.Heartbeat:Connect(function()
		Plasma.start(root, function()
			Plasma.window("Checkboxes", function()
				if Plasma.checkbox("Controlled checkbox", {
					checked = checked,
				}):clicked() then
					checked = not checked
				end

				Plasma.checkbox("Disabled checkbox", {
					checked = checked,
					disabled = true,
				})

				Plasma.checkbox("Uncontrolled checkbox")
			end)
		end)
	end)

	return function()
		connection:Disconnect()
		Plasma.start(root, function() end)
	end
end
