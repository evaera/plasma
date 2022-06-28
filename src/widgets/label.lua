local Runtime = require(script.Parent.Parent.Runtime)
local create = require(script.Parent.Parent.create)
local Style = require(script.Parent.Parent.Style)

return Runtime.widget(function(text)
	local instance = Runtime.useInstance(function()
		local style = Style.get()

		return create("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.SourceSans,
			AutomaticSize = Enum.AutomaticSize.XY,
			TextColor3 = style.textColor,
			TextSize = 20,
		})
	end)

	instance.Text = text
end)
