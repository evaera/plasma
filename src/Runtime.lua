type Node = {
	instance: Instance?,
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

--[=[
	@within Plasma
	@param rootInstance Instance -- The root instance of which to mount all children. Likely a ScreenGui.
	@return Node -- An opaque object which holds persistent state about your UI.
]=]
function Runtime.new(rootInstance: Instance): Node
	local node = newNode()
	node.instance = rootInstance
	return node
end

--[=[
	@within Plasma
	@param name string -- The human-readable name of the context. This is only for debug purposes.
	@return Context -- An opqaue Context object which holds persistent state.

	Creates a [Context] object which is used to pass state downwards through the tree without needing to thread it
	through every child as props.
]=]
function Runtime.createContext(name: string)
	local fullName = string.format("PlasmaContext(%s)", name)
	return setmetatable({}, {
		__tostring = function()
			return fullName
		end,
	})
end

--[=[
	@within Plasma
	@param context Context -- A context object previously created with `createContext`
	@return T
	@tag hooks

	Returns the value of this context provided by the most recent ancestor that used `provideContext` with this context.
]=]
function Runtime.useContext(context)
	for i = #stack - 1, 1, -1 do
		local frame = stack[i]

		if frame.contextValues[context] ~= nil then
			return frame.contextValues[context]
		end
	end

	return nil
end

--[=[
	@within Plasma
	@param context Context -- A context object previously created with `createContext`
	@param value T -- Any value you want to provide for this context

	Provides a value for this context for any subsequent uses of `useContext` in this scope.
]=]
function Runtime.provideContext(context, value)
	local frame = stack[#stack]
	frame.contextValues[context] = value
end

--[=[
	@within Plasma
	@param callback () -> () | () -> () -> () -- A callback function that optionally returns a cleanup function
	@param ... any -- Dependencies
	@tag hooks

	`useEffect` takes a callback as a parameter which is then only invoked if passed dependencies are different from the
	last time this function was called. The callback is always invoked the first time this code path is reached.

	If no dependencies are passed, the callback only runs once.

	This function can be used to skip expensive work if none of the dependencies have changed since the last run.
	For example, you might use this to set a bunch of properties in a widget if any of the inputs change.
]=]
function Runtime.useEffect(callback: () -> () | () -> () -> (), ...)
	local frame = stack[#stack]
	local effects = frame.node.effects

	local file = debug.info(2, "s")
	local line = debug.info(2, "l")
	local baseKey = string.format("%s:%d", file, line)
	frame.effectCounts[baseKey] = (frame.effectCounts[baseKey] or 0) + 1
	local key = string.format("%s:%d", baseKey, frame.effectCounts[baseKey])

	local existing = effects[key]
	local gottaRunIt = existing == nil -- We ain't never run this before!
		or select("#", ...) ~= existing.lastDependenciesLength -- I have altered the dependencies. Pray that I do not alter them further.

	if not gottaRunIt then
		for i = 1, select("#", ...) do
			if select(i, ...) ~= existing.lastDependencies[i] then
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
			lastDependencies = { ... },
			lastDependenciesLength = select("#", ...),
		}
	end
end

--[=[
	@within Plasma
	@param initialValue T -- The value this hook returns if the set callback has never been called
	@return T -- The previously set value, or the initial value if none has been set
	@return (newValue: T) -> () -- A function which when called stores the value in this hook for the next run
	@tag hooks

	```lua
	local checked, setChecked = useState(false)

	useInstance(function()
		local TextButton = Instance.new("TextButton")

		TextButton.Activated:Connect(function()
			setChecked(not checked)
		end)

		return TextButton
	end)

	TextButton.Text = if checked then "X" else ""
	```
]=]
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

--[=[
	@within Plasma
	@param creator () -> (Instance, Instance?) -- A callback which creates the widget and returns it
	@return Instance -- Returns the instance returned by `creator`
	@tag hooks

	`useInstance` takes a callback which should be used to create the initial UI for the widget.
	The callback is only ever invoked on the first time this widget runs and never again.
	The callback should return the instance it created.
	The callback can optionally return a second value, which is the instance where children of this widget should be
	placed. Otherwise, children are placed in the first instance returned.

	`useInstance` returns the instance returned by the `creator` callback on the initial call and all further calls.
]=]
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

		if not recentErrors[widgetHandle] then
			task.spawn(error, tostring(widgetHandle))
			warn("Plasma: The above error will be suppressed for the next 10 seconds")
			recentErrors[widgetHandle] = true
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

--[=[
	@within Plasma
	@param rootNode Node -- A node created by `Plasma.new`.
	@param callback (...: T) -> ()
	@param ... T -- Additional parameters to `callback`

	Begins a new frame for this Plasma instance. The `callback` is invoked immediately.
	Code run in the `callback` function that uses plasma APIs will be associated with this Plasma node.
	The `callback` function is **not allowed to yield**.
]=]
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

	debug.profilebegin("Plasma")

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

	for childKey, childNode in pairs(rootNode.children) do
		if childNode.generation ~= rootNode.generation then
			destroyNode(childNode)
			rootNode.children[childKey] = nil
		end
	end

	debug.profileend()
end

--[=[
	@within Plasma
	@param callback (...: T) -> ()
	@param ... T -- Additional parameters to `callback`

	Begins a new scope. This function may only be called within a `Plasma.start` callback.
	The `callback` is invoked immediately.

	Beginning a new scope associates all further calls to Plasma APIs with a nested scope inside this one.
]=]
function Runtime.scope(fn, ...)
	return scope(2, fn, ...)
end

--[=[
	@within Plasma
	@param callback (...: T) -> () -- The widget function
	@return (...: T) -> () -- A function which can be called to create the widget

	This function takes a widget funtion and returns a function that automatically starts a new scope when the function
	is called.
]=]
function Runtime.widget(fn)
	return function(...)
		return scope(2, fn, ...)
	end
end

return Runtime
