local Runtime = require(script.Parent.Parent.Runtime)
local Style = require(script.Parent.Parent.Style)
local automaticSize = require(script.Parent.Parent.automaticSize)
local create = require(script.Parent.Parent.create)

--[=[
	@within Plasma
	@function label
	@param text string
	@tag widgets

	Text.
]=]
return Runtime.widget(function(text)
	local refs = Runtime.useInstance(function(ref)
		local style = Style.get()

		create("TextLabel", {
			[ref] = "label",
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			TextColor3 = style.textColor,
			TextSize = 16,
			RichText = true,
		})

		automaticSize(ref.label)

		return ref.label
	end)

	refs.label.Text = text
end)
