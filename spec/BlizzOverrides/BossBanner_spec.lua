describe("BossBanner module", function()
	before_each(function()
		-- Define the global G_RLF
		local ns = {
			RLF = {},
		}
		-- Load the list module before each test

		assert(loadfile("BlizzOverrides/BossBanner.lua"))("TestAddon", ns)
	end)

	it("TODO", function()
		assert.are.equal(true, true)
	end)
end)
