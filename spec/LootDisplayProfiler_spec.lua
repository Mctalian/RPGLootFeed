local common_stubs = require("spec/common_stubs")

describe("LootDisplayProfiler module", function()
	local ns
	before_each(function()
		_G.LibStub = function()
			return {
				GetLocale = function() end,
			}
		end
		_G.LootDisplayFrameMixin = {}
		_G.LootDisplayRowMixin = {}
		-- Define the global G_RLF
		ns = ns or common_stubs.setup_G_RLF(spy)

		-- Load the list module before each test
		assert(loadfile("LootDisplayProfiler.lua"))("TestAddon", ns)
	end)

	it("TODO", function()
		assert.are.equal(true, true)
	end)
end)
