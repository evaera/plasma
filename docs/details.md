---
sidebar_position: 4
---

# Usage details

## Hooks

Hooks are topologically-aware functions. This means that when you use a hook like `useState` or `useEffect`, they are aware of the call stack and hold their own state outside of arguments and return values.

Their state is actually keyed by your script name and the line number you call them on! This state is kept in the enclosing *scope*. Scopes are created every time you use a new widget or create children inside of a widget. You can also create a new scope manually with the `Plasma.scope` function.

Even if code runs multiple times in a single frame, state will always be separated by scope. This means you can use the same widget multiple times in a single frame, and their state will be separate because they are all inside of separate scopes.

If called in a loop, hooks hold state by number of times that line was called consecutively.

Check out the [API reference](/api#useContext) to learn more.

## Automatic layout

Widgets are automatically laid out with Roblox's Layout objects. This means you don't need to worry about where UI elements go, they just go after whatever came before them.

By default, widgets are laid out vertically. You can lay widgets out horizontally by using `Plasma.row(function() end)` and creating widgets inside the children function to lay widgets out to the side.

In the future, there will be more widgets that allow users to customize layout more easily.

Plasma automatically sets the `LayoutOrder` property of children widgets to the correct value.

## Error reporting

By default, errors that occur during layout are reported visually in the UI, bounded at the scope level.

![Example of error](https://i.eryn.io/2150/n1AsMbhS.png)

Since your code runs every frame, errors that happen every frame can fill up the output quickly. To mitigate this, Plasma will only allow repeated errors to be reported in the output once every 10 seconds:

![Example of output](https://i.eryn.io/2150/xmBJqQDQ.png)