local common_stubs = require("RPGLootFeed_spec/common_stubs")
local assert = require("luassert")

describe("LootDisplayRowMixin", function()
	local ns
	before_each(function()
		-- Define the global G_RLF
		ns = common_stubs.setup_G_RLF()

		-- Load the module before each test
		assert(loadfile("RPGLootFeed/LootDisplay/LootDisplayFrame/LootDisplayRow/LootDisplayRow.lua"))("TestAddon", ns)
	end)

	it("TODO", function()
		assert.is_not_nil(_G.LootDisplayRowMixin)
	end)
end)
