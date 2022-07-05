local Runtime = require(script.Parent.Parent.Runtime)
local create = require(script.Parent.Parent.create)
local Style = require(script.Parent.Parent.Style)

return Runtime.widget(function(text, options)
	options = options or {}
	local refs = Runtime.useInstance(function(ref)
		local style = Style.get()

		return create("TextLabel", {
			[ref] = "heading",
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			AutomaticSize = Enum.AutomaticSize.XY,
			TextColor3 = style.mutedTextColor,
			TextSize = 20,
			RichText = true,
		})
	end)

	local instance = refs.heading
	instance.Text = text
	instance.Font = options.font or Enum.Font.GothamBold
end)
