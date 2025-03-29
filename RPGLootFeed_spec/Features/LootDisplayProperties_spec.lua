local nsMocks = require("RPGLootFeed_spec._mocks.Internal.addonNamespace")
local assert = require("luassert")

describe("LootDisplayProperties module", function()
	local LootModule, ns

	before_each(function()
		-- Define the global G_RLF
		ns = nsMocks:unitLoadedAfter(nsMocks.LoadSections.All)
		-- Load the list module before each test
		LootModule = assert(loadfile("RPGLootFeed/Features/LootDisplayProperties.lua"))("TestAddon", ns)
	end)

	it("LootModule is not nil", function()
		assert.is_not_nil(LootModule)
	end)
end)
