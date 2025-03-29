local common_stubs = require("RPGLootFeed_spec/common_stubs")
local assert = require("luassert")

describe("LootDisplay module", function()
	local LootDisplayModule, ns
	before_each(function()
		require("RPGLootFeed_spec._mocks.WoWGlobals")
		-- Define the global G_RLF
		ns = common_stubs.setup_G_RLF()

		-- Load the list module before each test
		LootDisplayModule = assert(loadfile("RPGLootFeed/LootDisplay/LootDisplay.lua"))("TestAddon", ns)
	end)

	it("creates the module", function()
		assert.is_not_nil(LootDisplayModule)
	end)
end)
