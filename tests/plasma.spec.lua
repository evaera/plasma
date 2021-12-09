local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Plasma = require(ReplicatedStorage.Plasma)

return function()
	describe("plasma", function()
		it("should create and destroy things", function()
			local folder = Instance.new("Folder")

			local root = Plasma.new(folder)

			Plasma.start(root, function()
				Plasma.button("hello")
			end)

			expect(folder:FindFirstChildWhichIsA("TextButton")).to.be.ok()

			Plasma.start(root, function() end)

			expect(folder:FindFirstChildWhichIsA("TextButton")).to.never.be.ok()
		end)

		it("should create and destroy from a single start point", function()
			local folder = Instance.new("Folder")

			local root = Plasma.new(folder)

			local function start(visible)
				Plasma.start(root, function()
					if visible then
						Plasma.button("hello")
					end
				end)
			end

			start(true)
			expect(folder:FindFirstChildWhichIsA("TextButton")).to.be.ok()

			start(false)

			expect(folder:FindFirstChildWhichIsA("TextButton")).to.never.be.ok()
		end)
	end)
end
