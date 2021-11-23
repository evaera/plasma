local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local Plasma = require(ReplicatedStorage.Plasma)

-- local plasma = Plasma.new()
-- local ui = plasma:begin()

-- ui:window("title", function()
-- 	ui:columns(function()
-- 		if ui:button("Delete item"):clicked() then
-- 		end
-- 	end)
-- end)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Plasma Test"
screenGui.Parent = PlayerGui

local root = Plasma.new(screenGui)
local lastShown = 0

RunService.Heartbeat:Connect(function()
	local outer
	Plasma.start(root, function()
		local buttonCount, setButtonCount = Plasma.useState(1)

		Plasma.window("Window Title!", function()
			for i = 1, buttonCount do
				if Plasma.button("Button " .. i):clicked() then
					setButtonCount(buttonCount + 1)
				end
			end
		end)

		if buttonCount % 2 == 0 then
			Plasma.blur(50)
		end

		outer = buttonCount
	end)

	if lastShown ~= outer then
		lastShown = outer
		print(root)
	end
end)
