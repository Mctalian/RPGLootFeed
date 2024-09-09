local common_stubs = require("spec.common_stubs")

describe("LootDisplay module", function()
	local LootDisplayModule
	before_each(function()
		-- Define the global G_RLF
		common_stubs.setup_G_RLF(spy)
		-- Load the list module before each test
		LootDisplayModule = require("LootDisplay")
	end)

	it("creates the module", function()
		assert.is_not_nil(LootDisplayModule)
	end)
end)
