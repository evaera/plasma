--- @class Plasma

local Runtime = require(script.Runtime)
local Style = require(script.Style)

return {
	new = Runtime.new,
	start = Runtime.start,
	continueFrame = Runtime.continueFrame,
	beginFrame = Runtime.beginFrame,
	finishFrame = Runtime.finishFrame,
	scope = Runtime.scope,
	widget = Runtime.widget,
	useState = Runtime.useState,
	useInstance = Runtime.useInstance,
	useEffect = Runtime.useEffect,
	useKey = Runtime.useKey,
	setEventCallback = Runtime.setEventCallback,
	createContext = Runtime.createContext,
	useContext = Runtime.useContext,
	provideContext = Runtime.provideContext,

	useStyle = Style.get,
	setStyle = Style.set,

	automaticSize = require(script.automaticSize),
	hydrateAutomaticSize = require(script.hydrateAutomaticSize),
	create = require(script.create),

	window = require(script.widgets.window),
	button = require(script.widgets.button),
	portal = require(script.widgets.portal),
	blur = require(script.widgets.blur),
	row = require(script.widgets.row),
	spinner = require(script.widgets.spinner),
	checkbox = require(script.widgets.checkbox),
	arrow = require(script.widgets.arrow),
	heading = require(script.widgets.heading),
	label = require(script.widgets.label),
	slider = require(script.widgets.slider),
	space = require(script.widgets.space),
	table = require(script.widgets.table),
	highlight = require(script.widgets.highlight),
}
