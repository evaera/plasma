local UserInputService = game:GetService("UserInputService")

local Runtime = require(script.Parent.Parent.Runtime)
local Style = require(script.Parent.Parent.Style)
local create = require(script.Parent.Parent.create)

return Runtime.widget(function(options)
	if type(options) == "number" then
		options = {
			max = options,
		}
	end

	local min = options.min or 0
	local max = options.max or 1
	local value, setValue = Runtime.useState(options.initial or 0)

	local refs = Runtime.useInstance(function(ref)
		local style = Style.get()

		local frame = create("Frame", {
			[ref] = "frame",
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
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = style.textColor,
				Position = UDim2.new(0, 0, 0.5, 0),
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

				local maxPos = frame.AbsoluteSize.X - frame.dot.AbsoluteSize.X
				x -= frame.AbsolutePosition.X + frame.dot.AbsoluteSize.X / 2
				x = math.clamp(x, 0, maxPos)

				local percent = x / maxPos

				setValue(percent * (max - min) + min)
			end)
		end)

		frame.dot.InputEnded:Connect(function(input)
			if inputs[input] then
				inputs[input]:Disconnect()
			end
		end)

		return frame
	end)

	local maxPos = refs.frame.AbsoluteSize.X - refs.frame.dot.AbsoluteSize.X
	local percent = (value - min) / (max - min)
	refs.frame.dot.Position = UDim2.new(0, percent * maxPos + refs.frame.dot.AbsoluteSize.X / 2, 0.5, 0)

	return value
end)
