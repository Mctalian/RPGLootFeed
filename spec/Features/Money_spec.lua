local common_stubs = require("spec/common_stubs")

describe("Money module", function()
	local MoneyModule

	before_each(function()
		common_stubs.setup_G_RLF(spy)
		common_stubs.stub_Money_Funcs()
		-- Load the list module before each test
		MoneyModule = require("Features/Money")
	end)

	it("MoneyModule is not nil", function()
		assert.is_not_nil(MoneyModule)
	end)
end)
