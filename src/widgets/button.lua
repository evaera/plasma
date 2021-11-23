local Runtime = require(script.Parent.Parent.Runtime)

return Runtime.widget(function(text)
	local clicked, setClicked = Runtime.useState(false)
	local instance = Runtime.useInstance(function()
		local TextButton = Instance.new("TextButton")
		TextButton.BackgroundColor3 = Color3.fromRGB(54, 54, 54)
		TextButton.BorderSizePixel = 0
		TextButton.Font = Enum.Font.SourceSans
		TextButton.Size = UDim2.new(0, 200, 0, 50)
		TextButton.TextColor3 = Color3.fromRGB(153, 153, 153)
		TextButton.TextSize = 21

		local UICorner = Instance.new("UICorner")
		UICorner.Parent = TextButton

		TextButton.Activated:Connect(function()
			setClicked(true)
		end)

		return TextButton
	end)

	instance.Text = text

	instance.LayoutOrder = Runtime.childNumber()

	local handle = {
		clicked = function()
			if clicked then
				setClicked(false)
				return true
			end

			return false
		end,
	}

	return handle
end)
