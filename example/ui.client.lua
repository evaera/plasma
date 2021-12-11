local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local Plasma = require(ReplicatedStorage.Plasma)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Plasma"
screenGui.Parent = PlayerGui

local root = Plasma.new(screenGui)

RunService.Heartbeat:Connect(function()
	Plasma.start(root, function()
		Plasma.window("Hello plasma!", function()
			if Plasma.button("Say hello"):clicked() then
				print("Hello world!")
			end
		end)
	end)
end)
