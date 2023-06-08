local input = require(script.Parent.Parent.input)
local Runtime = require(script.Parent.Parent.Parent.Runtime)
local field = require(script.Parent.field)
local vector3 = require(script.Parent.vector3)

return Runtime.widget(function(label, value, options)
	local oX, oY, oZ = value:ToOrientation()

	local expanded = field(label, { expandable = true, minCellSize = options.minCellSize }, function()
		local positionStr = tostring(value.Position)
		local orientationStr = `{oX}, {oY}, {oZ}`

		local focusLost, enterPressed, inputText = input(positionStr .. "," .. orientationStr):focusLost()

		if focusLost and enterPressed then
			local pattern = "(.+),(.+),(.+),(.+),(.+),(.+)"
			local x, y, z, rx, ry, rz = inputText:gsub("%s+", ""):match(pattern)
			options.onUpdate(CFrame.new(x, y, z) * CFrame.fromOrientation(rx, ry, rz))
		end
	end):expanded()

	if not expanded then
		return
	end

	vector3("Position", value.Position, {
		depth = options.depth + 1,
		minCellSize = options.minCellSize,
		onUpdate = function(newPos)
			options.onUpdate(CFrame.new(newPos) * CFrame.fromOrientation(oX, oY, oZ))
		end,
	})
	vector3("Orientation", Vector3.new(oX, oY, oZ), {
		depth = options.depth + 1,
		minCellSize = options.minCellSize,
		onUpdate = function(newOrient)
			options.onUpdate(CFrame.new(value.Position) * CFrame.fromOrientation(newOrient.X, newOrient.Y, newOrient.Z))
		end,
	})
end)
