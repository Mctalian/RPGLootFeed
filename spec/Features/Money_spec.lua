describe("Money module", function()
	local MoneyModule

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
		MoneyModule = dofile("Features/Money.lua")
	end)

	it("MoneyModule is not nil", function()
		assert.is_not_nil(MoneyModule)
	end)
end)
