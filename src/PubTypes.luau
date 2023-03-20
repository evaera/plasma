export type EventCallback = (Instance, string, (...any) -> ()) -> ()

export type Node = {
	instance: Instance?,
	refs: { [any]: Instance }?,
	containerInstance: Instance?,
	effects: {
		[TopoKey]: {
			lastDependencies: { any }?,
			lastDependenciesLength: number,
			destructor: (() -> ())?,
		},
	},
	states: { [TopoKey]: any },
	children: { [TopoKey]: Node },
	generation: number,
	eventCallback: EventCallback?,
}

export type TopoKey = string

export type StackFrame = {
	node: Node,
	contextValues: {
		[any]: any,
	},
	childrenCount: number,
	effectCounts: { [TopoKey]: number },
	stateCounts: { [TopoKey]: number },
	childCounts: { [TopoKey]: number },
	discriminator: (string | number)?,
}

export type WindowOptions = {
	title: string?,
	movable: boolean?,
	resizable: boolean?,
	closable: boolean?,
	maxSize: (Vector2 | UDim2)?,
	minSize: Vector2?
}

export type RowOptions = {
	padding: Vector2?
}

export type CheckboxOptions = {
	disabled: boolean?,
	checked: boolean?
}

export type HeaderOptions = {
	font: Enum.Font
}

export type SliderOptions = {
	max: number?,
	min: number?,
	initial: number?
}

export type TableOptions = {
	marginTop: number?,
	selectable: boolean?,
	font: Enum.Font?,
	headings: boolean?
}

export type HighlightOptions = {
	outlineColor: Color3?,
	fillColor: Color3?,
	fillTransparency: Color3?,
	outlineTransparency: Color3?,
	depthMode: Enum.HighlightDepthMode?
	
}

export type WindowWidgetHandle = {
	closed: (WindowWidgetHandle?) -> boolean
}

export type ButtonWidgetHandle = {
	clicked: (ButtonWidgetHandle?) -> boolean
	
}

export type CheckboxWidgetHandle = {
	checked: (CheckboxWidgetHandle?) -> boolean,
	clicked: (CheckboxWidgetHandle?) -> boolean
	
}

export type TableWidgetHandle = {
	selected: (TableWidgetHandle?) -> {string},
	hovered: (TableWidgetHandle?) -> boolean
}

return nil