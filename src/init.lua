--- @class Plasma

local Runtime = require(script.Runtime)
local Style = require(script.Style)

return {
	new = Runtime.new,
	start = Runtime.start,
	scope = Runtime.scope,
	widget = Runtime.widget,
	useState = Runtime.useState,
	useInstance = Runtime.useInstance,
	useEffect = Runtime.useEffect,

	useStyle = Style.get,
	setStyle = Style.set,

	automaticSize = require(script.automaticSize),
	create = require(script.create),

	window = require(script.widgets.window),
	button = require(script.widgets.button),
	portal = require(script.widgets.portal),
	blur = require(script.widgets.blur),
	row = require(script.widgets.row),
	spinner = require(script.widgets.spinner),
	checkbox = require(script.widgets.checkbox),
	arrow = require(script.widgets.arrow),
}
