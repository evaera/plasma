--[=[
	@within Plasma
	@function window
	@param title string -- The title of the window
	@param children () -> () -- Children
	@tag widgets

	A window widget. Contains children.

	In the future:
	- Closable
	- Draggable
	- Resizable

	![Window with checkboxes](https://i.eryn.io/2150/TVkkOnxj.png)
]=]

local Runtime = require(script.Parent.Parent.Runtime)
local Style = require(script.Parent.Parent.Style)
local automaticSize = require(script.Parent.Parent.automaticSize)

return Runtime.widget(function(title, fn)
	local instance = Runtime.useInstance(function()
		local style = Style.get()

		local Frame = Instance.new("Frame")
		Frame.BackgroundColor3 = style.bg2
		Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
		Frame.AnchorPoint = Vector2.new(0.5, 0.5)
		Frame.Size = UDim2.new(0, 50, 0, 40)

		local UICorner = Instance.new("UICorner")
		UICorner.Parent = Frame

		local UIPadding = Instance.new("UIPadding")
		UIPadding.PaddingBottom = UDim.new(0, 20)
		UIPadding.PaddingLeft = UDim.new(0, 20)
		UIPadding.PaddingRight = UDim.new(0, 20)
		UIPadding.PaddingTop = UDim.new(0, 20)
		UIPadding.Parent = Frame

		local UIStroke = Instance.new("UIStroke")
		UIStroke.Parent = Frame

		local UIListLayout = Instance.new("UIListLayout")
		UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout.Parent = Frame

		local TextLabel = Instance.new("TextLabel")
		TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TextLabel.BackgroundTransparency = 1
		TextLabel.Font = Enum.Font.GothamBold
		TextLabel.Size = UDim2.new(0, 200, 0, 40)
		TextLabel.TextColor3 = style.mutedTextColor
		TextLabel.TextSize = 20
		TextLabel.TextXAlignment = Enum.TextXAlignment.Left
		TextLabel.TextYAlignment = Enum.TextYAlignment.Top
		TextLabel.Parent = Frame

		local Container = Instance.new("ScrollingFrame")
		Container.BackgroundTransparency = 1
		Container.Name = "Container"
		Container.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
		Container.HorizontalScrollBarInset = Enum.ScrollBarInset.ScrollBar
		Container.BorderSizePixel = 0
		Container.ScrollBarThickness = 6
		Container.Parent = Frame

		local UIListLayout2 = Instance.new("UIListLayout")
		UIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout2.Parent = Container
		UIListLayout2.Padding = UDim.new(0, 10)

		automaticSize(Frame)
		automaticSize(Container, {
			maxSize = Vector2.new(math.huge, 500),
		})

		return Frame, Container
	end)

	instance.TextLabel.Text = title and string.upper(title) or ""

	Runtime.scope(fn)
end)
