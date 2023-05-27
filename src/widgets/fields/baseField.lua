local Runtime = require(script.Parent.Parent.Parent.Runtime)
local Style = require(script.Parent.Parent.Parent.Style)
local create = require(script.Parent.Parent.Parent.create)
local automaticSize = require(script.Parent.Parent.Parent.automaticSize)
local Field = require(script.Parent.Parent.Parent.Field)

local DEPTH_PADDING = 20

local fieldValueDisplay = Runtime.widget(function(value, options, globalFieldOptions)
	local fieldValueType = options.fieldValueType or Field.FieldValueType.TEXTBOX

	if fieldValueType == Field.FieldValueType.TEXTBOX then
		local refs = Runtime.useInstance(function(ref)
			local style = Style.get()
			return create("TextBox", {
				[ref] = "valueText",
				Size = UDim2.fromScale(1, 1),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = style.textColor,
				BackgroundTransparency = 1,
				Text = value,
				FocusLost = function(enterPressed)
					if enterPressed then
						options.onUpdate(ref.valueText.Text)
					end
				end,
			})
		end)

		if not refs.valueText:IsFocused() then
			refs.valueText.Text = value
		end
	elseif fieldValueType == Field.FieldValueType.TEXTLABEL then
		Runtime.useInstance(function(ref)
			local style = Style.get()
			return create("TextLabel", {
				Size = UDim2.fromScale(1, 1),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = style.textColor,
				BackgroundTransparency = 1,
				Text = value,
			})
		end)
	end
end)

local fieldRow = Runtime.widget(function(key, value, options, globalFieldOptions)
	local expand, setExpand = Runtime.useState(false)

	local depth = globalFieldOptions.depth
	local minCellSize = options.minCellSize
	local isExpandable = options.expandable or false

	if not minCellSize then
		minCellSize = globalFieldOptions.minCellSize
	end

	local refs = Runtime.useInstance(function(ref)
		local style = Style.get()

		local spacerSizeX = depth * DEPTH_PADDING

		--Add size of expandBtn
		if not isExpandable then
			spacerSizeX += 20
		end

		local expandBtn = create("TextButton", {
			[ref] = "expandBtn",
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 20, 1, 0),
			Visible = isExpandable,
			TextColor3 = style.textColor,
			TextXAlignment = Enum.TextXAlignment.Center,
			Activated = function()
				setExpand(function(isExpanded)
					return not isExpanded
				end)
			end,
		})

		local spacer = create("Frame", {
			[ref] = "spacer",
			BackgroundTransparency = 1,
			Size = UDim2.new(0, spacerSizeX, 1, 0),
		})

		local keyLabel = create("TextLabel", {
			[ref] = "keyLabel",
			BackgroundTransparency = 1,
			Text = key,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = style.textColor,
		})

		local keyContainer = create("Frame", {
			[ref] = "keyContainer",
			BackgroundTransparency = 1,
			spacer,
			expandBtn,
			keyLabel,
			create("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
		})

		local valueContainer = create("Frame", {
			[ref] = "valueContainer",
			BackgroundTransparency = 1,
			create("UIPadding", {
				PaddingLeft = UDim.new(0, 5),
			}),
		})

		local rowContainer = create("Frame", {
			[ref] = "row",
			BackgroundTransparency = 1,
			keyContainer,
			valueContainer,
			create("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		})

		automaticSize(keyLabel)
		automaticSize(keyContainer, { minSize = minCellSize })
		automaticSize(valueContainer, { minSize = minCellSize })
		automaticSize(rowContainer)

		return rowContainer, valueContainer
	end)

	Runtime.useEffect(function()
		refs.keyContainer:SetAttribute("minSize", minCellSize)
		refs.valueContainer:SetAttribute("minSize", minCellSize)
	end, minCellSize)

	refs.expandBtn.Text = if expand then "⬇️" else "➡️"

	fieldValueDisplay(value, options, globalFieldOptions)

	local handle = {
		expanded = function()
			return expand
		end,
	}

	return handle
end)

return Runtime.widget(function(key, value, options, fn)
	local globalFieldOptions = Field.getOptions()

	local expanded = fieldRow(key, value, options, globalFieldOptions):expanded()

	if fn and expanded then
		Field.setOptions({ depth = globalFieldOptions.depth + 1 })
		Runtime.scope(fn)
	end
end)
