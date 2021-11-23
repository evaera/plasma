local Runtime = require(script.Parent.Parent.Runtime)
local Style = require(script.Parent.Parent.Style)
local create = require(script.Parent.Parent.create)

return Runtime.widget(function(text, options)
	options = options or {}

	local checked, setChecked = Runtime.useState(false)
	local clicked, setClicked = Runtime.useState(false)

	local instance = Runtime.useInstance(function()
		local Checkbox = create("Frame", {
			BackgroundTransparency = 1,
			Name = "Checkbox",
			Size = UDim2.new(0, 30, 0, 30),
			AutomaticSize = Enum.AutomaticSize.X,

			create("TextButton", {
				BackgroundColor3 = Color3.fromRGB(54, 54, 54),
				BorderSizePixel = 0,
				Font = Enum.Font.SourceSansBold,
				Size = UDim2.new(0, 30, 0, 30),
				TextColor3 = Color3.fromRGB(153, 153, 153),
				TextSize = 24,

				create("UICorner", {
					CornerRadius = UDim.new(0, 8),
				}),

				Activated = function()
					setClicked(true)
					setChecked(function(currentlyChecked)
						return not currentlyChecked
					end)
				end,
			}),

			create("TextLabel", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.GothamSemibold,
				TextColor3 = Color3.fromRGB(203, 203, 203),
				TextSize = 18,
				AutomaticSize = Enum.AutomaticSize.X,
			}),

			create("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 10),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
		})

		return Checkbox
	end)

	instance.TextLabel.Text = text
	instance.TextButton.AutoButtonColor = not options.disabled

	Runtime.useEffect(function()
		local isChecked
		if options.checked ~= nil then
			isChecked = options.checked
		else
			isChecked = checked
		end

		instance.TextButton.Text = isChecked and "✓" or ""
	end, {
		options.checked,
		checked,
	})

	Runtime.useEffect(function()
		instance.TextButton.BackgroundColor3 = options.disabled and Color3.fromRGB(112, 112, 112)
			or Color3.fromRGB(54, 54, 54)
	end, {
		options.disabled,
	})

	local handle = {
		checked = function()
			if options.checked or checked then
				return true
			end

			return false
		end,
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
