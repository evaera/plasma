local input = require(script.Parent.Parent.input)
local Runtime = require(script.Parent.Parent.Parent.Runtime)
local field = require(script.Parent.field)

return Runtime.widget(function(label, value, options)
	field(label, { minCellSize = options.minCellSize, depth = options.depth }, function()
		local focusLost, enterPressed, inputText = input(value):focusLost()

		if focusLost and enterPressed then
			options.onUpdate(inputText)
		end
	end)
end)
