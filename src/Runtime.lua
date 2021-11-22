type Node = {
	instance: Instance?,
	containerInstance: Instance?,
	states: { [any]: any },
	children: { [any]: Node },
}

type TopoKey = number

type StackFrame = {
	node: Node,
	stateCount: TopoKey,
	childCount: TopoKey,
}

local stack: { StackFrame } = {}

local function newNode(state: {}): Node
	if state == nil then
		state = {}
	end

	return {
		instance = nil,
		states = {},
		children = {},
	}
end

local function newStackFrame(node: Node): StackFrame
	return {
		node = node,
		stateCount = 0,
		childCount = 0,
	}
end

local Runtime = {}

function Runtime.new(rootInstance: Instance): Node
	local node = newNode()
	node.instance = rootInstance
	node.containerInstance = rootInstance
	return node
end

function Runtime.useState<T>(initialValue: T): T
	local frame = stack[#stack]
	local states = frame.node.states

	frame.stateCount += 1
	local key = frame.stateCount

	local existing = states[key]
	if existing == nil then
		states[key] = initialValue
	end

	local function setter(newValue)
		states[key] = newValue
	end

	return states[key], setter
end

function Runtime.useInstance(creator: () -> Instance): Instance
	local node = stack[#stack].node

	if node.instance == nil then
		local parent = Runtime.parentInstance()

		local instance, container = creator()
		instance.Parent = parent
		if container == nil then
			container = instance
		end

		node.instance = instance
		node.containerInstance = container
	end

	return node.instance
end

function Runtime.childNumber(): number
	local frame = stack[#stack]
	return frame.childCount
end

function Runtime.parentInstance(): Instance?
	for i = #stack - 1, 1, -1 do
		local frame = stack[i]

		if frame.node.containerInstance ~= nil then
			return frame.node.containerInstance
		end
	end

	return nil
end

function Runtime.start(rootNode: Node, fn, ...)
	if #stack > 0 then
		error("Runtime.start cannot be called while Runtime.start is already running", 2)
	end

	stack[1] = newStackFrame(rootNode)

	local success, err = pcall(fn, ...)
	table.remove(stack)

	if not success then
		task.spawn(error, err)
	end

	return rootNode
end

function Runtime.scope(fn, ...)
	local parentFrame = stack[#stack]
	if parentFrame == nil then
		error("scope must be called from within a Plasma runtime", 2)
	end

	-- TODO: Expand key logic to include source file line and number
	parentFrame.childCount += 1
	local key = parentFrame.childCount
	local currentNode = parentFrame.node.children[key]

	if currentNode == nil then
		currentNode = newNode()
		parentFrame.node.children[key] = currentNode
	end

	table.insert(stack, newStackFrame(currentNode))
	local success, widgetHandle = pcall(fn, ...)
	table.remove(stack)

	if not success then
		task.spawn(error, widgetHandle)
	end

	return widgetHandle
end

function Runtime.widget(fn)
	return function(...)
		return Runtime.scope(fn, ...)
	end
end

return Runtime
