type Node = {
	instance: Instance?,
	containerInstance: Instance?,
	states: { [any]: any },
	children: { [any]: Node },
	generation: number,
}

type TopoKey = number

type StackFrame = {
	node: Node,
	stateCounts: TopoKey,
	childCounts: TopoKey,
}

local stack: { StackFrame } = {}

local function newNode(state: {}): Node
	if state == nil then
		state = {}
	end

	return {
		instance = nil,
		containerInstance = nil,
		states = {},
		children = {},
		generation = 0,
	}
end

local function destroyNode(node: Node)
	if node.instance ~= nil then
		node.instance:Destroy()
	end

	for _, child in pairs(node.children) do
		destroyNode(child)
	end
end

local function newStackFrame(node: Node): StackFrame
	return {
		node = node,
		stateCounts = {},
		childCounts = {},
	}
end

local Runtime = {}

function Runtime.new(rootInstance: Instance): Node
	local node = newNode()
	node.instance = rootInstance
	return node
end

function Runtime.useState<T>(initialValue: T): T
	local frame = stack[#stack]
	local states = frame.node.states

	local file = debug.info(2, "s")
	local line = debug.info(2, "l")
	local baseKey = string.format("%s:%d", file, line)
	frame.stateCounts[baseKey] = (frame.stateCounts[baseKey] or 0) + 1
	local key = string.format("%s:%d", baseKey, frame.stateCounts[baseKey])

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

		if instance ~= nil then
			instance.Parent = parent
			node.instance = instance
		end

		if container ~= nil then
			node.containerInstance = container
		end
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

		if frame.node.instance ~= nil then
			return frame.node.instance
		end
	end

	return nil
end

local function scope(level, fn, ...)
	local parentFrame = stack[#stack]
	local parentNode = parentFrame.node

	local file = debug.info(1 + level, "s")
	local line = debug.info(1 + level, "l")
	local baseKey = string.format("%s:%d", file, line)
	parentFrame.childCounts[baseKey] = (parentFrame.childCounts[baseKey] or 0) + 1
	local key = string.format("%s:%d", baseKey, parentFrame.childCounts[baseKey])

	local currentNode = parentNode.children[key]

	if currentNode == nil then
		currentNode = newNode()
		parentNode.children[key] = currentNode
	end

	currentNode.generation = parentNode.generation

	table.insert(stack, newStackFrame(currentNode))
	local success, widgetHandle = pcall(fn, ...)
	table.remove(stack)

	if not success then
		task.spawn(error, widgetHandle)
	end

	for childKey, childNode in pairs(currentNode.children) do
		if childNode.generation ~= currentNode.generation then
			destroyNode(childNode)
			currentNode.children[childKey] = nil
		end
	end

	return widgetHandle
end

function Runtime.start(rootNode: Node, fn, ...)
	if #stack > 0 then
		error("Runtime.start cannot be called while Runtime.start is already running", 2)
	end

	if rootNode.generation == 0 then
		rootNode.generation = 1
	else
		rootNode.generation = 0
	end

	stack[1] = newStackFrame(rootNode)
	scope(2, fn, ...)
	table.remove(stack)
end

function Runtime.scope(fn, ...)
	return scope(2, fn, ...)
end

function Runtime.widget(fn)
	return function(...)
		return scope(2, fn, ...)
	end
end

return Runtime
