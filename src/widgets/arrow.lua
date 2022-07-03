--[=[
	@within Plasma
	@function arrow
	@tag widgets
	@param from Vector3 | CFrame | BasePart
	@param to Vector3 | BasePart | nil
	@param color Color3? -- Optional color. Random if not specified.

	- `arrow(from: Vector3, to: Vector3)` -> Creates an arrow between `from` and `to`
	- `arrow(point: Vector3)` -> Creates an arrow pointing at `point`
	- `arrow(cframe: CFrame)` -> Creates an arrow with its point at the CFrame position facing the CFrame LookVector
	- `arrow(part: BasePart)` -> Arrow represents the Part's CFrame
	- `arrow(fromPart: BasePart, toPart: BasePart)` -> Arrow between the two parts

	![Arrows](https://i.eryn.io/2150/arrows.png)

	```lua
	Plasma.arrow(Vector3.new(0, 0, 0))
	Plasma.arrow(Vector3.new(5, 5, 5), Vector3.new(10, 10, 10))
	```
]=]

local function arrow(name, container, scale, color, zindex)
	local body = Instance.new("CylinderHandleAdornment")

	body.Name = name .. "Body"
	body.Color3 = color
	body.Radius = 0.15
	body.Adornee = workspace.Terrain
	body.Transparency = 0
	body.Radius = 0.15 * scale
	body.Transparency = 0
	body.AlwaysOnTop = true
	body.ZIndex = zindex

	body.Parent = container

	local point = Instance.new("ConeHandleAdornment")

	scale = scale == 1 and 1 or 1.4

	point.Name = name .. "Point"
	point.Color3 = color
	point.Radius = 0.5 * scale
	point.Transparency = 0
	point.Adornee = workspace.Terrain
	point.Height = 2 * scale
	point.AlwaysOnTop = true
	point.ZIndex = zindex

	point.Parent = container
end

local function update(body, point, from, to, scale)
	body.Height = (from - to).magnitude - 2
	body.CFrame = CFrame.lookAt(((from + to) / 2) - ((to - from).unit * 1), to)
	point.CFrame = CFrame.lookAt((CFrame.lookAt(to, from) * CFrame.new(0, 0, -2 - ((scale - 1) / 2))).p, to)
end

local Runtime = require(script.Parent.Parent.Runtime)

return Runtime.widget(function(from, to, color)
	local fallbackColor = Runtime.useState(BrickColor.random().Color)
	color = color or fallbackColor

	if typeof(from) == "Instance" then
		if from:IsA("BasePart") then
			from = from.CFrame
		elseif from:IsA("Attachment") then
			from = from.WorldCFrame
		end

		if to ~= nil then
			from = from.p
		end
	end

	if typeof(to) == "Instance" then
		if to:IsA("BasePart") then
			to = to.Position
		elseif to:IsA("Attachment") then
			to = to.WorldPosition
		end
	end

	if typeof(from) == "CFrame" and to == nil then
		local look = from.lookVector
		to = from.p
		from = to + (look * -10)
	end

	if to == nil then
		to = from
		from = to + Vector3.new(0, 10, 0)
	end

	assert(typeof(from) == "Vector3" and typeof(to) == "Vector3", "Passed parameters are of invalid types")

	local refs = Runtime.useInstance(function(ref)
		local container = Instance.new("Folder")
		container.Name = "Arrow"

		ref.folder = container

		arrow("front", container, 1, color, 1)
		arrow("back", container, 2, Color3.new(0, 0, 0), -1)

		return container
	end)

	local folder = refs.folder

	update(folder.frontBody, folder.frontPoint, from, to, 1)
	update(folder.backBody, folder.backPoint, from, to, 1.4)

	folder.frontBody.Color3 = color
	folder.frontPoint.Color3 = color
end)
