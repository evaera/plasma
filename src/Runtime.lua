type Node = {
	instance: Instance?,
	containerInstance: Instance?,
	effects: {
		[TopoKey]: {
			lastDependencies: { any }?,
			destructor: (() -> ())?,
		},
	},
	states: { [TopoKey]: any },
	children: { [TopoKey]: Node },
	generation: number,
}

type TopoKey = string

type StackFrame = {
	node: Node,
	contextValues: {
		[any]: any,
	},
	childrenCount: number,
	effectCounts: TopoKey,
	stateCounts: TopoKey,
	childCounts: TopoKey,
}

local stack: { StackFrame } = {}

local yieldedThread
local recentErrors = {}
local recentErrorLastTime = 0

local function newNode(state: {}): Node
	if state == nil then
		state = {}
	end

	return {
		instance = nil,
		containerInstance = nil,
		effects = {},
		states = {},
		children = {},
		generation = 0,
	}
end

local function destroyNode(node: Node)
	if node.instance ~= nil then
		node.instance:Destroy()
	end

	for _, effect in pairs(node.effects) do
		if effect.destructor ~= nil then
			effect.destructor()
		end
	end

	for _, child in pairs(node.children) do
		destroyNode(child)
	end
end

local function newStackFrame(node: Node): StackFrame
	return {
		node = node,
		contextValues = {},
		childrenCount = 0,
		effectCounts = {},
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

function Runtime.createContext(name: string)
	local fullName = string.format("PlasmaContext(%s)", name)
	return setmetatable({}, {
		__tostring = function()
			return fullName
		end,
	})
end

function Runtime.getContext(context)
	for i = #stack - 1, 1, -1 do
		local frame = stack[i]

		if frame.contextValues[context] ~= nil then
			return frame.contextValues[context]
		end
	end

	return nil
end

function Runtime.provideContext(context, value)
	local frame = stack[#stack]
	frame.contextValues[context] = value
end

function Runtime.useEffect(callback: () -> () | () -> () -> (), dependencies: { any }?)
	local frame = stack[#stack]
	local effects = frame.node.effects

	local file = debug.info(2, "s")
	local line = debug.info(2, "l")
	local baseKey = string.format("%s:%d", file, line)
	frame.effectCounts[baseKey] = (frame.effectCounts[baseKey] or 0) + 1
	local key = string.format("%s:%d", baseKey, frame.effectCounts[baseKey])

	local existing = effects[key]
	local gottaRunIt = existing == nil -- We ain't never run this before!
		or dependencies == nil -- The user didn't specify any dependencies.
		or #dependencies ~= #existing.lastDependencies -- I have altered the dependencies. Pray that I do not alter them further.

	-- TODO: improve dependency comparison
	if not gottaRunIt then
		for i, last in pairs(existing.lastDependencies) do
			if dependencies[i] ~= last then
				gottaRunIt = true
				break
			end
		end
	end

	if gottaRunIt then
		if existing ~= nil and existing.destructor ~= nil then
			existing.destructor()
		end

		effects[key] = {
			destructor = callback(),
			lastDependencies = dependencies,
		}
	end
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
		if type(newValue) == "function" then
			newValue = newValue(states[key])
		end

		states[key] = newValue
	end

	return states[key], setter
end

function Runtime.useInstance(creator: () -> Instance): Instance
	local node = stack[#stack].node
	local parentFrame = Runtime.nearestStackFrameWithInstance()

	if node.instance == nil then
		local parent = parentFrame.node.containerInstance or parentFrame.node.instance

		local instance, container = creator()

		if instance ~= nil then
			instance.Parent = parent
			node.instance = instance
		end

		if container ~= nil then
			node.containerInstance = container
		end
	end

	if node.instance ~= nil and node.instance:IsA("GuiObject") then
		parentFrame.childrenCount += 1
		node.instance.LayoutOrder = parentFrame.childrenCount
	end

	return node.instance
end

function Runtime.nearestStackFrameWithInstance(): StackFrame?
	for i = #stack - 1, 1, -1 do
		local frame = stack[i]

		if frame.node.containerInstance ~= nil or frame.node.instance ~= nil then
			return frame
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
	local success, widgetHandle = xpcall(fn, debug.traceback, ...)

	if not success then
		if os.clock() - recentErrorLastTime > 10 then
			recentErrorLastTime = os.clock()
			recentErrors = {}
		end

		if not recentErrors[error] then
			task.spawn(error, widgetHandle)
			warn("Plasma: The above error will be suppressed for the next 10 seconds")
			recentErrors[error] = true
		end

		local errorWidget = require(script.Parent.widgets.error)

		errorWidget(tostring(widgetHandle))
	end

	table.remove(stack)

	for childKey, childNode in pairs(currentNode.children) do
		if childNode.generation ~= currentNode.generation then
			destroyNode(childNode)
			currentNode.children[childKey] = nil
		end
	end

	return widgetHandle
end

function Runtime.start(rootNode: Node, fn, ...)
	if yieldedThread then
		if coroutine.status(yieldedThread) ~= "dead" then
			return
		end
		yieldedThread = nil
		warn("Plasma: Erroneously yielded thread has resumed, UI is no longer blocked.")
	end

	if #stack > 0 then
		error("Runtime.start cannot be called while Runtime.start is already running", 2)
	end

	if rootNode.generation == 0 then
		rootNode.generation = 1
	else
		rootNode.generation = 0
	end

	local handler = function(...)
		local thread = coroutine.running()

		task.defer(function()
			if coroutine.status(thread) ~= "dead" then
				task.spawn(
					error,
					"Plasma: Handler passed to Plasma.start yielded! Yielding is not allowed and will lead to unexpected results."
				)
				warn("Plasma UI will not update until the yielded thread has resumed...")

				yieldedThread = thread
			end
		end)

		return fn(...)
	end

	stack[1] = newStackFrame(rootNode)
	scope(2, handler, ...)
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
