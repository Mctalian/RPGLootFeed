local common_stubs = require("RPGLootFeed_spec/common_stubs")

describe("LootDisplay module", function()
	local LootDisplayModule, ns
	before_each(function()
		-- Define the global G_RLF
		ns = ns or common_stubs.setup_G_RLF(spy)

		-- Load the list module before each test
		LootDisplayModule = assert(loadfile("RPGLootFeed/LootDisplay/LootDisplay.lua"))("TestAddon", ns)
	end)

	it("creates the module", function()
		assert.is_not_nil(LootDisplayModule)
	end)
end)
