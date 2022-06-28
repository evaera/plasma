local Runtime = require(script.Parent.Parent.Runtime)
local create = require(script.Parent.Parent.create)

return Runtime.widget(function(size)
	local frame = Runtime.useInstance(function()
		return create("Frame", {
			BackgroundTransparency = 1,
		})
	end)

	Runtime.useEffect(function()
		frame.Size = UDim2.new(0, size, 0, size)
	end, size)
end)
