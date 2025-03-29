local common_stubs = require("RPGLootFeed_spec/common_stubs")
local assert = require("luassert")

describe("Maps", function()
	local ns

	before_each(function()
		require("RPGLootFeed_spec._mocks.WoWGlobals.Enum")
		ns = common_stubs.setup_G_RLF()
		assert(loadfile("RPGLootFeed/utils/Maps.lua"))("TestAddon", ns)
	end)

	it("defines armorClassMapping", function()
		assert.is_not_nil(ns.armorClassMapping)
	end)

	it("defines equipSlotMap", function()
		assert.is_not_nil(ns.equipSlotMap)
	end)

	it("defines tertiaryToString", function()
		assert.is_not_nil(ns.tertiaryToString)
	end)
end)
