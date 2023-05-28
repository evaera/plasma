local Runtime = require(script.Parent.Parent.Runtime)
local create = require(script.Parent.Parent.create)
local Style = require(script.Parent.Parent.Style)
local automaticSize = require(script.Parent.Parent.automaticSize)

--[=[
	@within Plasma
	@function input
	@param text string
	@tag widgets

	Text.
]=]
return Runtime.widget(function(text, onFocusLost)
	local refs = Runtime.useInstance(function(ref)
		local style = Style.get()

		create("TextBox", {
			[ref] = "input",
			BackgroundTransparency = 1,
			Font = Enum.Font.SourceSans,
			TextColor3 = style.textColor,
			TextSize = 20,
			RichText = true,
			Size = UDim2.new(0, 100, 0, 50),
			TextXAlignment = Enum.TextXAlignment.Left,
			FocusLost = function(enterPressed)
				onFocusLost(ref.input.Text, enterPressed)
			end,
		})

		return ref.input
	end)

	if not refs.input:IsFocused() then
		refs.input.Text = text
	end
end)
