describe("ConfigOptions module", function()
	before_each(function()
		-- Define the global G_RLF
		_G.G_RLF = {
			defaults = {
				global = {},
			},
			L = {},
			options = {
				args = {},
			},
			DisableBossBanner = {
				ENABLED = 0,
				FULLY_DISABLE = 1,
				DISABLE_LOOT = 2,
				DISABLE_MY_LOOT = 3,
				DISABLE_GROUP_LOOT = 4,
			},
		}
		-- Load the list module before each test
		dofile("config/ConfigOptions.lua")
	end)

	it("TODO", function()
		assert.are.equal(true, true)
	end)
end)
