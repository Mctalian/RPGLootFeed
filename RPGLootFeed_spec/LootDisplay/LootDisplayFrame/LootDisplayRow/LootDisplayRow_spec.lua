local nsMocks = require("RPGLootFeed_spec._mocks.Internal.addonNamespace")
local assert = require("luassert")
local busted = require("busted")
local before_each = busted.before_each
local describe = busted.describe
local it = busted.it

describe("LootDisplayRowMixin", function()
	local ns
	before_each(function()
		-- Define the global G_RLF
		ns = nsMocks:unitLoadedAfter(nsMocks.LoadSections.All)

		-- Load the module before each test
		assert(loadfile("RPGLootFeed/LootDisplay/LootDisplayFrame/LootDisplayRow/LootDisplayRow.lua"))("TestAddon", ns)
	end)

	it("TODO", function()
		assert.is_not_nil(_G.LootDisplayRowMixin)
	end)
end)
