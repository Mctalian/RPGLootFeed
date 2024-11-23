local common_stubs = require("spec/common_stubs")

describe("Logger module", function()
	local ns
	before_each(function()
		_G.LibStub = function()
			return {
				GetLocale = function() end,
			}
		end
		-- Define the global G_RLF
		ns = ns or common_stubs.setup_G_RLF(spy)

		-- Load the module before each test
		assert(loadfile("utils/Logger.lua"))("TestAddon", ns)
	end)

	it("TODO", function()
		assert.are.equal(true, true)
	end)
end)
