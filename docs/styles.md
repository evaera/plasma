---
sidebar_position: 5
---

# Styles

Styles are accessed with the `useStyle` and `setStyle` functions. Styles are similar to CSS in that they cascade downwards in the tree.

Styles are not anything special, they are just configuration. It's up to the widgets to read from the specified styles and use the values.

## useStyle

Returns the current style information, with styles that are set more recently in the tree overriding styles that were set further up. In this way, styles cascade downwards, similar to CSS.

## setStyle

Defines style for any subsequent calls in this scope. Merges with any existing styles.

## Default styles

By default, these styles are used. You can override them anywhere:

```lua
{
	bg1 = Color3.fromRGB(31, 31, 31),
	bg2 = Color3.fromRGB(42, 42, 42),
	bg3 = Color3.fromRGB(54, 54, 54),
	mutedTextColor = Color3.fromRGB(147, 147, 147),
	textColor = Color3.fromRGB(255, 255, 255),
}
```