describe("Core module", function()
	before_each(function()
		_G.LibStub = function()
			return {
				NewAddon = function()
					return {
						SetDefaultModuleState = function() end,
						SetDefaultModulePrototype = function() end,
					}
				end,
			}
		end

		local ns = {}
		-- Load the list module before each test
		assert(loadfile("Core.lua"))("TestAddon", ns)
	end)

	it("TODO", function()
		assert.are.equal(true, true)
	end)
end)
