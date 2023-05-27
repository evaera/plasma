local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Plasma = require(ReplicatedStorage.Plasma)
local window = Plasma.window
local dictionary = Plasma.dictionary

return function(target)
	local root = Plasma.new(target)

	local class = {}
	class.__index = class

	function class.new()
		local t = setmetatable({}, class)

		t.field = "this is a field"

		return t
	end

	local dict = {
		vector3 = Vector3.new(),
		tbl = {
			nested_tbl = { "first element in array is a string" },
		},
		fn = function() end,
		class_instance = class.new(),
		cf = CFrame.new(),
	}

	local connection = RunService.Heartbeat:Connect(function()
		Plasma.start(root, function()
			window({
				title = "Dictionary",
			}, function()
				dictionary(dict, {
					alignFields = true,
					minCellSize = Vector2.new(300, 40),
					update = function(new)
						local newDict = table.clone(dict)

						for k, v in new do
							newDict[k] = v
						end

						dict = newDict
					end,
				})
			end)
		end)
	end)

	return function()
		connection:Disconnect()
		Plasma.start(root, function() end)
	end
end
