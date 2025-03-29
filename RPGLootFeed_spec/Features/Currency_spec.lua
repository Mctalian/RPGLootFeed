local nsMocks = require("RPGLootFeed_spec._mocks.Internal.addonNamespace")
local assert = require("luassert")
local busted = require("busted")
local setup = busted.setup
local stub = busted.stub
local before_each = busted.before_each
local describe = busted.describe
local it = busted.it

describe("Currency module", function()
	local _ = match._
	---@type RLF_Currency, test_G_RLF
	local CurrencyModule, ns
	local currencyInfoMocks

	setup(function() end)

	before_each(function()
		require("RPGLootFeed_spec._mocks.WoWGlobals.Constants")
		require("RPGLootFeed_spec._mocks.WoWGlobals.Functions")
		require("RPGLootFeed_spec._mocks.Libs.LibStub")
		currencyInfoMocks = require("RPGLootFeed_spec._mocks.WoWGlobals.namespaces.C_CurrencyInfo")
		ns = nsMocks:unitLoadedAfter(nsMocks.LoadSections.All)

		-- Load the LootDisplayProperties module to populate `ns`
		assert(loadfile("RPGLootFeed/Features/LootDisplayProperties.lua"))("TestAddon", ns)

		-- Ensure `ns` has been populated correctly by LootDisplayProperties
		assert.is_not_nil(ns.InitializeLootDisplayProperties)

		-- Load the list module before each test
		---@type RLF_Currency
		CurrencyModule = assert(loadfile("RPGLootFeed/Features/Currency/Currency.lua"))("TestAddon", ns) ---[[@as RLF_Currency]]
	end)

	it("does not show loot if the currency type is nil", function()
		ns.db.global.currency.enabled = true

		CurrencyModule:CURRENCY_DISPLAY_UPDATE(_, nil)

		assert.stub(ns.SendMessage).was.not_called()
	end)

	it("does not show loot if the quantityChange is nil", function()
		ns.db.global.currency.enabled = true

		CurrencyModule:CURRENCY_DISPLAY_UPDATE(_, 123, nil, nil)

		assert.stub(ns.SendMessage).was.not_called()
	end)

	it("does not show loot if the quantityChange is lte 0", function()
		ns.db.global.currency.enabled = true

		CurrencyModule:CURRENCY_DISPLAY_UPDATE(_, 123, nil, -1)

		assert.stub(ns.SendMessage).was.not_called()
	end)

	it("does not show loot if the currency info cannot be found", function()
		ns.db.global.currency.enabled = true
		currencyInfoMocks.GetCurrencyInfo:revert()
		currencyInfoMocks.GetCurrencyInfo = stub(_G.C_CurrencyInfo, "GetCurrencyInfo").returns(nil)

		CurrencyModule:CURRENCY_DISPLAY_UPDATE(_, 123, 1, 1)

		assert.stub(ns.SendMessage).was.not_called()
		currencyInfoMocks.GetCurrencyInfo:revert()
	end)

	it("does not show loot if the currency has an empty description", function()
		ns.db.global.currency.enabled = true
		currencyInfoMocks.GetCurrencyInfo:revert()
		currencyInfoMocks.GetCurrencyInfo = stub(_G.C_CurrencyInfo, "GetCurrencyInfo").returns({
			currencyID = 123,
			description = "",
			iconFileID = 123456,
		})

		CurrencyModule:CURRENCY_DISPLAY_UPDATE(_, 123, 5, 2)

		assert.stub(ns.SendMessage).was.not_called()
		currencyInfoMocks.GetCurrencyInfo:revert()
	end)

	it("shows loot if the currency info is valid", function()
		ns.db.global.currency.enabled = true
		local info = {
			currencyID = 123,
			description = "An awesome currency",
			iconFileID = 123456,
			quantity = 5,
			quality = 2,
		}
		local link = "|c12345678|Hcurrency:123|r"
		local basicInfo = {
			name = "Best Coin",
			description = "An awesome currency",
			icon = 123456,
			quality = 2,
			displayAmount = 2,
			actualAmount = 2,
		}
		currencyInfoMocks.GetCurrencyInfo:revert()
		currencyInfoMocks.GetCurrencyLink:revert()
		currencyInfoMocks.GetBasicCurrencyInfo:revert()
		currencyInfoMocks.GetCurrencyInfo = stub(_G.C_CurrencyInfo, "GetCurrencyInfo").returns(info)
		currencyInfoMocks.GetCurrencyLink = stub(_G.C_CurrencyInfo, "GetCurrencyLink").returns(link)
		currencyInfoMocks.GetBasicCurrencyInfo = stub(_G.C_CurrencyInfo, "GetBasicCurrencyInfo").returns(basicInfo)

		local newElement = spy.on(CurrencyModule.Element, "new")

		CurrencyModule:CURRENCY_DISPLAY_UPDATE(_, 123, 5, 2)

		assert.spy(newElement).was.called_with(_, "|c12345678|Hcurrency:123|r", info, basicInfo)
		assert.stub(ns.SendMessage).was.called(1)
		currencyInfoMocks.GetBasicCurrencyInfo:revert()
		currencyInfoMocks.GetCurrencyLink:revert()
		currencyInfoMocks.GetCurrencyInfo:revert()
	end)
end)
