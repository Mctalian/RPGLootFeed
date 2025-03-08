local common_stubs = require("RPGLootFeed_spec/common_stubs")

describe("LootDisplayProperties module", function()
	local LootModule, ns

	before_each(function()
		-- Define the global G_RLF
		ns = ns or common_stubs.setup_G_RLF(spy)
		-- Load the list module before each test
		LootModule = assert(loadfile("RPGLootFeed/Features/LootDisplayProperties.lua"))("TestAddon", ns)
	end)

	it("LootModule is not nil", function()
		assert.is_not_nil(LootModule)
	end)
end)
