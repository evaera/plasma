---
sidebar_position: 4
---

# Internals of Hooks

Hooks are topologically-aware functions. This means that when you use a hook like `useState` or `useEffect`, they are aware of the call stack and hold their own state outside of arguments and return values.

Their state is actually keyed by your script name and the line number you call them on! This state is kept in the enclosing *scope*. Scopes are created every time you use a new widget or create children inside of a widget. You can also create a new scope manually with the `Plasma.scope` function.

Even if code runs multiple times in a single frame, state will always be separated by scope. This means you can use the same widget multiple times in a single frame, and their state will be separate because they are all inside of separate scopes.

If called in a loop, hooks hold state by number of times that line was called consecutively.

Check out the [API reference](/api#useContext) to learn more.