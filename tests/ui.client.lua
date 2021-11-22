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

RunService.Heartbeat:Connect(function()
	root = Plasma.start(root, function(state)
		state.times = state.times or 0

		Plasma.window("title", function()
			if Plasma.button("Hello " .. state.times):clicked() then
				state.times += 1
			end
		end)
	end)
end)
