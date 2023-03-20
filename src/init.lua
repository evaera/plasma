--- @class Plasma

local Runtime = require(script.Runtime)
local Style = require(script.Style)
local PubTypes = require(script.PubTypes)

export type Node = PubTypes.Node
export type EventCallback = PubTypes.EventCallback
export type StackFrame = PubTypes.StackFrame
export type ContinueHandle = PubTypes.StackFrame

export type WindowOptions = PubTypes.WindowOptions
export type RowOptions = PubTypes.RowOptions
export type CheckboxOptions = PubTypes.CheckboxOptions
export type HeaderOptions = PubTypes.HeaderOptions
export type SliderOptions = PubTypes.SliderOptions
export type TableOptions = PubTypes.TableOptions
export type HighlightOptions = PubTypes.HighlightOptions

export type WindowWidgetHandle = PubTypes.WindowWidgetHandle
export type ButtonWidgetHandle = PubTypes.ButtonWidgetHandle
export type CheckboxWidgetHandle = PubTypes.CheckboxWidgetHandle
export type TableWidgetHandle = PubTypes.TableWidgetHandle

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
} :: {
	
	new: (rootInstance: Instance) -> Node,
	start: <T...>(rootNode: Node, fn: (T...) -> (), T...) -> (),
	continueFrame: <T...>(continueHandle: ContinueHandle, fn: (T...) -> (), T...) -> (),
	beginFrame: <T...>(rootNode: Node, fn: (T...) -> (), T...) -> ContinueHandle,
	finishFrame: (rootNode: Node) -> (),
	scope: <R..., T...>(fn: (T...) -> R..., T...) -> R...,
	widget: <R..., T...>(fn: (T...) -> R...) -> (T...) -> R...,
	useState: <T>(initialValue: T) -> (T, (newValue: T) -> ()),
	useInstance: <T>(creator: (ref: T & {}) -> (Instance, Instance?)) -> T,
	useEffect: (callback: (() -> ()) & (() -> () -> ())) -> (),
	useKey: (key: string | number) -> (),
	setEventCallback: (callback: EventCallback) -> (),
	
	useStyle: () -> {[string]: any},
	setStyle: (styleFragment: {[string]: any}) -> (),
	
	automaticSize: (container: GuiObject, options: {axis: Enum.AutomaticSize, maxSize: (Vector2 | UDim2)?, minSize: Vector2?}?) -> (),
	hydrateAutomaticSize: () -> RBXScriptConnection,
	create: (className: string, props: {[any]: any}) -> Instance,
	
	window: (options: string | WindowOptions, children: () -> ()) -> WindowWidgetHandle,
	button: (label: string) -> ButtonWidgetHandle,
	portal: (targetInstance: Instance, children: () -> ()) -> (),
	blur: (size: number) -> (),
	row: ((options: RowOptions?, children: () -> ()) -> ()) & ((children: () -> ()) -> ()),
	spinner: () -> (),
	checkbox: (label: string, options: CheckboxOptions?) -> CheckboxWidgetHandle,
	arrow: (from: Vector3 | CFrame | BasePart, to: Vector3 | BasePart?, color: Color3?) -> (),
	heading: (text: string, options: HeaderOptions?) -> (),
	label: (text: string) -> (),
	slider: (options: SliderOptions | number) -> number,
	space: (size: number) -> (),
	table: (items: {{string}}, options: TableOptions?) -> TableWidgetHandle,
	highlight: (adornee: Instance, options: HighlightOptions) -> ()
	
}