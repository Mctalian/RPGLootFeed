describe("AddonScope module", function()
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
		-- Load the list module before each test
		require("AddonScope")
	end)

	it("TODO", function()
		assert.are.equal(true, true)
	end)
end)
