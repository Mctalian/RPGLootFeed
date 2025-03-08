local common_stubs = require("RPGLootFeed_spec/common_stubs")

describe("TestMode module", function()
	local ns
	before_each(function()
		-- Define the global G_RLF
		ns = ns or common_stubs.setup_G_RLF(spy)

		-- Load the module before each test
		assert(loadfile("RPGLootFeed/GameTesting/TestMode.lua"))("TestAddon", ns)
	end)

	it("TODO", function()
		assert.are.equal(true, true)
	end)
end)
