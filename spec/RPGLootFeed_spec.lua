describe("RPGLootFeed module", function()
	before_each(function()
		_G.LibStub = function()
			return {
				GetLocale = function() end,
			}
		end
		-- Define the global G_RLF
		local ns = {
			RLF = {},
		}
		-- Load the list module before each test
		assert(loadfile("RPGLootFeed.lua"))("TestAddon", ns)
	end)

	it("TODO", function()
		assert.are.equal(true, true)
	end)
end)
