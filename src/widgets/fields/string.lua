local Runtime = require(script.Parent.Parent.Parent.Runtime)
local baseField = require(script.Parent.baseField)

return Runtime.widget(function(key, value, options)
	baseField(key, value, {
		onUpdate = options.onUpdate,
	})
end)
