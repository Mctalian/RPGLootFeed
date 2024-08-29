describe("Reputation module", function()
	local RepModule

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
		RepModule = dofile("Features/Reputation.lua")
	end)

	it("RepModule is not nil", function()
		assert.is_not_nil(RepModule)
	end)
end)
