local nsMocks = require("RPGLootFeed_spec._mocks.Internal.addonNamespace")
local assert = require("luassert")
local busted = require("busted")
local describe = busted.describe
local it = busted.it
local setup = busted.setup

describe("CurrencyConfig module", function()
	local ns
	setup(function()
		-- Define the global namespace
		-- CurrencyConfig comes after PartyLootConfig in features.xml
		ns = nsMocks:unitLoadedAfter(nsMocks.LoadSections.ConfigFeaturePartyLoot)
		-- Load the CurrencyConfig module
		assert(loadfile("RPGLootFeed/config/Features/CurrencyConfig.lua"))("TestAddon", ns)
	end)

	it("should set up the currency configuration defaults", function()
		-- Check that the currency configuration is set up in the defaults
		assert.is_table(ns.defaults.global.currency)
		assert.is_boolean(ns.defaults.global.currency.enabled)
		assert.is_boolean(ns.defaults.global.currency.currencyTotalTextEnabled)
		assert.is_table(ns.defaults.global.currency.currencyTotalTextColor)
		assert.is_not_nil(ns.defaults.global.currency.currencyTotalTextWrapChar)
		assert.is_number(ns.defaults.global.currency.lowerThreshold)
		assert.is_number(ns.defaults.global.currency.upperThreshold)
		assert.is_table(ns.defaults.global.currency.lowestColor)
		assert.is_table(ns.defaults.global.currency.midColor)
		assert.is_table(ns.defaults.global.currency.upperColor)
	end)

	it("should set up the currency configuration options", function()
		-- Check that the currency configuration options are set up
		assert.is_table(ns.options.args.features.args.currencyConfig)
		assert.equal("group", ns.options.args.features.args.currencyConfig.type)
		assert.is_not_nil(ns.options.args.features.args.currencyConfig.name)
		assert.equal(ns.mainFeatureOrder.Currency, ns.options.args.features.args.currencyConfig.order)
	end)

	it("should have correct color defaults for currency text", function()
		local textColor = ns.defaults.global.currency.currencyTotalTextColor
		assert.is_table(textColor)
		assert.equal(0.737, textColor[1])
		assert.equal(0.737, textColor[2])
		assert.equal(0.737, textColor[3])
		assert.equal(1, textColor[4])
	end)

	it("should have correct threshold values", function()
		assert.equal(0.7, ns.defaults.global.currency.lowerThreshold)
		assert.equal(0.9, ns.defaults.global.currency.upperThreshold)
	end)

	it("should use parenthesis as default wrap character", function()
		assert.equal(ns.WrapCharEnum.PARENTHESIS, ns.defaults.global.currency.currencyTotalTextWrapChar)
	end)
end)
