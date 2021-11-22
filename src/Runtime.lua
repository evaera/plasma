type Node = {
	state: any,
	children: { [any]: Node },
}

type StackFrame = { node: Node, callCount: number }
local stack: { StackFrame } = {}

local Runtime = {}

function Runtime.new(rootInstance)
	return {
		state = {
			instance = rootInstance,
		},
		children = {},
	}
end

function Runtime.parentInstance()
	for i = #stack - 1, 1, -1 do
		local frame = stack[i]

		if frame.node.state.instance ~= nil then
			return frame.node.state.instance
		end
	end

	return nil
end

function Runtime.start(rootNode: Node, fn, ...)
	if #stack > 0 then
		error("Runtime.start cannot be called while Runtime.start is already running", 2)
	end

	stack[1] = {
		node = rootNode,
		callCount = 0,
	}

	local success, err = pcall(fn, rootNode.state, ...)
	table.remove(stack)

	if not success then
		task.spawn(error, err)
	end

	return rootNode
end

-- fn: (curState, ...) => newState
function Runtime.scope(fn, ...)
	local parentFrame = stack[#stack]
	if parentFrame == nil then
		error("scope must be called from within a Plasma runtime", 2)
	end

	-- TODO: Expand key logic to include source file line and number
	parentFrame.callCount += 1
	local key = parentFrame.callCount
	local currentNode = parentFrame.node.children[key]

	if currentNode == nil then
		currentNode = {
			state = {},
			children = {},
		}

		parentFrame.node.children[key] = currentNode
	end

	table.insert(stack, {
		node = currentNode,
		callCount = 0,
	})

	local success, widgetHandle = pcall(fn, currentNode.state, ...)
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
