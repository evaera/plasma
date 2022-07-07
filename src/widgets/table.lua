local RunService = game:GetService("RunService")
local Runtime = require(script.Parent.Parent.Runtime)
local Style = require(script.Parent.Parent.Style)
local create = require(script.Parent.Parent.create)
local automaticSize = require(script.Parent.Parent.automaticSize)

local cell = Runtime.widget(function(text, font)
	local refs = Runtime.useInstance(function(ref)
		local style = Style.get()

		return create("TextLabel", {
			[ref] = "label",
			BackgroundTransparency = 1,
			Font = Enum.Font.SourceSans,
			AutomaticSize = Enum.AutomaticSize.XY,
			TextColor3 = style.textColor,
			TextSize = 20,
			TextXAlignment = Enum.TextXAlignment.Left,
			RichText = true,

			create("UIPadding", {
				PaddingBottom = UDim.new(0, 8),
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
				PaddingTop = UDim.new(0, 8),
			}),
		})
	end)

	refs.label.Font = font or Enum.Font.SourceSans
	refs.label.Text = text
end)

local row = Runtime.widget(function(columns, darken, selectable, font)
	local clicked, setClicked = Runtime.useState(false)
	local hovering, setHovering = Runtime.useState(false)

	local selected = columns.selected

	local refs = Runtime.useInstance(function(ref)
		return create("TextButton", {
			[ref] = "row",
			BackgroundTransparency = if darken then 0.7 else 1,
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			AutoButtonColor = false,
			Text = "",
			Active = false,

			MouseEnter = function()
				setHovering(true)
			end,

			MouseLeave = function()
				setHovering(false)
			end,

			Activated = function()
				setClicked(true)
			end,
		})
	end)

	refs.row.Active = selectable and not selected or false

	local transparency = 1

	if selected then
		transparency = 0
	elseif hovering and selectable then
		transparency = 0.4
	elseif darken then
		transparency = 0.7
	end

	refs.row.BackgroundTransparency = transparency
	refs.row.BackgroundColor3 = selected and Color3.fromHex("bd515c") or Color3.fromRGB(0, 0, 0)

	for _, column in ipairs(columns) do
		if type(column) == "function" then
			Runtime.scope(column)
		else
			cell(column, font)
		end
	end

	return {
		clicked = function()
			if clicked then
				setClicked(false)
				return true
			end
			return false
		end,
		hovered = function()
			return hovering
		end,
	}
end)

--[=[
	@within Plasma
	@function table
	@param items {{string}}
	@param options {marginTop?: number, selectable?: boolean, font?: Font, headings?: boolean}
	@tag widgets

	A table widget. Items is a list of rows, with each row being a list of cells.

	```lua
	local items = {
		{"cell one", "cell two"},
		{"cell three", "cell four"}
	}
	```

	![Table](https://i.eryn.io/2227/NEc4Dmnv.png)
]=]
return Runtime.widget(function(items, options)
	options = options or {}

	Runtime.useInstance(function(ref)
		create("Frame", {
			[ref] = "table",
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 0, options.marginTop or 0),

			create("UITableLayout", {
				[ref] = "layout",
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		})

		local connection

		connection = ref.table:GetPropertyChangedSignal("Parent"):Connect(function()
			connection:Disconnect()
			connection = nil

			RunService.Heartbeat:Wait()
			RunService.Heartbeat:Wait()

			-- Wtf roblox

			for _, child in ref.table:GetChildren() do
				if child:IsA("GuiObject") then
					child.Visible = false
				end
			end

			local _ = ref.layout.AbsoluteContentSize

			for _, child in ref.table:GetChildren() do
				if child:IsA("GuiObject") then
					child.Visible = true
				end
			end
		end)

		automaticSize(ref.table)

		return ref.table
	end)

	local selected, setSelected = Runtime.useState()
	local hovered

	for i, columns in items do
		local selectable = options.selectable
		local font = options.font

		if options.headings and i == 1 then
			selectable = false
			font = Enum.Font.GothamBold
		end

		local currentRow = row(columns, i % 2 == 1, selectable, font)

		if currentRow:clicked() then
			setSelected(columns)
		end

		if currentRow:hovered() then
			hovered = columns
		end
	end

	return {
		selected = function()
			if selected then
				setSelected(nil)
				return selected
			end
		end,
		hovered = function()
			return hovered
		end,
	}
end)
