local UserInputService = game:GetService("UserInputService")

local Runtime = require(script.Parent.Parent.Runtime)
local Style = require(script.Parent.Parent.Style)
local create = require(script.Parent.Parent.create)

return Runtime.widget(function(max)
	local value, setValue = Runtime.useState(0)

	Runtime.useInstance(function()
		local style = Style.get()

		local frame = create("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 200, 0, 30),

			create("Frame", {
				Name = "line",
				Size = UDim2.new(1, 0, 0, 2),
				BackgroundColor3 = style.mutedTextColor,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 0.5, 0),
			}),

			create("TextButton", {
				Name = "dot",
				Size = UDim2.new(0, 15, 0, 15),
				BackgroundColor3 = style.textColor,
				Position = UDim2.new(0, 0, 0.5, -7),
				Text = "",

				create("UICorner", {
					CornerRadius = UDim.new(1, 0),
				}),
			}),
		})

		local inputs = {}

		frame.dot.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
				return
			end

			inputs[input] = UserInputService.InputChanged:Connect(function(moveInput)
				if moveInput.UserInputType ~= Enum.UserInputType.MouseMovement then
					return
				end

				local x = UserInputService:GetMouseLocation().X

				x -= frame.AbsolutePosition.X
				x = math.clamp(x, 0, frame.AbsoluteSize.X)

				local percent = x / frame.AbsoluteSize.X

				frame.dot.Position = UDim2.new(0, x, 0.5, -7)

				setValue(percent * max)
			end)
		end)

		frame.dot.InputEnded:Connect(function(input)
			if inputs[input] then
				inputs[input]:Disconnect()
			end
		end)

		return frame
	end)

	return value
end)
