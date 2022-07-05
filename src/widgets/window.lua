local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

--[=[
	@interface WindowOptions
	@within Plasma

	.title? string
	.closable? boolean
	.movable? boolean
	.resizable? boolean
]=]

--[=[
	@within Plasma
	@function window
	@param options string | WindowOptions -- The title of the window, or options
	@param children () -> () -- Children
	@tag widgets
	@return WindowWidgetHandle

	A window widget. Contains children.

	- Closable
	- Draggable
	- Resizable

	Returns a widget handle, which has the field:

	- `closed`, a function you can call to check if the close button was clicked.

	![Window with checkboxes](https://i.eryn.io/2150/TVkkOnxj.png)
]=]

local Runtime = require(script.Parent.Parent.Runtime)
local createConnect = require(script.Parent.Parent.createConnect)
local Style = require(script.Parent.Parent.Style)
local automaticSize = require(script.Parent.Parent.automaticSize)
local c = require(script.Parent.Parent.create)

local MIN_SIZE = Vector2.new(50, 50)

return Runtime.widget(function(options, fn)
	local closed, setClosed = Runtime.useState(false)

	local refs = Runtime.useInstance(function(ref)
		local style = Style.get()

		local dragConnection

		local connect = createConnect()

		c("Frame", {
			[ref] = "frame",
			BackgroundColor3 = style.bg2,
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(0, 50, 0, 40),

			c("UICorner", {}),

			c("UIPadding", {
				PaddingBottom = UDim.new(0, 20),
				PaddingLeft = UDim.new(0, 20),
				PaddingRight = UDim.new(0, 20),
				PaddingTop = UDim.new(0, 20),
			}),

			c("UIStroke", {}),

			c("TextButton", {
				[ref] = "titleBar",
				Size = UDim2.new(1, 0, 0, 40),
				BackgroundTransparency = 1,
				Text = "",

				InputBegan = function(clickInput)
					if not ref.titleBar.Active then
						return
					end
					if clickInput.UserInputType ~= Enum.UserInputType.MouseButton1 then
						return
					end

					local lastMousePosition = clickInput.Position

					if
						ref.frame.Parent:FindFirstChildWhichIsA("UIGridStyleLayout")
						and not ref.frame.Parent:IsA("ScreenGui")
					then
						local beforePosition = ref.frame.AbsolutePosition

						local screenGui = ref.frame:FindFirstAncestorOfClass("ScreenGui")

						if screenGui.IgnoreGuiInset then
							beforePosition += GuiService:GetGuiInset()
						end

						ref.frame.Parent = screenGui
						ref.frame.Position = UDim2.new(0, beforePosition.X, 0, beforePosition.Y)
					end

					dragConnection = connect(UserInputService, "InputChanged", function(moveInput)
						local delta = lastMousePosition - moveInput.Position

						lastMousePosition = moveInput.Position

						ref.frame.Position = ref.frame.Position - UDim2.new(0, delta.X, 0, delta.Y)
					end)
				end,

				InputEnded = function(input)
					if dragConnection and input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragConnection:Disconnect()
						dragConnection = nil
					end
				end,

				c("Frame", {
					[ref] = "handle",
					Position = UDim2.new(0, -5, 0, 0),

					c("TextLabel", {
						Text = "..",
						Position = UDim2.new(0, 0, 0, 0),
						BackgroundTransparency = 1,
						TextSize = 20,
						TextColor3 = style.mutedTextColor,
					}),

					c("TextLabel", {
						Text = "..",
						Position = UDim2.new(0, 0, 0, 7),
						BackgroundTransparency = 1,
						TextSize = 20,
						TextColor3 = style.mutedTextColor,
					}),

					c("TextLabel", {
						Text = "..",
						Position = UDim2.new(0, 0, 0, -7),
						BackgroundTransparency = 1,
						TextSize = 20,
						TextColor3 = style.mutedTextColor,
					}),
				}),

				c("TextLabel", {
					[ref] = "title",
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBold,
					Size = UDim2.new(1, 0, 1, 0),
					TextColor3 = style.mutedTextColor,
					TextSize = 20,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					TextTruncate = Enum.TextTruncate.AtEnd,
					RichText = true,
				}),

				c("TextButton", {
					[ref] = "close",
					BackgroundColor3 = Color3.fromHex("e74c3c"),
					Size = UDim2.new(0, 20, 0, 20),
					Text = "",
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.new(1, -10, 0, 0),
					TextColor3 = Color3.fromHex("#71190f"),
					TextSize = 20,
					Font = Enum.Font.Gotham,

					MouseEnter = function()
						ref.close.Text = "x"
					end,

					MouseLeave = function()
						ref.close.Text = ""
					end,

					Activated = function()
						setClosed(true)
					end,

					c("UICorner", {
						CornerRadius = UDim.new(1, 0),
					}),
				}),
			}),

			c("ScrollingFrame", {
				[ref] = "container",
				BackgroundTransparency = 1,
				VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
				HorizontalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
				BorderSizePixel = 0,
				ScrollBarThickness = 6,
				Position = UDim2.new(0, 0, 0, 40),

				c("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 10),
				}),
			}),

			c("TextButton", {
				[ref] = "resizeHandle",
				Size = UDim2.new(0, 20, 0, 20),
				Text = "≡",
				Font = Enum.Font.SourceSans,
				TextSize = 20,
				Rotation = -45,
				BackgroundTransparency = 1,
				TextColor3 = style.mutedTextColor,
				Position = UDim2.new(1, 0, 1, 0),

				InputBegan = function(clickInput)
					if clickInput.UserInputType ~= Enum.UserInputType.MouseButton1 then
						return
					end

					local initialMousePosition = clickInput.Position
					local initialSize = ref.container.AbsoluteSize

					dragConnection = connect(UserInputService, "InputChanged", function(moveInput)
						if moveInput.UserInputType ~= Enum.UserInputType.MouseMovement then
							return
						end

						local delta = Vector2.new(
							(moveInput.Position.X - initialMousePosition.X),
							(moveInput.Position.Y - initialMousePosition.Y)
						)

						local size = initialSize + delta

						ref.container:SetAttribute(
							"maxSize",
							Vector2.new(math.max(MIN_SIZE.X, size.X), math.max(MIN_SIZE.Y, size.Y))
						)
					end)
				end,

				InputEnded = function(input)
					if dragConnection and input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragConnection:Disconnect()
						dragConnection = nil
					end
				end,
			}),
		})

		automaticSize(ref.container)
		automaticSize(ref.frame)

		return ref.frame, ref.container
	end)

	if type(options) == "string" then
		options = {
			title = options,
		}
	end

	local movable = if options.movable ~= nil then options.movable else true
	local resizable = if options.resizable ~= nil then options.movable else true

	refs.close.Visible = options.closable or false
	refs.handle.Visible = movable
	refs.titleBar.Active = movable
	refs.resizeHandle.Visible = resizable

	refs.title.Size = UDim2.new(1, if options.closable then -30 else 0, 1, 0)

	local spaces = if movable then "  " else ""
	refs.title.Text = options.title and spaces .. string.upper(options.title) or ""

	Runtime.useEffect(function()
		refs.container:SetAttribute("maxSize", options.maxSize or Vector2.new(2000, 500))
	end, options.maxSize)

	Runtime.useEffect(function()
		refs.container:SetAttribute("minSize", options.minSize)
	end, options.minSize)

	Runtime.scope(fn)

	local handle = {
		closed = function()
			if closed then
				setClosed(false)
				return true
			end

			return false
		end,
	}

	return handle
end)
