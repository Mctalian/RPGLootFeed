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
		}
		_G.LibStub = function(lib)
			if lib == "LibSharedMedia-3.0" then
				local l = {}
				function l:HashTable()
					return {
						["Test"] = "Test",
					}
				end
				l.MediaType = {
					["FONT"] = "font",
				}
				return l
			end
			return nil
		end
		-- Load the list module before each test
		assert(loadfile("config/Styling.lua"))("TestAddon", ns)
	end)

	it("TODO", function()
		assert.are.equal(true, true)
	end)
end)
