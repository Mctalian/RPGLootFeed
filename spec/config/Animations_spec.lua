local common_stubs = require("spec/common_stubs")

describe("Animations module", function()
	local ns
	before_each(function()
		-- Define the global G_RLF
		ns = common_stubs.setup_G_RLF(spy)
		-- Load the list module before each test
		assert(loadfile("config/Animations.lua"))("TestAddon", ns)
	end)

	it("TODO", function()
		assert.are.equal(true, true)
	end)
end)
