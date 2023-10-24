local UserInputService = game:GetService("UserInputService")

local Runtime = require(script.Parent.Parent.Runtime)
local Style = require(script.Parent.Parent.Style)
local create = require(script.Parent.Parent.create)
local createConnect = require(script.Parent.Parent.createConnect)

return Runtime.widget(function(options)
	if type(options) == "number" then
		options = {
			max = options,
		}
	end

	local min = options.min or 0
	local max = options.max or 1
	local initial = options.initial or 0
	local initpercent = (initial - min) / (max - min)
	local precentageValue, setPrecentageValue = Runtime.useState(initpercent)

	local refs = Runtime.useInstance(function(ref)
		local connect = createConnect()

		local style = Style.get()

		local connection

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
				[ref] = "dot",
				Size = UDim2.new(0, 15, 0, 15),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = style.textColor,
				Position = UDim2.new(0, 0, 0.5, 0),
				Text = "",

				create("UICorner", {
					CornerRadius = UDim.new(1, 0),
				}),

				InputBegan = function(input)
					if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
						return
					end

					if connection then
						connection:Disconnect()
					end

					connection = connect(UserInputService, "InputChanged", function(moveInput)
						if moveInput.UserInputType ~= Enum.UserInputType.MouseMovement then
							return
						end

						local x = moveInput.Position.X

						local maxPos = ref.frame.AbsoluteSize.X - ref.dot.AbsoluteSize.X
						x -= ref.frame.AbsolutePosition.X + ref.dot.AbsoluteSize.X / 2
						x = math.clamp(x, 0, maxPos)

						local percent = x / maxPos
						
						setPrecentageValue(percent)
					end)
				end,

				InputEnded = function(input)
					if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
						return
					end

					if connection then
						connection:Disconnect()
						connection = nil
					end
				end,
			}),
		})

		return frame
	end)

	local maxPos = refs.frame.AbsoluteSize.X - refs.frame.dot.AbsoluteSize.X
	refs.frame.dot.Position = UDim2.new(0, precentageValue * maxPos + refs.frame.dot.AbsoluteSize.X / 2, 0.5, 0)

	local value = precentageValue * (max - min) + min
	return value
end)
