local Runtime = require(script.Parent.Parent.Parent.Runtime)
local create = require(script.Parent.Parent.Parent.create)
local row = require(script.Parent.Parent.row)
local automaticSize = require(script.Parent.Parent.Parent.automaticSize)
local label = require(script.Parent.Parent.label)
local DEPTH_PADDING = 20

local expandButton = Runtime.widget(function(isExpanded, onActivated)
	local refs = Runtime.useInstance(function(ref)
		return create("TextButton", {
			[ref] = "expand",
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 20, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Center,
			Activated = onActivated,
		})
	end)

	refs.expand.Text = if isExpanded then "⬇️" else "➡️"
end)

local customSpace = Runtime.widget(function(sizeX)
	local refs = Runtime.useInstance(function(ref)
		return create("Frame", {
			[ref] = "space",
			BackgroundTransparency = 1,
		})
	end)

	Runtime.useEffect(function()
		refs.space.Size = UDim2.new(0, sizeX, 0, 5)
	end, sizeX)
end)

return Runtime.widget(function(labelText, options, fn)
	Runtime.useInstance(function(ref)
		local row = create("Frame", {
			BackgroundTransparency = 1,
			create("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
		})

		automaticSize(row)

		return row
	end)

	local expand, setExpand = Runtime.useState(false)
	local expandable = options.expandable

	row({ padding = 0, minSize = options.minCellSize, verticalAlignment = Enum.VerticalAlignment.Center }, function()
		local depth = options.depth or 0
		local spacerSizeX = depth * DEPTH_PADDING

		if expandable then
			customSpace(spacerSizeX)
			expandButton(expand, function()
				setExpand(function(isExpanded)
					return not isExpanded
				end)
			end)
		else
			customSpace(spacerSizeX + 20)
		end

		label(labelText)
	end)

	row({ padding = 0, minSize = options.minCellSize, verticalAlignment = Enum.VerticalAlignment.Center }, fn)

	return {
		expanded = function()
			return expand
		end,
	}
end)
