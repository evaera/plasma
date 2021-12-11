--[=[
	@within Plasma
	@function row
	@tag widgets
	@param options {padding: Vector2}
	@param children () -> () -- Children

	Lays out children horizontally
]=]

local Runtime = require(script.Parent.Parent.Runtime)
local automaticSize = require(script.Parent.Parent.automaticSize)

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

	local frame = Runtime.useInstance(function()
		local Frame = Instance.new("Frame")
		Frame.BackgroundTransparency = 1

		local UIListLayout = Instance.new("UIListLayout")
		UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout.FillDirection = Enum.FillDirection.Horizontal
		UIListLayout.Padding = options.padding
		UIListLayout.Parent = Frame

		automaticSize(Frame)

		return Frame
	end)

	frame.UIListLayout.HorizontalAlignment = options.alignment or Enum.HorizontalAlignment.Left

	Runtime.scope(fn)
end)
