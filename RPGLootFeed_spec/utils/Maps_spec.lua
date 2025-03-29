local nsMocks = require("RPGLootFeed_spec._mocks.Internal.addonNamespace")
local assert = require("luassert")
local busted = require("busted")
local before_each = busted.before_each
local describe = busted.describe
local it = busted.it
local setup = busted.setup

describe("Maps", function()
	local ns

	setup(function()
		ns = nsMocks:unitLoadedAfter(nsMocks.LoadSections.UtilsLogger)
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
