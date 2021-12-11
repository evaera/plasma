--[=[
	@within Plasma
	@function portal
	@tag widgets
	@param targetInstance Instance -- Where the portal goes to
	@param children () -> () -- Children

	The portal widget creates its children inside the specified `targetInstance`. For example, you could use this
	to create lighting effects in Lighting as a widget:


	```lua
	return function(size)
		portal(Lighting, function()
			useInstance(function()
				local blur = Instance.new("BlurEffect")
				blur.Size = size
				return blur
			end)
		end)
	end
	```
]=]

local Runtime = require(script.Parent.Parent.Runtime)

return Runtime.widget(function(targetInstance, fn)
	Runtime.useInstance(function()
		return nil, targetInstance
	end)

	Runtime.scope(fn)
end)
