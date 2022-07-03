local CollectionService = game:GetService("CollectionService")
local automaticSize = require(script.Parent.automaticSize)

--[=[
	Applies automatic sizing to any current or future instances in the DataModel that are tagged with
	`"PlasmaAutomaticSize"`. Attributes `axis` (string) and `maxSize` (UDim2 or Vector2) are allowed.

	@within Plasma
	@tag utilities
	@client
	@return RBXScriptConnection
]=]
local function hydrateAutomaticSize()
	for _, instance in CollectionService:GetTagged("PlasmaAutomaticSize") do
		automaticSize(instance)
	end

	return CollectionService:GetInstanceAddedSignal("PlasmaAutomaticSize"):Connect(function(instance)
		task.defer(automaticSize, instance) -- instance added signal fires before children are added
	end)
end

return hydrateAutomaticSize
