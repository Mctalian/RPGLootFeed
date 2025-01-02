local common_stubs = require("spec/common_stubs")

describe("ConfigOptions module", function()
	before_each(function()
		-- Define the global G_RLF
		local ns = common_stubs.setup_G_RLF(spy)
		-- Load the list module before each test
		assert(loadfile("config/ConfigOptions.lua"))("TestAddon", ns)
	end)

	it("TODO", function()
		assert.are.equal(true, true)
	end)
end)
