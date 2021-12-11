---
sidebar_position: 2
---

# Getting Started

Your UI code is intended to run on every frame. To get started with Plasma, the first step is to set up an event loop:

```lua
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
```

![Example](https://i.eryn.io/2150/RobloxStudioBeta-hHIjzTo6.png)

In the above code sample, we call `Plasma.new`, passing in the root instance where we want our UI to end up, in this case it's a ScreenGui.

`Plasma.new` returns an object which holds state about our UI. You don't need to interact with this object, just keep it around so we can pass it into Plasma later.

We create an event connected to Heartbeat, and every heartbeat event, we call `Plasma.start` with our `root` and a function that creates the UI.

The function we pass to `Plasma.start` cannot yield (doing so will error). Inside, we can create our UI using Plasma's [widgets](/api/Plasma#arrow).

From here, you should look at the [API reference](/api/Plasma) to check out all the other available widgets!