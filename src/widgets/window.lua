local Runtime = require(script.Parent.Parent.Runtime)

return Runtime.widget(function(state, title, fn)
	if state.instance == nil then
		local Frame = Instance.new("Frame")
		Frame.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
		Frame.Position = UDim2.new(0.3218587, 0, 0.2729408, 0)
		Frame.Size = UDim2.new(0, 885, 0, 403)

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
		TextLabel.TextColor3 = Color3.fromRGB(147, 147, 147)
		TextLabel.TextSize = 20
		TextLabel.TextXAlignment = Enum.TextXAlignment.Left
		TextLabel.TextYAlignment = Enum.TextYAlignment.Top
		TextLabel.Parent = Frame

		local Container = Instance.new("Frame")
		Container.BackgroundTransparency = 1
		Container.Name = "Container"
		Container.Parent = Frame

		state.instance = Frame

		Frame.Parent = Runtime.parentInstance()
	end

	state.instance.TextLabel.Text = title or ""

	Runtime.scope(fn)
end)
