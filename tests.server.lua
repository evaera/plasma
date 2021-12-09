local ReplicatedStorage = game:GetService("ReplicatedStorage")

require(ReplicatedStorage.TestEZ).TestBootstrap:run({
	ReplicatedStorage.Plasma,
	ReplicatedStorage.Tests,
})
