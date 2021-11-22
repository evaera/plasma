local Lighting = game:GetService("Lighting")
local Runtime = require(script.Parent.Parent.Runtime)
local portal = require(script.Parent.portal)

return function(size)
	portal(Lighting, function()
		Runtime.useInstance(function()
			local blur = Instance.new("BlurEffect")
			blur.Size = size
			return blur
		end)
	end)
end
