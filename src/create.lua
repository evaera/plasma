local Runtime = require(script.Parent.Runtime)

--[=[
	@within Plasma
	@function create
	@param className string -- The class name of the Instance to create
	@param props CreateProps
	@return Instance -- The created instance
	@tag utilities

	A function that creates an Instance tree.

	CreateProps is a table:
	- String keys are interpreted as properties to set
	- Numerical keys are interpreted as children
	- Function values are interpreted as event handlers
	- Table keys can be used to get references to instances deep in the tree, the value becomes the key in the table

	This function doesn't do anything special. It just creates an instance.

	```lua
	create("Frame", {
		BackgroundTransparency = 1,
		Name = "Checkbox",

		create("TextButton", {
			BackgroundColor3 = Color3.fromRGB(54, 54, 54),
			Size = UDim2.new(0, 30, 0, 30),

			create("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),

			Activated = function()
				setClicked(true)
			end,
		}),
	})
	```

	Getting references to instances deep in a tree:

	```lua
	local ref = {}

	create("Frame", {
		create("TextButton", {
			[ref] = "button",
			Text = "hi"
		})
	})

	print(ref.button.Text) --> hi
	```
]=]
local function create(className, props)
	props = props or {}

	local eventCallback = Runtime.useEventCallback()

	local instance = Instance.new(className)

	for key, value in pairs(props) do
		if type(value) == "function" then
			if eventCallback then
				eventCallback(instance, key, value)
			else
				instance[key]:Connect(value)
			end
		elseif type(key) == "number" then
			value.Parent = instance
		elseif type(key) == "table" then
			key[value] = instance

			if props.Name == nil then
				instance.Name = value
			end
		else
			instance[key] = value
		end
	end

	return instance
end

return create
