local nsMocks = require("RPGLootFeed_spec._mocks.Internal.addonNamespace")
local assert = require("luassert")

describe("ConfigOptions module", function()
	before_each(function()
		-- Define the global G_RLF
		local ns = nsMocks:unitLoadedAfter(nsMocks.LoadSections.All)
		-- Load the list module before each test
		assert(loadfile("RPGLootFeed/config/ConfigOptions.lua"))("TestAddon", ns)
	end)

	it("TODO", function()
		assert.are.equal(true, true)
	end)
end)
