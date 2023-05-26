local Runtime = require(script.Parent.Runtime)

local ContextKey = Runtime.createContext("Field")

local Field = {
	FieldValueType = {
		TEXTBOX = 1,
		CHECKBOX = 2,
		TEXTLABEL = 3,
	}
}

local defaultFieldOptions = {
	depth = 0,
}

function Field.getOptions()
	return Runtime.useContext(ContextKey) or defaultFieldOptions
end

function Field.setOptions(optionsFragment)
	local existing = Runtime.useContext(ContextKey) or defaultFieldOptions
	local new = table.clone(existing)

	for key, value in pairs(optionsFragment) do
		new[key] = value
	end

	Runtime.provideContext(ContextKey, new)
end

return Field
