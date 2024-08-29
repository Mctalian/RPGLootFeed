describe("ItemLoot module", function()
	local LootModule

	before_each(function()
		-- Define the global G_RLF
		_G.G_RLF = {
			RLF = {
				NewModule = function()
					return {}
				end,
			},
		}
		-- Load the list module before each test
		LootModule = dofile("Features/ItemLoot.lua")
	end)

	it("LootModule is not nil", function()
		assert.is_not_nil(LootModule)
	end)
end)
