local nsMocks = require("RPGLootFeed_spec._mocks.Internal.addonNamespace")
local assert = require("luassert")
local busted = require("busted")
local describe = busted.describe
local it = busted.it
local setup = busted.setup

describe("ItemConfig module", function()
	local ns, functionMocks
	setup(function()
		-- Define the global namespace
		ns = nsMocks:unitLoadedAfter(nsMocks.LoadSections.ConfigFeaturesInit)
		functionMocks = require("RPGLootFeed_spec._mocks.WoWGlobals.Functions")
		-- Load the ItemConfig module before each test
		assert(loadfile("RPGLootFeed/config/Features/ItemConfig.lua"))("TestAddon", ns)
	end)

	it("should set up the item configuration defaults", function()
		-- Check that the item configuration is set up in the defaults
		assert.is_table(ns.defaults.global.item)
		assert.is_boolean(ns.defaults.global.item.enabled)
		assert.is_boolean(ns.defaults.global.item.itemCountTextEnabled)
		assert.is_table(ns.defaults.global.item.itemCountTextColor)
		assert.is_table(ns.defaults.global.item.itemQualitySettings)
		assert.is_table(ns.defaults.global.item.itemHighlights)
		assert.is_table(ns.defaults.global.item.sounds)
	end)

	it("should set up the item configuration options", function()
		-- Check that the item configuration options are set up
		assert.is_table(ns.options.args.features.args.itemLootConfig)
		assert.equal("group", ns.options.args.features.args.itemLootConfig.type)
		assert.is_not_nil(ns.options.args.features.args.itemLootConfig.name)
		assert.equal(ns.mainFeatureOrder.ItemLoot, ns.options.args.features.args.itemLootConfig.order)
	end)

	it("should set up item quality settings", function()
		-- Check that all item qualities are configured
		local qualities = ns.defaults.global.item.itemQualitySettings
		local qualityEnum = ns.ItemQualEnum

		assert.is_table(qualities[qualityEnum.Poor])
		assert.is_table(qualities[qualityEnum.Common])
		assert.is_table(qualities[qualityEnum.Uncommon])
		assert.is_table(qualities[qualityEnum.Rare])
		assert.is_table(qualities[qualityEnum.Epic])
		assert.is_table(qualities[qualityEnum.Legendary])
		assert.is_table(qualities[qualityEnum.Artifact])
		assert.is_table(qualities[qualityEnum.Heirloom])
	end)

	it("should have a SoundOptionValues function", function()
		local handler = ns.options.args.features.args.itemLootConfig.handler
		assert.is_table(handler)
		assert.is_function(handler.SoundOptionValues)
	end)
end)
