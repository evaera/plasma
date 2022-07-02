local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local function applyLayout(container, layout, options)
	local axis = options.axis or Enum.AutomaticSize.XY
	local maxSize = options.maxSize or Vector2.new(math.huge, math.huge)

	if typeof(maxSize) == "UDim2" then
		if container.Parent == nil then
			maxSize = Vector2.new(0, 0)
		else
			local parentSize = container.Parent.AbsoluteSize

			maxSize = Vector2.new(
				(parentSize.X / maxSize.X.Scale) + maxSize.X.Offset,
				(parentSize.Y / maxSize.Y.Scale) + maxSize.Y.Offset
			)
		end
	end

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
		local canvasX = x
		local canvasY = y

		if x.Offset > xClamped.Offset then
			canvasY -= UDim.new(0, container.ScrollBarThickness)
		end
		if y.Offset > yClamped.Offset then
			canvasX -= UDim.new(0, container.ScrollBarThickness)
		end

		container.CanvasSize = UDim2.new(canvasX, canvasY)
	end

	container.Size = UDim2.new(xClamped, yClamped)
end

local function trackParentSize(instance, callback)
	local parent = nil
	local connection = nil

	local function parentChanged(newParent)
		if parent == newParent then
			return
		end

		if connection ~= nil then
			connection:Disconnect()
			connection = nil
		end

		if newParent == nil then
			return
		end

		connection = newParent:GetPropertyChangedSignal("AbsoluteSize"):Connect(callback)
		parent = newParent
	end

	parentChanged(instance.Parent)

	instance:GetPropertyChangedSignal("Parent"):Connect(function()
		parentChanged(instance.Parent)
	end)
end

local defaultOptions = {}

--[=[
	@within Plasma
	@function automaticSize
	@param container GuiObject -- The instance to apply automatic sizing to.
	@param options { axis: Enum.AutomaticSize, maxSize: Vector2 | UDim2} | nil
	@tag utilities

	Applies padding-aware automatic size to the given GUI instance. This function sets up events to listen to further changes, so
	should only be called once per object.

	Also supports ScrollingFrames by correctly clamping actual and canvas sizes.

	:::note
	Automatic sizing cannot be applied on the server because clients have differing screen sizes.

	If this function is called from the server, it instead configures the instance to be compatible with the
	[Plasma.hydrateAutomaticSize] function, adding the CollectionService tag and other attributes.

	You must also call `hydrateAutomaticSize` once on the client for this to work.
	:::
]=]
local function automaticSize(container, options)
	options = options or defaultOptions

	if RunService:IsServer() then
		if options.maxSize then
			container:SetAttribute("maxSize", options.maxSize)
		end
		if options.axis then
			container:SetAttribute("axis", options.axis.Name)
		end

		CollectionService:AddTag(container, "PlasmaAutomaticSize")

		return
	end

	local layout = container:FindFirstChildWhichIsA("UIGridStyleLayout")

	applyLayout(container, layout, options)

	if typeof(options.maxSize) == "UDim2" then
		trackParentSize(container, function()
			applyLayout(container, layout, options)
		end)
	end

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		applyLayout(container, layout, options)
	end)
end

return automaticSize
