local common_stubs = require("spec.common_stubs")

describe("Enums", function()
	local ns

	before_each(function()
		ns = common_stubs.setup_G_RLF(spy)
		assert(loadfile("utils/Enums.lua"))("TestAddon", ns)
	end)

	it("defines DisableBossBanner enum", function()
		assert.is_not_nil(ns.DisableBossBanner)
	end)

	it("defines LogEventSource enum", function()
		assert.is_not_nil(ns.LogEventSource)
	end)

	it("defines LogLevel enum", function()
		assert.is_not_nil(ns.LogLevel)
	end)

	it("defines FeatureModule enum", function()
		assert.is_not_nil(ns.FeatureModule)
	end)

	it("defines WrapCharEnum enum", function()
		assert.is_not_nil(ns.WrapCharEnum)
	end)
end)
