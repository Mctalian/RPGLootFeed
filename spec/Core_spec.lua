describe("Core module", function()
	local ns
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

		ns = {}
		-- Load the list module before each test
		assert(loadfile("Core.lua"))("TestAddon", ns)
	end)

	describe("RGBAToHexFormat", function()
		it("converts RGBA01 to WoW's hex color format", function()
			local result = ns:RGBAToHexFormat(0.1, 0.2, 0.3, 0.4)
			assert.are.equal(result, "|c6619334C")
		end)
	end)
end)
