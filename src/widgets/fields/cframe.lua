local Runtime = require(script.Parent.Parent.Parent.Runtime)
local baseField = require(script.Parent.baseField)
local vector3 = require(script.Parent.vector3)

return Runtime.widget(function(key, value, options)
	local oX, oY, oZ = value:ToOrientation()

	local positionStr = tostring(value.Position)
	local orientationStr = `{oX}, {oY}, {oZ}`

	baseField(key, `{positionStr}, {orientationStr}`, {
		expandable = true,
		update = function(cframeString)
			local pattern = "(.+),(.+),(.+),(.+),(.+),(.+)"
			local x, y, z, rx, ry, rz = cframeString:gsub("%s+", ""):match(pattern)
			options.update(CFrame.new(x, y, z) * CFrame.fromOrientation(rx, ry, rz))
		end,
	}, function()
		vector3("Position", value.Position, {
			update = function(newPosition)
				options.update(CFrame.new(newPosition) * CFrame.fromOrientation(oX, oY, oZ))
			end,
		})

		vector3("Orientation", Vector3.new(oX, oY, oZ), {
			update = function(newOrientation)
				options.update(
					CFrame.new(value.Position)
						* CFrame.fromOrientation(newOrientation.X, newOrientation.Y, newOrientation.Z)
				)
			end,
		})
	end)
end)
