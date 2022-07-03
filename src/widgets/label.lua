local Runtime = require(script.Parent.Parent.Runtime)
local create = require(script.Parent.Parent.create)
local Style = require(script.Parent.Parent.Style)
local automaticSize = require(script.Parent.Parent.automaticSize)

return Runtime.widget(function(text)
	local refs = Runtime.useInstance(function(ref)
		local style = Style.get()

		create("TextLabel", {
			[ref] = "label",
			BackgroundTransparency = 1,
			Font = Enum.Font.SourceSans,
			TextColor3 = style.textColor,
			TextSize = 20,
		})

		automaticSize(ref.label)

		return ref.label
	end)

	refs.label.Text = text
end)
