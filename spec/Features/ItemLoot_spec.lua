local common_stubs = require("spec/common_stubs")

describe("ItemLoot module", function()
	local LootModule

	before_each(function()
		-- Define the global G_RLF
		common_stubs.setup_G_RLF(spy)
		-- Load the list module before each test
		LootModule = dofile("Features/ItemLoot.lua")
	end)

	it("LootModule is not nil", function()
		assert.is_not_nil(LootModule)
	end)
end)
