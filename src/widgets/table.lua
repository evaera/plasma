local RunService = game:GetService("RunService")
local Runtime = require(script.Parent.Parent.Runtime)
local Style = require(script.Parent.Parent.Style)
local create = require(script.Parent.Parent.create)
local automaticSize = require(script.Parent.Parent.automaticSize)

local cell = Runtime.widget(function(text)
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

			create("UIPadding", {
				PaddingBottom = UDim.new(0, 8),
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
				PaddingTop = UDim.new(0, 8),
			}),
		})
	end)

	refs.label.Text = text
end)

local row = Runtime.widget(function(columns, darken)
	Runtime.useInstance(function()
		return create("Frame", {
			BackgroundTransparency = if darken then 0.7 else 1,
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		})
	end)

	for _, column in columns do
		if type(column) == "function" then
			return Runtime.scope(column)
		else
			cell(column)
		end
	end
end)

--[=[
	@within Plasma
	@function table
	@param items {{string}}
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

	local refs = Runtime.useInstance(function(ref)
		create("Frame", {
			[ref] = "table",
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 0, options.marginTop or 0),

			create("UITableLayout", {
				[ref] = "layout",
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		})

		ref.fix = function()
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
		end

		local connection

		connection = ref.table:GetPropertyChangedSignal("Parent"):Connect(function()
			connection:Disconnect()
			connection = nil

			RunService.Heartbeat:Wait()
			RunService.Heartbeat:Wait()

			ref.fix()
		end)

		automaticSize(ref.table)

		return ref.table
	end)

	for i, columns in items do
		row(columns, i % 2 == 0)
	end

	Runtime.useEffect(function()
		refs.fix()
	end, #items)

	return refs.table
end)
