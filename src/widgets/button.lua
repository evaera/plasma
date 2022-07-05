--[=[
	@within Plasma
	@function button
	@tag widgets
	@param label string -- The label for the checkbox
	@return ButtonWidgetHandle

	A text button.

	Returns a widget handle, which has the field:

	- `clicked`, a function you can call to check if the checkbox was clicked this frame

	![A button](https://i.eryn.io/2150/RobloxStudioBeta-iwRM0RMx.png)

	```lua
	Plasma.window("Button", function()
		if Plasma.button("button text"):clicked() then
			print("clicked!")
		end
	end)
	```
]=]

local Runtime = require(script.Parent.Parent.Runtime)
local Style = require(script.Parent.Parent.Style)
local create = require(script.Parent.Parent.create)

return Runtime.widget(function(text)
	local clicked, setClicked = Runtime.useState(false)
	local refs = Runtime.useInstance(function(ref)
		local style = Style.get()

		return create("TextButton", {
			[ref] = "button",
			BackgroundColor3 = style.bg3,
			BorderSizePixel = 0,
			Font = Enum.Font.SourceSans,
			Size = UDim2.new(0, 100, 0, 40),
			TextColor3 = style.textColor,
			AutomaticSize = Enum.AutomaticSize.X,
			TextSize = 21,

			create("UIPadding", {
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
			}),

			create("UICorner"),

			Activated = function()
				setClicked(true)
			end,
		})
	end)

	local instance = refs.button

	instance.Text = text

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
