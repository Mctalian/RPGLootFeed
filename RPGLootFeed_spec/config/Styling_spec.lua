local nsMocks = require("RPGLootFeed_spec._mocks.Internal.addonNamespace")
local assert = require("luassert")
local busted = require("busted")
local before_each = busted.before_each
local describe = busted.describe
local it = busted.it

describe("Styling module", function()
	local ns = {}
	before_each(function()
		-- Define the global G_RLF
		ns = nsMocks:unitLoadedAfter(nsMocks.LoadSections.ConfigFeaturesAll)
		assert(loadfile("RPGLootFeed/config/common/common.lua"))("TestAddon", ns)
		assert(loadfile("RPGLootFeed/config/common/db.utils.lua"))("TestAddon", ns)
		assert(loadfile("RPGLootFeed/config/common/styling.base.lua"))("TestAddon", ns)
		-- Load the list module before each test
		assert(loadfile("RPGLootFeed/config/Styling.lua"))("TestAddon", ns)
	end)

	it("TODO", function()
		assert.are.equal(true, true)
	end)
end)
