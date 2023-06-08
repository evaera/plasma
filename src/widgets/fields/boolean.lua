local checkbox = require(script.Parent.Parent.checkbox)
local Runtime = require(script.Parent.Parent.Parent.Runtime)
local field = require(script.Parent.field)

return Runtime.widget(function(label, value, options)
	field(label, { minCellSize = options.minCellSize, depth = options.depth }, function()
		if checkbox("", { checked = value }):clicked() then
			options.onUpdate(not value)
		end
	end)
end)
