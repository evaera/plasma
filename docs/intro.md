---
sidebar_position: 1
---

# Plasma

Plasma is a declarative, immediate mode UI widget library for Roblox.

:::danger Still baking!
Plasma isn't quite ready for production yet. There might be bugs and missing features!
:::

Plasma is intended to be used for debug UI, similar to [egui](https://github.com/emilk/egui) and [Dear ImGui](https://github.com/ocornut/imgui). While there's nothing stopping you from using it for your game's main UI, something like [Roact](https://github.com/Roblox/roact) might be a better fit.

## What is immediate mode?

Plasma is an *immediate mode* UI library, as opposed to *retained mode*.

In a retained mode model, you might make a button and connect a clicked event, with code that is invoked when the event happens. The button is *retained* in the DataModel, and to change the text on it you need to store a reference to it.

But under an immediate mode model, you show the button and check if it's been clicked immediately, and you do that every single frame (60 times per second). There's no need for a clicked event or to store a reference to the button.

As another example, let's say you had a window that you only wanted to be shown when it was visible. In retained mode, you would create the window, and store a reference to the window. When the button to toggle visibility is toggled, you use the reference to the window to make it visible or not.

In immediate mode, it's much simpler: you just check if the window should be rendered with an if statement, and render the window inside the if statement. That's it: if the window wasn't supposed to be rendered, you just never call the code to render the window.

## Advantages

The main advantage of immediate mode is that code becomes vastly simpler:

- You never need to have any on-click handlers and callbacks that disrupts your code flow.
- You don't have to worry about a lingering callback calling something that is gone.
- Your GUI code can easily live in a simple function (no need for an object just for the UI).
- You don't have to worry about world and GUI state being out-of-sync (i.e. the GUI showing something outdated), because the GUI isn't storing any state - it is showing the latest state immediately.

In other words, a whole lot of code, complexity and bugs are gone, and you can focus your time on something more interesting than writing GUI code.

## Performance

Your UI code runs every frame, but we only make changes to the DataModel as needed. If you created a window, button, and checkbox in the exact same place last frame, we just do nothing this frame. We only make changes to the DataModel when something ends up being different than the last frame.

This means that if your UI is not any different than it was last time, the only overhead you have is actually calling the functions to create the UI. It's not *free*, and using immediate-mode UI can end up using more CPU time than a retained mode UI, but it's also shouldn't be a significant enough of an overhead to cause problems. Computers are pretty fast.
