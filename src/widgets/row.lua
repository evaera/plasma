local Runtime = require(script.Parent.Parent.Runtime)

return Runtime.widget(function(options, fn)
	if type(options) == "function" and fn == nil then
		fn = options
		options = {}
	end

	if options.padding then
		if type(options.padding) == "number" then
			options.padding = UDim.new(0, options.padding)
		end
	else
		options.padding = UDim.new(0, 10)
	end

	Runtime.useInstance(function()
		local Frame = Instance.new("Frame")
		Frame.BackgroundTransparency = 1
		Frame.AutomaticSize = Enum.AutomaticSize.XY

		local UIListLayout = Instance.new("UIListLayout")
		UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout.FillDirection = Enum.FillDirection.Horizontal
		UIListLayout.Padding = options.padding
		UIListLayout.Parent = Frame

		return Frame
	end)

	Runtime.scope(fn)
end)
