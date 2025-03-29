local nsMocks = require("RPGLootFeed_spec._mocks.Internal.addonNamespace")
local assert = require("luassert")
local busted = require("busted")
local describe = busted.describe
local it = busted.it
local setup = busted.setup

describe("ReputationConfig module", function()
	local ns
	setup(function()
		-- Define the global namespace
		-- ReputationConfig comes after ExperienceConfig in features.xml
		ns = nsMocks:unitLoadedAfter(nsMocks.LoadSections.ConfigFeatureXP)
		-- Load the ReputationConfig module
		assert(loadfile("RPGLootFeed/config/Features/ReputationConfig.lua"))("TestAddon", ns)
	end)

	it("should set up the reputation configuration defaults", function()
		-- Check that the reputation configuration is set up in the defaults
		assert.is_table(ns.defaults.global.rep)
		assert.is_boolean(ns.defaults.global.rep.enabled)
		assert.is_table(ns.defaults.global.rep.defaultRepColor)
		assert.is_number(ns.defaults.global.rep.secondaryTextAlpha)
		assert.is_boolean(ns.defaults.global.rep.enableRepLevel)
		assert.is_table(ns.defaults.global.rep.repLevelColor)
		assert.is_not_nil(ns.defaults.global.rep.repLevelTextWrapChar)
	end)

	it("should set up the reputation configuration options", function()
		-- Check that the reputation configuration options are set up
		assert.is_table(ns.options.args.features.args.repConfig)
		assert.equal("group", ns.options.args.features.args.repConfig.type)
		assert.is_not_nil(ns.options.args.features.args.repConfig.name)
		assert.equal(ns.mainFeatureOrder.Rep, ns.options.args.features.args.repConfig.order)
	end)

	it("should have correct color defaults for reputation text", function()
		local repColor = ns.defaults.global.rep.defaultRepColor
		assert.is_table(repColor)
		assert.equal(0.5, repColor[1])
		assert.equal(0.5, repColor[2])
		assert.equal(1, repColor[3])
	end)

	it("should have correct color defaults for reputation level text", function()
		local levelColor = ns.defaults.global.rep.repLevelColor
		assert.is_table(levelColor)
		assert.equal(0.5, levelColor[1])
		assert.equal(0.5, levelColor[2])
		assert.equal(1, levelColor[3])
		assert.equal(1, levelColor[4])
	end)

	it("should have correct secondary text alpha", function()
		assert.equal(0.7, ns.defaults.global.rep.secondaryTextAlpha)
	end)

	it("should use angle brackets as default wrap character for reputation level", function()
		assert.equal(ns.WrapCharEnum.ANGLE, ns.defaults.global.rep.repLevelTextWrapChar)
	end)
end)
