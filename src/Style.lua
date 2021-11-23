local Runtime = require(script.Parent.Runtime)

local ContextKey = Runtime.createContext("Style")

local defaultStyle = {
	bg1 = Color3.fromRGB(31, 31, 31),
	bg2 = Color3.fromRGB(42, 42, 42),
	bg3 = Color3.fromRGB(54, 54, 54),
	mutedTextColor = Color3.fromRGB(147, 147, 147),
	textColor = Color3.fromRGB(255, 255, 255),
}

local Style = {}

function Style.get()
	return Runtime.getContext(ContextKey) or defaultStyle
end

function Style.set(styleFragment)
	local existing = Runtime.getContext(ContextKey) or defaultStyle
	local newStyle = {}

	for key, value in pairs(existing) do
		newStyle[key] = value
	end

	for key, value in pairs(styleFragment) do
		newStyle[key] = value
	end

	Runtime.provideContext(ContextKey, newStyle)
end

return Style
