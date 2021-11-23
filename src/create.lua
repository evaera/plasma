local function create(className, props)
	local instance = Instance.new(className)

	for key, value in pairs(props) do
		if type(value) == "function" then
			instance[key]:Connect(value)
		elseif type(key) == "number" then
			value.Parent = instance
		else
			instance[key] = value
		end
	end

	return instance
end

return create
