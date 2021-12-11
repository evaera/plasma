---
sidebar_position: 3
---

# Creating Custom Widgets

Creating custom widgets is easy. Widgets in Plasma are just functions!

To create a widget, pass a function to the `widget` function.

```lua title="myButton.lua"
local Plasma = require(ReplicatedStorage.Plasma)

return Plasma.widget(function(text, color)
	local label = Plasma.useInstance(function()
		-- Code here only runs one time to create the widget.
		-- Only set properties here that DO NOT depend on arguments.

		return Plasma.create("TextButton", {
			Font = Enum.Font.GothamBold,
			TextColor3 = Color3.fromRGB(147, 147, 147),
			BackgroundColor3 = Color3.fromRGB(54, 54, 54),
			TextSize = 20,
			Size = UDim2.new(0, 0, 0, 30),
			AutomaticSize = Enum.AutomaticSize.XY,

			-- We can create children here as well
			Plasma.create("UIPadding", {
				PaddingBottom = UDim.new(0, 10),
				PaddingLeft = UDim.new(0, 20),
				PaddingRight = UDim.new(0, 20),
				PaddingTop = UDim.new(0, 10),
			}),

			Plasma.create("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),
		})
	end)

	-- In the main body of the function, we set the properties that do depend on arguments.

	label.Text = text
	label.TextColor3 = color
end)
```

In the above code snippet, we use the [`useInstance`](/api/Plasma#useInstance) hook, which takes a callback that is used to create the initial UI for the widget. The callback is only ever invoked on the first time this widget runs and never again. It also returns what we returned from it, so we can use it further.

## Only updating properties when necessary with useEffect
Typically, setting properties every frame is not that expensive of an operation, but if you only wanted to set `Text` and `TextColor3` when their arguments actually changed, we can use the [`useEffect`](/api/Plasma#useEffect) hook:

```lua
Plasma.useEffect(function()
	label.Text = text
	label.TextColor3 = color
end, text, color)
```

Now, this code will only ever be invoked if `text` or `color` actually changes from the last run.

## Persistent state with the useState hook

Let's make a counter button! The button's text should increase by 1 every time we click it.

```lua title="myButton.lua"
local Plasma = require(ReplicatedStorage.Plasma)

return Plasma.widget(function(text, color)
	local times, setTimes = Plasma.useState(0) -- new!

	local label = Plasma.useInstance(function()
		return Plasma.create("TextButton", {
			-- snip --

			Activated = function() -- new!
				setTimes(function(last)
					return last + 1
				end)
			end,
		})
	end)


	label.Text = text .. " " .. times -- new!
end)
```
(Extraneous lines have been removed from the above example)

Now, every time the user clicks this button, it'll concatenate the text they passed in with the number of times the button's been pressed.

![Button presses](https://i.eryn.io/2150/RobloxStudioBeta-sNsoBtKL.png)

:::info A note on useState with useInstance and useEffect
Notice that we pass a function to `setTimes`. What would have happened if we just wrote `setTimes(times + 1)` instead?

**It would only go to 1**! This is because (as we mentioned above), the code inside `useInstance` only ever runs once, when the widget is created. This means that the `times` variable the `useInstance` closure captured is always going to be `0`.

In the main scope of the widget function, `times` is what you expect, because it does run every frame. But inside `useInstance` or `useEffect` functions, `times` is always going to be what it was when those functions ran.

That's why the set callback (`setTimes`) can be given a function, which is invoked immediately with the *current* value of `times`. Problem solved!
:::

## Getting information out of widgets

Let's say you want your users to be able to see how many times your button was clicked in their code when they use your button widget.

You already know how to do this: just return it!

At the bottom of your widget, just:

```lua
return {
	times = times
}
```

:::tip
Returning a table with named values instead of returning a value directly is recommended, because it allows you to add more return values in the future without breaking your API interface.
:::

Then, when you use your button widget, you can just check it!

```lua title="Using your widget"
Plasma.start(root, function()
	Plasma.window("Button", function()
		local timesClicked = myButton("hi", Color3.fromRGB(255, 153, 0)).times

		if timesClicked > 50 then
			Plasma.label("You clicked them all!")
		end
	end)
end)
```

## Nested widgets

You can use widgets inside of other widgets.

For example, you could blur the world only if the number of times clicked is even:

```lua
if times % 2 == 0 then
	Plasma.blur(20)
end
```

## Automatic size

Roblox has an automatic size property of GuiObjects, but it doesn't always work correctly, especially with padding.

Plasma comes with an alternative automatic sizing function: [`automaticSize`](/api/Plasma#automaticSize).

To use it, just call `automaticSize` inside your `useInstance` function, passing in your root frame.