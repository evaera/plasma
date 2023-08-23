local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local function applyLayout(container, layout)
	local axisName = container:GetAttribute("axis") or "XY"
	local axis = Enum.AutomaticSize[axisName]

	local maxSize = container:GetAttribute("maxSize") or Vector2.new(math.huge, math.huge)
	local minSize = container:GetAttribute("minSize") or Vector2.new(0, 0)

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

	local contentSize

	if layout then
		contentSize = layout.AbsoluteContentSize
	elseif container:IsA("TextButton") or container:IsA("TextLabel") then
		contentSize = container.TextBounds
	else
		contentSize = Vector2.new(0, 0)

		for _, child in container:GetChildren() do
			if child:IsA("GuiObject") then
				local farX = child.Position.X.Offset + child.Size.X.Offset
				local farY = child.Position.Y.Offset + child.Size.Y.Offset

				contentSize = Vector2.new(math.max(contentSize.X, farX), math.max(contentSize.Y, farY))
			end
		end
	end

	local baseX = math.max(contentSize.X + padX, minSize.X)
	local baseY = math.max(contentSize.Y + padY, minSize.Y)

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
	@param options { axis: Enum.AutomaticSize, maxSize: Vector2 | UDim2, minSize: Vector2 } | nil
	@tag utilities

	Applies padding-aware automatic size to the given GUI instance. This function sets up events to listen to further changes, so
	should only be called once per object.

	Also supports ScrollingFrames by correctly clamping actual and canvas sizes.

	:::note
	If this function is called from the server, if `maxSize` is a UDim2, because of differing screen sizes, it instead
	configures the instance to be compatible with the [Plasma.hydrateAutomaticSize] function, adding the
	CollectionService tag and other attributes.

	You must also call `hydrateAutomaticSize` once on the client for this to work.
	:::

	::warning
	There is currently no way to undo this other than destroying the instance. Once automatic sizing has been applied,
	it is always applied to that instance.
	:::
]=]
local function automaticSize(container, options)
	options = options or defaultOptions

	if options.maxSize then
		container:SetAttribute("maxSize", options.maxSize)
	end

	if options.minSize then
		container:SetAttribute("minSize", options.minSize)
	end

	if options.axis then
		container:SetAttribute("axis", options.axis.Name)
	end

	if not RunService:IsClient() and typeof(container:GetAttribute("maxSize") or nil) == "UDim2" then
		CollectionService:AddTag(container, "PlasmaAutomaticSize")

		return
	end

	local layout = container:FindFirstChildWhichIsA("UIGridStyleLayout")

	applyLayout(container, layout)

	if typeof(container:GetAttribute("maxSize") or nil) == "UDim2" then
		trackParentSize(container, function()
			applyLayout(container, layout)
		end)
	end

	if layout then
		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			applyLayout(container, layout)
		end)
	elseif container:IsA("TextLabel") or container:IsA("TextButton") then
		container:GetPropertyChangedSignal("TextBounds"):Connect(function()
			applyLayout(container)
		end)
	else
		local function connect(child)
			if child:IsA("GuiObject") then
				child:GetPropertyChangedSignal("Size"):Connect(function()
					applyLayout(container)
				end)
			end
		end

		for _, child in container:GetChildren() do
			connect(child)
		end

		container.ChildAdded:Connect(function(child)
			applyLayout(container)

			connect(child)
		end)

		container.ChildRemoved:Connect(function()
			applyLayout(container)
		end)
	end

	container:GetAttributeChangedSignal("maxSize"):Connect(function()
		applyLayout(container, layout)
	end)

	container:GetAttributeChangedSignal("minSize"):Connect(function()
		applyLayout(container, layout)
	end)
end

return automaticSize
