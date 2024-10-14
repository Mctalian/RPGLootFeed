describe("Styling module", function()
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
			lsm = {
				MediaType = {
					["FONT"] = "font",
				},
			},
		}
		function ns.lsm:HashTable()
			return {
				["Test"] = "Test",
			}
		end
		-- Load the list module before each test
		assert(loadfile("config/Styling.lua"))("TestAddon", ns)
	end)

	it("TODO", function()
		assert.are.equal(true, true)
	end)
end)
