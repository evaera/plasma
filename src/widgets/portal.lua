local Runtime = require(script.Parent.Parent.Runtime)

return Runtime.widget(function(targetInstance, fn)
	Runtime.useInstance(function()
		return nil, targetInstance
	end)

	Runtime.scope(fn)
end)
