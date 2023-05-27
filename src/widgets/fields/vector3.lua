local Runtime = require(script.Parent.Parent.Parent.Runtime)
local baseField = require(script.Parent.baseField)

return Runtime.widget(function(key, value, options)
	baseField(key, tostring(value), {
		expandable = true,
		onUpdate = function(vector3String)
			local pattern = "(.+),(.+),(.+)"
			local x, y, z = vector3String:gsub("%s+", ""):match(pattern)
			options.onUpdate(Vector3.new(x, y, z))
		end,
	}, function()
		baseField("X", value.X, {
			onUpdate = function(x)
				options.onUpdate(Vector3.new(x, value.Y, value.Z))
			end,
		})

		baseField("Y", value.Y, {
			update = function(y)
				options.onUpdate(Vector3.new(value.X, y, value.Z))
			end,
		})

		baseField("Z", value.Z, {
			update = function(z)
				options.onUpdate(Vector3.new(value.X, value.Y, z))
			end,
		})
	end)
end)
