local Runtime = require(script.Parent.Parent.Runtime)
local create = require(script.Parent.Parent.create)
local automaticSize = require(script.Parent.Parent.automaticSize)
local field = require(script.Parent.field)
local DataTypeConfig = require(script.Parent.Parent.DataTypeConfig)

local function generateWidgets(fields, options)
	for key, value in fields do
		local fieldType = typeof(value)
		local dataTypeConfig = DataTypeConfig[fieldType]

		if not dataTypeConfig then
			continue
		end

		Runtime.useKey(key)

		local expanded = field(
			{
				label = key,
				value = value,
			},
			dataTypeConfig,
			{
				minCellSize = options.minCellSize,
				depth = options.depth,
				onUpdate = function(newValue)
					options.onUpdate({
						[key] = newValue,
					})
				end,
			}
		):expanded()

		if expanded then
			--TODO Implement logic for displaying datatype components
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
