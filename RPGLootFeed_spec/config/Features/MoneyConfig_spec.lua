local nsMocks = require("RPGLootFeed_spec._mocks.Internal.addonNamespace")
local assert = require("luassert")
local busted = require("busted")
local describe = busted.describe
local it = busted.it
local setup = busted.setup

describe("MoneyConfig module", function()
	local ns
	setup(function()
		-- Define the global namespace
		-- MoneyConfig comes after CurrencyConfig in features.xml
		ns = nsMocks:unitLoadedAfter(nsMocks.LoadSections.ConfigFeatureCurrency)
		-- Load the MoneyConfig module
		assert(loadfile("RPGLootFeed/config/Features/MoneyConfig.lua"))("TestAddon", ns)
	end)

	it("should set up the money configuration defaults", function()
		-- Check that the money configuration is set up in the defaults
		assert.is_table(ns.defaults.global.money)
		assert.is_boolean(ns.defaults.global.money.enabled)
		assert.is_boolean(ns.defaults.global.money.showMoneyTotal)
		assert.is_table(ns.defaults.global.money.moneyTotalColor)
		assert.is_not_nil(ns.defaults.global.money.moneyTextWrapChar)
		assert.is_boolean(ns.defaults.global.money.abbreviateTotal)
		assert.is_boolean(ns.defaults.global.money.accountantMode)
		assert.is_boolean(ns.defaults.global.money.overrideMoneyLootSound)
		assert.is_string(ns.defaults.global.money.moneyLootSound)
	end)

	it("should set up the money configuration options", function()
		-- Check that the money configuration options are set up
		assert.is_table(ns.options.args.features.args.moneyConfig)
		assert.equal("group", ns.options.args.features.args.moneyConfig.type)
		assert.is_not_nil(ns.options.args.features.args.moneyConfig.name)
		assert.equal(ns.mainFeatureOrder.Money, ns.options.args.features.args.moneyConfig.order)
	end)

	it("should have correct color defaults for money total", function()
		local totalColor = ns.defaults.global.money.moneyTotalColor
		assert.is_table(totalColor)
		assert.equal(0.333, totalColor[1])
		assert.equal(0.333, totalColor[2])
		assert.equal(1.0, totalColor[3])
		assert.equal(1.0, totalColor[4])
	end)

	it("should use bar as default wrap character", function()
		assert.equal(ns.WrapCharEnum.BAR, ns.defaults.global.money.moneyTextWrapChar)
	end)

	it("should have required sound functions", function()
		local handler = ns.options.args.features.args.moneyConfig.handler
		assert.is_table(handler)
		assert.is_function(handler.OverrideSound)
	end)
end)
