local Runtime = require(script.Parent.Parent.Parent.Runtime)
local baseField = require(script.Parent.baseField)

return Runtime.widget(function(key, value, options)
	baseField(key, tostring(value), {
		expandable = true,
		update = function(vector3String)
			local pattern = "(.+),(.+),(.+)"
 			local x, y, z = vector3String:gsub("%s+",""):match(pattern)
			options.update(Vector3.new(x,y,z))
		end
	}, function()

		 baseField("X", value.X, {
			update = function(x)
				options.update(Vector3.new(x, value.Y, value.Z))
			end
		 })

		 baseField("Y", value.Y, {
			update = function(y)
				options.update(Vector3.new(value.X, y, value.Z))
			end
		 })

		 baseField("Z", value.Z, {
			update = function(z)
				options.update(Vector3.new(value.X, value.Y, z))
			end
		 })
	end)
end)
