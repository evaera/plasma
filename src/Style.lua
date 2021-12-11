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

--[=[
	@within Plasma
	@function useStyle
	@tag style

	Returns the current style information, with styles that are set more recently in the tree overriding styles that
	were set further up. In this way, styles cascade downwards, similar to CSS.
]=]
function Style.get()
	return Runtime.useContext(ContextKey) or defaultStyle
end

--[=[
	@within Plasma
	@function setStyle
	@tag style
	@param styleFragment {[string]: any} -- A dictionary of style information

	Defines style for any subsequent calls in this scope. Merges with any existing styles.
]=]
function Style.set(styleFragment)
	local existing = Runtime.useContext(ContextKey) or defaultStyle
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
