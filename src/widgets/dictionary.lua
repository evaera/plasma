local Runtime = require(script.Parent.Parent.Runtime)
local create = require(script.Parent.Parent.create)
local automaticSize = require(script.Parent.Parent.automaticSize)
local FieldWidgets = {
	Vector3 = require(script.Parent.fields.vector3),
	string = require(script.Parent.fields.string),
	CFrame = require(script.Parent.fields.cframe)
}
local baseField = require(script.Parent.fields.baseField)
local Field = require(script.Parent.Parent.Field)

local function generateWidgets(fields, options)
	for fieldKey, fieldValue in fields do
		local fieldType = typeof(fieldValue)
		local fieldWidget = FieldWidgets[fieldType]

		if fieldWidget then
			fieldWidget(fieldKey, fieldValue, {
				update = function(newValue)
					options.update({
						[fieldKey] = newValue
					})
				end
			})
		elseif fieldType == "table" then
			baseField(fieldKey, "TABLE_VALUE", { expandable = true, fieldValueType = Field.FieldValueType.TEXTLABEL }, function()
				generateWidgets(fieldValue, {
					update = function(patch)
						local new = table.clone(fields)
						new[fieldKey] = patch
						options.update(new)
					end
				})

			end)
		elseif fieldType == "function" then
			baseField(fieldKey, "FUNCTION_VALUE", { fieldValueType = Field.FieldValueType.TEXTLABEL })
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
				SortOrder = Enum.SortOrder.LayoutOrder
			}),
		})

		automaticSize(dictionary)

		return dictionary
	end)

	local minCellSize = options.minCellSize or Vector2.new(100, 30)

	if options.alignFields then
		local xOffset = math.max(math.ceil(refs.listLayout.AbsoluteContentSize.X/2), minCellSize.X)
		minCellSize = Vector2.new(xOffset, minCellSize.Y)
	end

	Field.setOptions({minCellSize = minCellSize})

	generateWidgets(fields, options)
end)
