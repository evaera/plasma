local function applyLayout(container, layout, options)
	local axis = options.axis or Enum.AutomaticSize.XY
	local maxSize = options.maxSize or Vector2.new(math.huge, math.huge)

	local padX = 0
	local padY = 0
	local padding = container:FindFirstChildOfClass("UIPadding")
	if padding ~= nil then
		padX = padding.PaddingLeft.Offset + padding.PaddingRight.Offset
		padY = padding.PaddingTop.Offset + padding.PaddingBottom.Offset
	end

	local baseX = layout.AbsoluteContentSize.X + padX
	local baseY = layout.AbsoluteContentSize.Y + padY

	local x, y
	local xClamped, yClamped
	if axis == Enum.AutomaticSize.XY then
		x = UDim.new(0, baseX)
		y = UDim.new(0, baseY)
		xClamped = UDim.new(0, math.min(baseX, maxSize.X))
		yClamped = UDim.new(0, math.min(baseY, maxSize.Y))
	elseif axis == Enum.AutomaticSize.X then
		x = UDim.new(0, baseX)
		y = container.Size.Y
		xClamped = UDim.new(0, math.min(baseX, maxSize.X))
		yClamped = container.Size.Y
	else
		x = container.Size.X
		y = UDim.new(0, baseY)
		xClamped = container.Size.X
		yClamped = UDim.new(0, math.min(baseY, maxSize.Y))
	end

	if container:IsA("ScrollingFrame") then
		container.CanvasSize = UDim2.new(x, y)

		-- TODO: This isn't completely correct
		-- Need some solution here because the vertical scrollbar appearing also makes the horizontal scrollbar
		-- appear because the scrollbars take up space in the layout
		if x.Offset > xClamped.Offset then
			yClamped += UDim.new(0, container.ScrollBarThickness * 2)
		end
		if y.Offset > yClamped.Offset then
			xClamped += UDim.new(0, container.ScrollBarThickness * 2)
		end
	end

	container.Size = UDim2.new(xClamped, yClamped)
end

local defaultOptions = {}

--[=[
	@within Plasma
	@function automaticSize
	@param container GuiObject -- The instance to apply automatic sizing to.
	@param options { axis: Enum.AutomaticSize, maxSize: Vector2} | nil
	@tag utilities

	Applies padding-aware automatic size to the given GUI instance. This function sets up events to listen to further changes, so
	should only be called once per object.

	Also supports ScrollingFrames by correctly clamping actual and canvas sizes.
]=]
local function automaticSize(container, options)
	options = options or defaultOptions

	local layout = container:FindFirstChildWhichIsA("UIGridStyleLayout")
	applyLayout(container, layout, options)

	return layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		applyLayout(container, layout, options)
	end)
end

return automaticSize
