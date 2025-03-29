local nsMocks = require("RPGLootFeed_spec._mocks.Internal.addonNamespace")
local assert = require("luassert")

describe("Sizing module", function()
	local ns
	before_each(function()
		-- Define the global G_RLF
		ns = nsMocks:unitLoadedAfter(nsMocks.LoadSections.All)
		-- Load the list module before each test
		assert(loadfile("RPGLootFeed/config/Sizing.lua"))("TestAddon", ns)
	end)

	it("TODO", function()
		assert.are.equal(true, true)
	end)
end)
