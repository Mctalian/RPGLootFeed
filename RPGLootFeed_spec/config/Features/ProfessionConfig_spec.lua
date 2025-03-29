local nsMocks = require("RPGLootFeed_spec._mocks.Internal.addonNamespace")
local assert = require("luassert")
local busted = require("busted")
local describe = busted.describe
local it = busted.it
local setup = busted.setup

describe("ProfessionConfig module", function()
	local ns
	setup(function()
		-- Define the global namespace
		-- ProfessionConfig comes after ReputationConfig in features.xml
		ns = nsMocks:unitLoadedAfter(nsMocks.LoadSections.ConfigFeatureRep)
		-- Load the ProfessionConfig module
		assert(loadfile("RPGLootFeed/config/Features/ProfessionConfig.lua"))("TestAddon", ns)
	end)

	it("should set up the profession configuration defaults", function()
		-- Check that the profession configuration is set up in the defaults
		assert.is_table(ns.defaults.global.prof)
		assert.is_boolean(ns.defaults.global.prof.enabled)
		assert.is_boolean(ns.defaults.global.prof.showSkillChange)
		assert.is_table(ns.defaults.global.prof.skillColor)
		assert.is_not_nil(ns.defaults.global.prof.skillTextWrapChar)
	end)

	it("should set up the profession configuration options", function()
		-- Check that the profession configuration options are set up
		assert.is_table(ns.options.args.features.args.professionConfig)
		assert.equal("group", ns.options.args.features.args.professionConfig.type)
		assert.is_not_nil(ns.options.args.features.args.professionConfig.name)
		assert.equal(ns.mainFeatureOrder.Skills, ns.options.args.features.args.professionConfig.order)
	end)

	it("should have correct color defaults for skill text", function()
		local skillColor = ns.defaults.global.prof.skillColor
		assert.is_table(skillColor)
		assert.equal(0.333, skillColor[1])
		assert.equal(0.333, skillColor[2])
		assert.equal(1.0, skillColor[3])
		assert.equal(1.0, skillColor[4])
	end)

	it("should use brackets as default wrap character for skill text", function()
		assert.equal(ns.WrapCharEnum.BRACKET, ns.defaults.global.prof.skillTextWrapChar)
	end)
end)
