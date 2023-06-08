local input = require(script.Parent.Parent.input)
local Runtime = require(script.Parent.Parent.Parent.Runtime)
local field = require(script.Parent.field)

return Runtime.widget(function(label, value, options)
	local expanded = field(
		label,
		{ expandable = true, minCellSize = options.minCellSize, depth = options.depth },
		function()
			local focusLost, enterPressed, inputText = input(tostring(value)):focusLost()

			if focusLost and enterPressed then
				local pattern = "(.+),(.+),(.+)"
				local x, y, z = inputText:gsub("%s+", ""):match(pattern)
				options.onUpdate(Vector3.new(x, y, z))
			end
		end
	):expanded()

	if not expanded then
		return
	end

	local childOptions = { depth = options.depth + 1, minCellSize = options.minCellSize }

	field("X", childOptions, function()
		local focusLost, enterPressed, inputText = input(value.X):focusLost()

		if focusLost and enterPressed then
			options.onUpdate(Vector3.new(inputText, value.Y, value.Z))
		end
	end)

	field("Y", childOptions, function()
		local focusLost, enterPressed, inputText = input(value.Y):focusLost()

		if focusLost and enterPressed then
			options.onUpdate(Vector3.new(value.X, inputText, value.Z))
		end
	end)

	field("Z", childOptions, function()
		local focusLost, enterPressed, inputText = input(value.Z):focusLost()

		if focusLost and enterPressed then
			options.onUpdate(Vector3.new(value.X, value.Y, inputText))
		end
	end)
end)
