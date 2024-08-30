local common_stubs = require("spec/common_stubs")

describe("Reputation module", function()
	local RepModule

	before_each(function()
		common_stubs.setup_G_RLF(spy)
		-- Load the list module before each test
		RepModule = dofile("Features/Reputation.lua")
	end)

	it("RepModule is not nil", function()
		assert.is_not_nil(RepModule)
	end)
end)
