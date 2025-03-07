local common_stubs = require("RPGLootFeed_spec/common_stubs")

describe("LootDisplayFrameMixin", function()
	local ns
	before_each(function()
		-- Define the global G_RLF
		ns = ns or common_stubs.setup_G_RLF(spy)

		-- Load the module before each test
		assert(loadfile("RPGLootFeed/LootDisplay/LootDisplayFrame/LootDisplayFrame.lua"))("TestAddon", ns)
	end)

	it("TODO", function()
		assert.is_not_nil(_G.LootDisplayFrameMixin)
	end)
end)
