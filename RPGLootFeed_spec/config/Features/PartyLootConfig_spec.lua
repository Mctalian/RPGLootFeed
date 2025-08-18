local nsMocks = require("RPGLootFeed_spec._mocks.Internal.addonNamespace")
local assert = require("luassert")
local busted = require("busted")
local describe = busted.describe
local it = busted.it
local setup = busted.setup

describe("PartyLootConfig module", function()
	local ns
	setup(function()
		-- Define the global namespace
		ns = nsMocks:unitLoadedAfter(nsMocks.LoadSections.ConfigFeatureItemLoot)
		assert(loadfile("RPGLootFeed/config/common/common.lua"))("TestAddon", ns)
		assert(loadfile("RPGLootFeed/config/common/db.utils.lua"))("TestAddon", ns)
		assert(loadfile("RPGLootFeed/config/common/styling.base.lua"))("TestAddon", ns)
		-- Load the PartyLootConfig module before each test
		assert(loadfile("RPGLootFeed/config/Features/PartyLootConfig.lua"))("TestAddon", ns)
	end)

	it("should set up the party loot configuration defaults", function()
		-- Check that the party loot configuration is set up in the defaults
		assert.is_table(ns.defaults.global.partyLoot)
		assert.is_boolean(ns.defaults.global.partyLoot.enabled)
		assert.is_boolean(ns.defaults.global.partyLoot.separateFrame)
		assert.is_table(ns.defaults.global.partyLoot.itemQualityFilter)
		assert.is_table(ns.defaults.global.partyLoot.positioning)
		assert.is_table(ns.defaults.global.partyLoot.sizing)
		assert.is_table(ns.defaults.global.partyLoot.styling)
		assert.is_table(ns.defaults.global.partyLoot.ignoreItemIds)
	end)

	it("should set up the party loot configuration options", function()
		-- Check that the party loot configuration options are set up
		assert.is_table(ns.options.args.features.args.partyLootConfig)
		assert.equal("group", ns.options.args.features.args.partyLootConfig.type)
		assert.is_not_nil(ns.options.args.features.args.partyLootConfig.name)
		assert.equal(ns.mainFeatureOrder.PartyLoot, ns.options.args.features.args.partyLootConfig.order)
	end)

	it("should register the PartyLootConfig handler", function()
		-- Check that the handler is registered
		assert.is_table(ns.ConfigHandlers.PartyLootConfig)
	end)

	it("should have the required configuration methods", function()
		-- Check that the required methods exist
		local handler = ns.ConfigHandlers.PartyLootConfig
		assert.is_function(handler.GetPositioningOptions)
		assert.is_function(handler.GetSizingOptions)
		assert.is_function(handler.GetStylingOptions)
	end)

	it("should set up correct positioning defaults", function()
		local positioning = ns.defaults.global.partyLoot.positioning
		assert.is_table(positioning)
		assert.equal("UIParent", positioning.relativePoint)
		assert.equal("LEFT", positioning.anchorPoint)
		assert.equal(0, positioning.xOffset)
		assert.equal(375, positioning.yOffset)
		assert.equal("MEDIUM", positioning.frameStrata)
	end)

	it("should set up correct sizing defaults", function()
		local sizing = ns.defaults.global.partyLoot.sizing
		assert.is_table(sizing)
		assert.equal(330, sizing.feedWidth)
		assert.equal(10, sizing.maxRows)
		assert.equal(22, sizing.rowHeight)
		assert.equal(2, sizing.padding)
		assert.equal(18, sizing.iconSize)
	end)
end)
