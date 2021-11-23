local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local Plasma = require(ReplicatedStorage.Plasma)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Plasma Test"
screenGui.Parent = PlayerGui

local root = Plasma.new(screenGui)
local lastShown = 0

RunService.Heartbeat:Connect(function()
	local outer
	Plasma.start(root, function()
		Plasma.setStyle({
			-- bg2 = Color3.fromRGB(18, 231, 99),
		})

		local buttonCount, setButtonCount = Plasma.useState(1)

		Plasma.window("Window Title!", function()
			for i = 1, buttonCount do
				if Plasma.button(string.format("Button %d (%s)", i, tostring(buttonCount % i == 0))):clicked() then
					setButtonCount(buttonCount + 1)
				end
				if i == 1 then
					Plasma.spinner()
				end
			end
			Plasma.spinner()
		end)

		if buttonCount % 2 == 0 then
			Plasma.blur(50)
		end

		outer = buttonCount
	end)

	if lastShown ~= outer then
		lastShown = outer
		-- print(root)
	end
end)
