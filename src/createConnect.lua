local Runtime = require(script.Parent.Runtime)

local function createConnect()
	local eventCallback = Runtime.useEventCallback()

	return function(instance, eventName, handler)
		if eventCallback then
			return eventCallback(instance, eventName, handler)
		else
			return instance[eventName]:Connect(handler)
		end
	end
end

return createConnect
