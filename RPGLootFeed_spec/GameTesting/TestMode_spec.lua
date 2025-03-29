local common_stubs = require("RPGLootFeed_spec/common_stubs")
local assert = require("luassert")

describe("TestMode module", function()
	local ns
	before_each(function()
		require("RPGLootFeed_spec._mocks.Libs.LibStub")
		-- Define the global G_RLF
		ns = common_stubs.setup_G_RLF()

		-- Load the module before each test
		assert(loadfile("RPGLootFeed/GameTesting/TestMode.lua"))("TestAddon", ns)
	end)

	it("TODO", function()
		assert.are.equal(true, true)
	end)
end)
