---@see RLF_Currency
local nsMocks = require("RPGLootFeed_spec._mocks.Internal.addonNamespace")
local assert = require("luassert")
local match = require("luassert.match")
local busted = require("busted")
local setup = busted.setup
local spy = busted.spy
local stub = busted.stub
local before_each = busted.before_each
local describe = busted.describe
local it = busted.it

describe("Currency module", function()
	local _ = match._
	---@type RLF_Currency, test_G_RLF
	local CurrencyModule, ns
	local currencyInfoMocks, functionMocks

	describe("load order", function()
		it("loads the file successfully", function()
			ns = nsMocks:unitLoadedAfter(nsMocks.LoadSections.FeatureCurrencyHidden)
			local currencyModule = assert(loadfile("RPGLootFeed/Features/Currency/Currency.lua"))("TestAddon", ns)
			assert.is_not_nil(currencyModule)
			assert.is_not_nil(currencyModule.CURRENCY_DISPLAY_UPDATE)
			assert.is_not_nil(currencyModule.PERKS_PROGRAM_CURRENCY_AWARDED)
			assert.is_not_nil(currencyModule.Process)
			assert.is_not_nil(currencyModule.Element)
			assert.is_not_nil(currencyModule.moduleName)
			assert.is_not_nil(currencyModule.OnInitialize)
			assert.is_not_nil(currencyModule.OnEnable)
			assert.is_not_nil(currencyModule.OnDisable)
		end)
	end)

	setup(function() end)

	before_each(function()
		require("RPGLootFeed_spec._mocks.WoWGlobals.Constants")
		functionMocks = require("RPGLootFeed_spec._mocks.WoWGlobals.Functions")
		currencyInfoMocks = require("RPGLootFeed_spec._mocks.WoWGlobals.namespaces.C_CurrencyInfo")
		require("RPGLootFeed_spec._mocks.Libs.LibStub")
		ns = nsMocks:unitLoadedAfter(nsMocks.LoadSections.All)

		-- Load the LootDisplayProperties module to populate `ns`
		assert(loadfile("RPGLootFeed/Features/LootDisplayProperties.lua"))("TestAddon", ns)

		-- Ensure `ns` has been populated correctly by LootDisplayProperties
		assert.is_not_nil(ns.InitializeLootDisplayProperties)

		-- Load the list module before each test
		---@type RLF_Currency
		CurrencyModule = assert(loadfile("RPGLootFeed/Features/Currency/Currency.lua"))("TestAddon", ns) ---[[@as RLF_Currency]]
	end)

	describe("Lifecycle event handlers", function()
		before_each(function()
			functionMocks.GetExpansionLevel.returns(nil)
		end)

		it("OnInitialize sets up the module correctly if the feature is enabled", function()
			ns.db.global.currency.enabled = true
			local spyEnable = spy.on(CurrencyModule, "Enable")
			local spyDisable = spy.on(CurrencyModule, "Disable")
			functionMocks.GetExpansionLevel.returns(ns.Expansion.SL)
			CurrencyModule:OnInitialize()

			assert.spy(spyEnable).was.called(1)
			assert.spy(spyDisable).was.not_called()
		end)

		it("OnInitialize does not set up the module if the feature is disabled", function()
			ns.db.global.currency.enabled = false
			local spyEnable = spy.on(CurrencyModule, "Enable")
			local spyDisable = spy.on(CurrencyModule, "Disable")
			functionMocks.GetExpansionLevel.returns(ns.Expansion.SL)
			CurrencyModule:OnInitialize()

			assert.spy(spyEnable).was.not_called()
			assert.spy(spyDisable).was.called(1)
		end)

		it("OnInitialize does not set up the module if the expansion level is lower than SL", function()
			ns.db.global.currency.enabled = true
			local spyEnable = spy.on(CurrencyModule, "Enable")
			local spyDisable = spy.on(CurrencyModule, "Disable")
			functionMocks.GetExpansionLevel.returns(ns.Expansion.BFA)
			CurrencyModule:OnInitialize()

			assert.spy(spyEnable).was.not_called()
			assert.spy(spyDisable).was.called(1)
		end)

		it("OnEnable registers events correctly for Retail expansions gte SL", function()
			functionMocks.GetExpansionLevel.returns(ns.Expansion.SL)
			nsMocks.IsRetail.returns(true)
			local spyRegisterEvent = spy.on(CurrencyModule, "RegisterEvent")

			CurrencyModule:OnEnable()

			assert.stub(spyRegisterEvent).was.called(2)
			assert.stub(spyRegisterEvent).was.called_with(CurrencyModule, "CURRENCY_DISPLAY_UPDATE")
			assert.stub(spyRegisterEvent).was.called_with(CurrencyModule, "PERKS_PROGRAM_CURRENCY_AWARDED")
		end)

		it("OnEnable registers events correctly for Classic expansions gte SL", function()
			functionMocks.GetExpansionLevel.returns(ns.Expansion.SL)
			nsMocks.IsRetail.returns(false)
			local spyRegisterEvent = spy.on(CurrencyModule, "RegisterEvent")

			CurrencyModule:OnEnable()

			assert.stub(spyRegisterEvent).was.called(1)
			assert.stub(spyRegisterEvent).was.called_with(CurrencyModule, "CURRENCY_DISPLAY_UPDATE")
		end)

		it("OnEnable does not register events for expansions lower than SL", function()
			functionMocks.GetExpansionLevel.returns(ns.Expansion.BFA)
			local spyRegisterEvent = spy.on(CurrencyModule, "RegisterEvent")

			CurrencyModule:OnEnable()

			assert.stub(spyRegisterEvent).was.not_called()
		end)

		it("OnDisable unregisters events correctly for Retail expansions gte SL", function()
			functionMocks.GetExpansionLevel.returns(ns.Expansion.SL)
			nsMocks.IsRetail.returns(true)
			local spyUnregisterEvent = spy.on(CurrencyModule, "UnregisterEvent")

			CurrencyModule:OnDisable()

			assert.stub(spyUnregisterEvent).was.called(2)
			assert.stub(spyUnregisterEvent).was.called_with(CurrencyModule, "CURRENCY_DISPLAY_UPDATE")
			assert.stub(spyUnregisterEvent).was.called_with(CurrencyModule, "PERKS_PROGRAM_CURRENCY_AWARDED")
		end)

		it("OnDisable unregisters events correctly for Classic expansions gte SL", function()
			functionMocks.GetExpansionLevel.returns(ns.Expansion.SL)
			nsMocks.IsRetail.returns(false)
			local spyUnregisterEvent = spy.on(CurrencyModule, "UnregisterEvent")

			CurrencyModule:OnDisable()

			assert.stub(spyUnregisterEvent).was.called(1)
			assert.stub(spyUnregisterEvent).was.called_with(CurrencyModule, "CURRENCY_DISPLAY_UPDATE")
		end)

		it("OnDisable does not unregister events for expansions lower than SL", function()
			functionMocks.GetExpansionLevel.returns(ns.Expansion.BFA)
			local spyUnregisterEvent = spy.on(CurrencyModule, "UnregisterEvent")

			CurrencyModule:OnDisable()

			assert.stub(spyUnregisterEvent).was.not_called()
		end)
	end)

	it("does not show loot if the currency type is nil", function()
		ns.db.global.currency.enabled = true

		CurrencyModule:CURRENCY_DISPLAY_UPDATE("CURRENCY_DISPLAY_UPDATE", nil)

		assert.stub(nsMocks.SendMessage).was.not_called()
	end)

	it("does not show loot if the quantityChange is nil", function()
		ns.db.global.currency.enabled = true

		CurrencyModule:CURRENCY_DISPLAY_UPDATE("CURRENCY_DISPLAY_UPDATE", 123, nil, nil)

		assert.stub(nsMocks.SendMessage).was.not_called()
	end)

	it("does not show loot if the quantityChange is lte 0", function()
		ns.db.global.currency.enabled = true

		CurrencyModule:CURRENCY_DISPLAY_UPDATE("CURRENCY_DISPLAY_UPDATE", 123, nil, -1)

		assert.stub(nsMocks.SendMessage).was.not_called()
	end)

	it("does not show loot if the currency info cannot be found", function()
		ns.db.global.currency.enabled = true
		currencyInfoMocks.GetCurrencyInfo:revert()
		currencyInfoMocks.GetCurrencyInfo = stub(_G.C_CurrencyInfo, "GetCurrencyInfo").returns(nil)

		CurrencyModule:CURRENCY_DISPLAY_UPDATE("CURRENCY_DISPLAY_UPDATE", 123, 1, 1)

		assert.stub(nsMocks.SendMessage).was.not_called()
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

		CurrencyModule:CURRENCY_DISPLAY_UPDATE("CURRENCY_DISPLAY_UPDATE", 123, 5, 2)

		assert.stub(nsMocks.SendMessage).was.not_called()
		currencyInfoMocks.GetCurrencyInfo:revert()
	end)

	it("does not show hidden currencies", function()
		ns.db.global.currency.enabled = true
		ns.hiddenCurrencies = { [123] = true }
		currencyInfoMocks.GetCurrencyInfo:revert()
		currencyInfoMocks.GetCurrencyInfo = stub(_G.C_CurrencyInfo, "GetCurrencyInfo").returns({
			currencyID = 123,
			description = "An awesome currency",
			iconFileID = 123456,
			quantity = 5,
			quality = 2,
		})

		CurrencyModule:CURRENCY_DISPLAY_UPDATE("CURRENCY_DISPLAY_UPDATE", 123, 5, 2)

		assert.stub(nsMocks.SendMessage).was.not_called()
	end)

	it("does not show if the currency link cannot be retrieved", function()
		ns.db.global.currency.enabled = true
		currencyInfoMocks.GetCurrencyLink:revert()
		currencyInfoMocks.GetCurrencyLink = stub(_G.C_CurrencyInfo, "GetCurrencyLink").returns(nil)

		CurrencyModule:CURRENCY_DISPLAY_UPDATE("CURRENCY_DISPLAY_UPDATE", 123, 5, 2)

		assert.stub(nsMocks.SendMessage).was.not_called()
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

		CurrencyModule:CURRENCY_DISPLAY_UPDATE("CURRENCY_DISPLAY_UPDATE", 123, 5, 2)

		assert.spy(newElement).was.called_with(_, "|c12345678|Hcurrency:123|r", info, basicInfo)
		assert.stub(nsMocks.SendMessage).was.called(1)
		currencyInfoMocks.GetBasicCurrencyInfo:revert()
		currencyInfoMocks.GetCurrencyLink:revert()
		currencyInfoMocks.GetCurrencyInfo:revert()
	end)

	it("shows traders tender currency", function()
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

		CurrencyModule:PERKS_PROGRAM_CURRENCY_AWARDED("PERKS_PROGRAM_CURRENCY_AWARDED", 5)

		assert.spy(newElement).was.called_with(_, "|c12345678|Hcurrency:123|r", info, basicInfo)
		assert.stub(nsMocks.SendMessage).was.called(1)
		currencyInfoMocks.GetBasicCurrencyInfo:revert()
		currencyInfoMocks.GetCurrencyLink:revert()
		currencyInfoMocks.GetCurrencyInfo:revert()
	end)
end)
