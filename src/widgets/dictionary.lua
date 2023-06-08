local Runtime = require(script.Parent.Parent.Runtime)
local create = require(script.Parent.Parent.create)
local automaticSize = require(script.Parent.Parent.automaticSize)
local field = require(script.Parent.fields.field)
local label = require(script.Parent.label)
local Fields = {
	Vector3 = require(script.Parent.fields.vector3),
	CFrame = require(script.Parent.fields.cframe),
	boolean = require(script.Parent.fields.boolean),
	string = require(script.Parent.fields.string),
}

local function generateWidgets(fields, options)
	for key, value in fields do
		local fieldType = typeof(value)
		local fieldWidget = Fields[fieldType]

		if fieldWidget then
			fieldWidget(key, value, {
				depth = options.depth,
				minCellSize = options.minCellSize,
				onUpdate = function(newValue)
					options.onUpdate({
						[key] = newValue,
					})
				end,
			})
		elseif fieldType == "table" then
			local expanded = field(
				key,
				{ expandable = true, depth = options.depth, minCellSize = options.minCellSize },
				function()
					label("TABLE_VALUE")
				end
			):expanded()

			if expanded then
				generateWidgets(value, {
					depth = options.depth + 1,
					minCellSize = options.minCellSize,
					onUpdate = function(patch)
						local newValue = table.clone(value)

						for k, v in patch do
							newValue[k] = v
						end

						options.onUpdate({
							[key] = newValue,
						})
					end,
				})
			end
		end
	end
end

return Runtime.widget(function(fields, options)
	local refs = Runtime.useInstance(function(ref)
		local dictionary = create("Frame", {
			[ref] = "dictionary",
			BackgroundTransparency = 1,
			create("UIListLayout", {
				[ref] = "listLayout",
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		})

		automaticSize(dictionary)

		return dictionary
	end)

	local minCellSize = options.minCellSize or Vector2.new(100, 30)

	if options.alignFields then
		local xOffset = math.max(math.ceil(refs.listLayout.AbsoluteContentSize.X / 2), minCellSize.X)
		minCellSize = Vector2.new(xOffset, minCellSize.Y)
	end

	generateWidgets(fields, { minCellSize = minCellSize, depth = 0, onUpdate = options.onUpdate })
end)
