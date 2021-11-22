local Runtime = require(script.Parent.Parent.Runtime)

return Runtime.widget(function(state, text)
	if state.instance == nil then
		local TextButton = Instance.new("TextButton")
		TextButton.BackgroundColor3 = Color3.fromRGB(54, 54, 54)
		TextButton.BorderSizePixel = 0
		TextButton.Font = Enum.Font.SourceSans
		TextButton.Size = UDim2.new(0, 200, 0, 50)
		TextButton.TextColor3 = Color3.fromRGB(153, 153, 153)
		TextButton.TextSize = 21

		local UICorner = Instance.new("UICorner")
		UICorner.Parent = TextButton

		state.clicked = false
		state.instance = TextButton

		TextButton.Activated:Connect(function()
			state.clicked = true
		end)

		TextButton.Parent = Runtime.parentInstance()
	end

	state.instance.Text = text

	local handle = {
		clicked = function()
			if state.clicked then
				state.clicked = false
				return true
			end

			return false
		end,
	}

	return handle
end)
