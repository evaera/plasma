local FieldValueType = require(script.Parent.FieldValueType)

return {
	["boolean"] = {
		fieldValueType = FieldValueType.CHECKBOX,
	},
	["string"] = {
		fieldValueType = FieldValueType.INPUT,
	},
	["number"] = {
		fieldValueType = FieldValueType.INPUT,
		transform = function(strNum)
			return tonumber(strNum)
		end,
	},
	["table"] = {
		expandable = true,
		fieldValueType = FieldValueType.LABEL,
		formatValue = function()
			return "TABLE_VALUE"
		end,
	},
	["function"] = {
		fieldValueType = FieldValueType.LABEL,
		formatValue = function()
			return "FUNCTION_VALUE"
		end,
	},
	["CFrame"] = {
		fieldValueType = FieldValueType.INPUT,
		formatValue = function(value)
			local oX, oY, oZ = value:ToOrientation()
			local positionStr = tostring(value.Position)
			local orientationStr = `{oX}, {oY}, {oZ}`
			return `{positionStr}, {orientationStr}`
		end,
		transform = function(cframeString)
			local pattern = "(.+),(.+),(.+),(.+),(.+),(.+)"
			local x, y, z, rx, ry, rz = cframeString:gsub("%s+", ""):match(pattern)
			return CFrame.new(x, y, z) * CFrame.fromOrientation(rx, ry, rz)
		end,
		components = {
			{
				label = "Position",
				getValue = function(cf)
					return cf.Position
				end,
				transform = function(position, cf)
					return CFrame.new(position) * cf.Rotation
				end,
			},
			{
				label = "Orientation",
				getValue = function(cf)
					return cf.Position
				end,
				transform = function(orientation, cf)
					return CFrame.new(cf.Position) * CFrame.fromOrientation(orientation.X, orientation.Y, orientation.Z)
				end,
			},
		},
	},
	["Vector3"] = {
		fieldValueType = FieldValueType.INPUT,
		formatValue = function(value)
			return tostring(value)
		end,
		transform = function(vector3String)
			local pattern = "(.+),(.+),(.+)"
			local x, y, z = vector3String:gsub("%s+", ""):match(pattern)
			return Vector3.new(x, y, z)
		end,
		components = {
			{
				label = "X",
				getValue = function(vector)
					return vector.X
				end,
				transform = function(x, vector)
					return Vector3.new(x, vector.Y, vector.Z)
				end,
			},
			{
				label = "Y",
				getValue = function(vector)
					return vector.Y
				end,
				transform = function(y, vector)
					return Vector3.new(vector.X, y, vector.Z)
				end,
			},
			{
				label = "Z",
				getValue = function(vector)
					return vector.Z
				end,
				transform = function(z, vector)
					return Vector3.new(vector.X, vector.Y, z)
				end,
			},
		},
	},
}
