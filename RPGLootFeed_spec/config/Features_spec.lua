describe("Features module", function()
	before_each(function()
		-- Define the global G_RLF
		local ns = {
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
		_G.Enum = {
			ItemQuality = {
				Poor = 0,
				Common = 1,
				Uncommon = 2,
				Rare = 3,
				Epic = 4,
				Legendary = 5,
				Artifact = 6,
				Heirloom = 7,
				WoWToken = 8,
			},
		}
		-- Load the list module before each test
		assert(loadfile("RPGLootFeed/config/Features/Features.lua"))("TestAddon", ns)
	end)

	it("TODO", function()
		assert.are.equal(true, true)
	end)
end)
