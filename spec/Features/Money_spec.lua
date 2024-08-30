local common_stubs = require("spec/common_stubs")

describe("Money module", function()
	local MoneyModule

	before_each(function()
		common_stubs.setup_G_RLF(spy)
		-- Load the list module before each test
		MoneyModule = dofile("Features/Money.lua")
	end)

	it("MoneyModule is not nil", function()
		assert.is_not_nil(MoneyModule)
	end)
end)
