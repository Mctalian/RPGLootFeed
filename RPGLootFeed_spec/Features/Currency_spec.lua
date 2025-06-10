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
		assert(loadfile("RPGLootFeed/Features/_Internals/LootDisplayProperties.lua"))("TestAddon", ns)

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
			functionMocks.GetExpansionLevel.returns(ns.Expansion.WOTLK)
			CurrencyModule:OnInitialize()

			assert.spy(spyEnable).was.called(1)
			assert.spy(spyDisable).was.not_called()
		end)

		it("OnInitialize does not set up the module if the feature is disabled", function()
			ns.db.global.currency.enabled = false
			local spyEnable = spy.on(CurrencyModule, "Enable")
			local spyDisable = spy.on(CurrencyModule, "Disable")
			functionMocks.GetExpansionLevel.returns(ns.Expansion.WOTLK)
			CurrencyModule:OnInitialize()

			assert.spy(spyEnable).was.not_called()
			assert.spy(spyDisable).was.called(1)
		end)

		it("OnInitialize does not set up the module if the expansion level is lower than WOTLK", function()
			ns.db.global.currency.enabled = true
			local spyEnable = spy.on(CurrencyModule, "Enable")
			local spyDisable = spy.on(CurrencyModule, "Disable")
			functionMocks.GetExpansionLevel.returns(ns.Expansion.TBC)
			CurrencyModule:OnInitialize()

			assert.spy(spyEnable).was.not_called()
			assert.spy(spyDisable).was.called(1)
		end)

		it("OnEnable registers events correctly for Retail expansions gte BFA", function()
			functionMocks.GetExpansionLevel.returns(ns.Expansion.BFA)
			nsMocks.IsRetail.returns(true)
			local spyRegisterEvent = spy.on(CurrencyModule, "RegisterEvent")

			CurrencyModule:OnEnable()

			assert.stub(spyRegisterEvent).was.called(2)
			assert.stub(spyRegisterEvent).was.called_with(CurrencyModule, "CURRENCY_DISPLAY_UPDATE")
			assert.stub(spyRegisterEvent).was.called_with(CurrencyModule, "PERKS_PROGRAM_CURRENCY_AWARDED")
		end)

		it("OnEnable registers events correctly for Classic expansions gte WOTLK", function()
			functionMocks.GetExpansionLevel.returns(ns.Expansion.WOTLK)
			nsMocks.IsRetail.returns(false)
			local spyRegisterEvent = spy.on(CurrencyModule, "RegisterEvent")

			CurrencyModule:OnEnable()

			assert.stub(spyRegisterEvent).was.called(1)
			assert.stub(spyRegisterEvent).was.called_with(CurrencyModule, "CHAT_MSG_CURRENCY")
		end)

		it("OnEnable does not register events for expansions lower than WOTLK", function()
			functionMocks.GetExpansionLevel.returns(ns.Expansion.TBC)
			local spyRegisterEvent = spy.on(CurrencyModule, "RegisterEvent")

			CurrencyModule:OnEnable()

			assert.stub(spyRegisterEvent).was.not_called()
		end)

		it("OnDisable unregisters events correctly for Retail expansions gte BFA", function()
			functionMocks.GetExpansionLevel.returns(ns.Expansion.BFA)
			nsMocks.IsRetail.returns(true)
			local spyUnregisterEvent = spy.on(CurrencyModule, "UnregisterEvent")

			CurrencyModule:OnDisable()

			assert.stub(spyUnregisterEvent).was.called(3)
			assert.stub(spyUnregisterEvent).was.called_with(CurrencyModule, "CURRENCY_DISPLAY_UPDATE")
			assert.stub(spyUnregisterEvent).was.called_with(CurrencyModule, "PERKS_PROGRAM_CURRENCY_AWARDED")
			assert.stub(spyUnregisterEvent).was.called_with(CurrencyModule, "PERKS_PROGRAM_CURRENCY_REFRESH")
		end)

		it("OnDisable unregisters events correctly for Classic expansions gte WOTLK", function()
			functionMocks.GetExpansionLevel.returns(ns.Expansion.WOTLK)
			nsMocks.IsRetail.returns(false)
			local spyUnregisterEvent = spy.on(CurrencyModule, "UnregisterEvent")

			CurrencyModule:OnDisable()

			assert.stub(spyUnregisterEvent).was.called(1)
			assert.stub(spyUnregisterEvent).was.called_with(CurrencyModule, "CHAT_MSG_CURRENCY")
		end)

		it("OnDisable does not unregister events for expansions lower than WOTLK", function()
			functionMocks.GetExpansionLevel.returns(ns.Expansion.TBC)
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
		CurrencyModule:PERKS_PROGRAM_CURRENCY_REFRESH("PERKS_PROGRAM_CURRENCY_REFRESH", 10, 15)

		assert.spy(newElement).was.called_with(_, "|c12345678|Hcurrency:123|r", info, basicInfo)
		assert.stub(nsMocks.SendMessage).was.called(1)
		currencyInfoMocks.GetBasicCurrencyInfo:revert()
		currencyInfoMocks.GetCurrencyLink:revert()
		currencyInfoMocks.GetCurrencyInfo:revert()
	end)

	describe("Classic chat message parsing", function()
		before_each(function()
			require("RPGLootFeed_spec._mocks.WoWGlobals")
			-- Set up for Classic expansions to trigger the chat message parsing code path
			functionMocks.GetExpansionLevel.returns(ns.Expansion.WOTLK)
			local i = 1
			nsMocks.CreatePatternSegmentsForStringNumber.invokes(function()
				if i == 1 then
					i = i + 1
					return {
						"You receive currency: ",
						".",
					}
				elseif i == 2 then
					i = i + 1
					return {
						"You receive currency: ",
						" x",
						".",
					}
				elseif i == 3 then
					i = i + 1
					return {
						"You receive currency: ",
						" x",
						". (Bonus Objective)",
					}
				else
					return {}
				end
			end)
			CurrencyModule:OnInitialize()
			nsMocks.SendMessage:clear()
			nsMocks.LogDebug:clear()
		end)

		describe("ParseCurrencyChangeMessage", function()
			it("returns nil if no currency link is found in the message", function()
				nsMocks.ExtractDynamicsFromPattern.returns(nil, nil)

				local currencyLink, quantityChange = CurrencyModule:ParseCurrencyChangeMessage("Some random message")

				assert.is_nil(currencyLink)
				assert.is_nil(quantityChange)
			end)

			it("returns currency link and quantity from CURRENCY_GAINED pattern", function()
				local expectedLink = "|cffffffff|Hcurrency:241|h[Champion's Seal]|h|r"
				nsMocks.ExtractDynamicsFromPattern.returns(expectedLink, nil)

				local currencyLink, quantityChange = CurrencyModule:ParseCurrencyChangeMessage(
					"You receive currency: |cffffffff|Hcurrency:241|h[Champion's Seal]|h|r."
				)

				assert.equal(expectedLink, currencyLink)
				assert.equal(1, quantityChange) -- Default when no quantity specified
			end)

			it("returns currency link and quantity from CURRENCY_GAINED_MULTIPLE pattern", function()
				local expectedLink = "|cffffffff|Hcurrency:241|h[Champion's Seal]|h|r"
				nsMocks.ExtractDynamicsFromPattern.returns(expectedLink, 5)

				local currencyLink, quantityChange = CurrencyModule:ParseCurrencyChangeMessage(
					"You receive currency: |cffffffff|Hcurrency:241|h[Champion's Seal]|h|r x5."
				)

				assert.equal(expectedLink, currencyLink)
				assert.equal(5, quantityChange)
			end)

			it("returns currency link and quantity from CURRENCY_GAINED_MULTIPLE_BONUS pattern", function()
				local expectedLink = "|cffffffff|Hcurrency:241|h[Champion's Seal]|h|r"
				nsMocks.ExtractDynamicsFromPattern.returns(expectedLink, 7)

				local currencyLink, quantityChange = CurrencyModule:ParseCurrencyChangeMessage(
					"You receive currency: |cffffffff|Hcurrency:241|h[Champion's Seal]|h|r x5 (+2 bonus)."
				)

				assert.equal(expectedLink, currencyLink)
				assert.equal(7, quantityChange)
			end)
		end)

		describe("CHAT_MSG_CURRENCY", function()
			it("does not show currency if the currency link cannot be parsed from the message", function()
				nsMocks.ExtractDynamicsFromPattern.returns(nil, nil)

				local success = CurrencyModule:CHAT_MSG_CURRENCY("CHAT_MSG_CURRENCY", "Some random message")

				assert.is_true(success)
				assert.spy(nsMocks.SendMessage).was.not_called()
			end)

			it("does not show currency if the currency info cannot be retrieved from the link", function()
				local currencyLink = "|cffffffff|Hcurrency:241|h[Champion's Seal]|h|r"
				nsMocks.ExtractDynamicsFromPattern.returns(currencyLink, 1)
				currencyInfoMocks.GetCurrencyInfoFromLink:revert()
				currencyInfoMocks.GetCurrencyInfoFromLink =
					stub(_G.C_CurrencyInfo, "GetCurrencyInfoFromLink").returns(nil)

				local success = CurrencyModule:CHAT_MSG_CURRENCY(
					"CHAT_MSG_CURRENCY",
					"You receive currency: " .. currencyLink .. "."
				)

				assert.is_true(success)
				assert.spy(nsMocks.SendMessage).was.not_called()
				currencyInfoMocks.GetCurrencyInfoFromLink:revert()
			end)

			it("does not show currency if the currency ID cannot be extracted when currencyID is 0", function()
				local currencyLink = "|cffffffff|Hcurrency:241|h[Champion's Seal]|h|r"
				nsMocks.ExtractDynamicsFromPattern.returns(currencyLink, 1)
				currencyInfoMocks.GetCurrencyInfoFromLink:revert()
				currencyInfoMocks.GetCurrencyInfoFromLink = stub(_G.C_CurrencyInfo, "GetCurrencyInfoFromLink").returns({
					currencyID = 0,
					quantity = 0,
				})
				nsMocks.ExtractCurrencyID.returns(0)

				local success = CurrencyModule:CHAT_MSG_CURRENCY(
					"CHAT_MSG_CURRENCY",
					"You receive currency: " .. currencyLink .. "."
				)

				assert.is_true(success)
				assert.spy(nsMocks.SendMessage).was.not_called()
				currencyInfoMocks.GetCurrencyInfoFromLink:revert()
			end)

			it("does not show currency if it is a hidden currency", function()
				local currencyLink = "|cffffffff|Hcurrency:241|h[Champion's Seal]|h|r"
				nsMocks.ExtractDynamicsFromPattern.returns(currencyLink, 1)
				ns.hiddenCurrencies = { [241] = true }
				currencyInfoMocks.GetCurrencyInfoFromLink:revert()
				currencyInfoMocks.GetBasicCurrencyInfo:revert()
				currencyInfoMocks.GetCurrencyInfoFromLink = stub(_G.C_CurrencyInfo, "GetCurrencyInfoFromLink").returns({
					currencyID = 241,
					quantity = 1,
				})
				currencyInfoMocks.GetBasicCurrencyInfo = stub(_G.C_CurrencyInfo, "GetBasicCurrencyInfo").returns({
					displayAmount = 1,
				})

				local success = CurrencyModule:CHAT_MSG_CURRENCY(
					"CHAT_MSG_CURRENCY",
					"You receive currency: " .. currencyLink .. "."
				)

				assert.is_true(success)
				assert.spy(nsMocks.SendMessage).was.not_called()
				currencyInfoMocks.GetBasicCurrencyInfo:revert()
				currencyInfoMocks.GetCurrencyInfoFromLink:revert()
			end)

			it("shows currency when parsing succeeds", function()
				local currencyLink = "|cffffffff|Hcurrency:241|h[Champion's Seal]|h|r"
				local currencyInfo = {
					currencyID = 241,
					quantity = 1,
					iconFileID = 133784,
					quality = 1,
				}
				local basicInfo = {
					displayAmount = 1,
				}

				nsMocks.ExtractDynamicsFromPattern.returns(currencyLink, 1)
				currencyInfoMocks.GetCurrencyInfoFromLink:revert()
				currencyInfoMocks.GetBasicCurrencyInfo:revert()
				currencyInfoMocks.GetCurrencyInfoFromLink =
					stub(_G.C_CurrencyInfo, "GetCurrencyInfoFromLink").returns(currencyInfo)
				currencyInfoMocks.GetBasicCurrencyInfo =
					stub(_G.C_CurrencyInfo, "GetBasicCurrencyInfo").returns(basicInfo)

				local newElement = spy.on(CurrencyModule.Element, "new")

				local success = CurrencyModule:CHAT_MSG_CURRENCY(
					"CHAT_MSG_CURRENCY",
					"You receive currency: " .. currencyLink .. "."
				)

				assert.is_true(success)
				assert.spy(newElement).was.called_with(_, currencyLink, currencyInfo, basicInfo)
				assert.spy(nsMocks.SendMessage).was.called(1)
				currencyInfoMocks.GetBasicCurrencyInfo:revert()
				currencyInfoMocks.GetCurrencyInfoFromLink:revert()
			end)

			it("handles currency with zero quantity by setting it to quantityChange", function()
				local currencyLink = "|cffffffff|Hcurrency:241|h[Champion's Seal]|h|r"
				local currencyInfo = {
					currencyID = 241,
					quantity = 0, -- Zero quantity from link
					iconFileID = 133784,
					quality = 1,
				}
				local basicInfo = {
					displayAmount = 3,
				}

				nsMocks.ExtractDynamicsFromPattern.returns(currencyLink, 3)
				currencyInfoMocks.GetCurrencyInfoFromLink:revert()
				currencyInfoMocks.GetBasicCurrencyInfo:revert()
				currencyInfoMocks.GetCurrencyInfoFromLink =
					stub(_G.C_CurrencyInfo, "GetCurrencyInfoFromLink").returns(currencyInfo)
				currencyInfoMocks.GetBasicCurrencyInfo =
					stub(_G.C_CurrencyInfo, "GetBasicCurrencyInfo").returns(basicInfo)

				local newElement = spy.on(CurrencyModule.Element, "new")

				local success = CurrencyModule:CHAT_MSG_CURRENCY(
					"CHAT_MSG_CURRENCY",
					"You receive currency: " .. currencyLink .. " x3."
				)

				assert.is_true(success)
				-- Currency info should have quantity updated to 3
				local expectedCurrencyInfo = {
					currencyID = 241,
					quantity = 3, -- Updated from quantityChange
					iconFileID = 133784,
					quality = 1,
				}
				assert.spy(newElement).was.called_with(_, currencyLink, expectedCurrencyInfo, basicInfo)
				assert.spy(nsMocks.SendMessage).was.called(1)
				currencyInfoMocks.GetBasicCurrencyInfo:revert()
				currencyInfoMocks.GetCurrencyInfoFromLink:revert()
			end)

			it("handles currency with zero currencyID by extracting it from the link", function()
				local currencyLink = "|cffffffff|Hcurrency:241|h[Champion's Seal]|h|r"
				local currencyInfo = {
					currencyID = 0, -- Zero currency ID from link
					quantity = 1,
					iconFileID = 133784,
					quality = 1,
				}
				local basicInfo = {
					displayAmount = 1,
				}

				nsMocks.ExtractDynamicsFromPattern.returns(currencyLink, 1)
				nsMocks.ExtractCurrencyID.returns(241)
				currencyInfoMocks.GetCurrencyInfoFromLink:revert()
				currencyInfoMocks.GetBasicCurrencyInfo:revert()
				currencyInfoMocks.GetCurrencyInfoFromLink =
					stub(_G.C_CurrencyInfo, "GetCurrencyInfoFromLink").returns(currencyInfo)
				currencyInfoMocks.GetBasicCurrencyInfo =
					stub(_G.C_CurrencyInfo, "GetBasicCurrencyInfo").returns(basicInfo)

				local newElement = spy.on(CurrencyModule.Element, "new")

				local success = CurrencyModule:CHAT_MSG_CURRENCY(
					"CHAT_MSG_CURRENCY",
					"You receive currency: " .. currencyLink .. "."
				)

				assert.is_true(success)
				-- Currency info should have currencyID updated to 241
				local expectedCurrencyInfo = {
					currencyID = 241, -- Updated from ExtractCurrencyID
					quantity = 1,
					iconFileID = 133784,
					quality = 1,
				}
				assert.spy(newElement).was.called_with(_, currencyLink, expectedCurrencyInfo, basicInfo)
				assert.spy(nsMocks.SendMessage).was.called(1)
				currencyInfoMocks.GetBasicCurrencyInfo:revert()
				currencyInfoMocks.GetCurrencyInfoFromLink:revert()
			end)

			it("creates fallback basicInfo when GetBasicCurrencyInfo returns nil", function()
				local currencyLink = "|cffffffff|Hcurrency:241|h[Champion's Seal]|h|r"
				local currencyInfo = {
					currencyID = 241,
					quantity = 1,
					iconFileID = 133784,
					quality = 1,
				}

				nsMocks.ExtractDynamicsFromPattern.returns(currencyLink, 1)
				currencyInfoMocks.GetCurrencyInfoFromLink:revert()
				currencyInfoMocks.GetBasicCurrencyInfo:revert()
				currencyInfoMocks.GetCurrencyInfoFromLink =
					stub(_G.C_CurrencyInfo, "GetCurrencyInfoFromLink").returns(currencyInfo)
				currencyInfoMocks.GetBasicCurrencyInfo = stub(_G.C_CurrencyInfo, "GetBasicCurrencyInfo").returns(nil)

				local newElement = spy.on(CurrencyModule.Element, "new")

				local success = CurrencyModule:CHAT_MSG_CURRENCY(
					"CHAT_MSG_CURRENCY",
					"You receive currency: " .. currencyLink .. "."
				)

				assert.is_true(success)
				-- Should create fallback basicInfo with displayAmount = quantityChange
				local expectedBasicInfo = {
					displayAmount = 1,
				}
				assert.spy(newElement).was.called_with(_, currencyLink, currencyInfo, expectedBasicInfo)
				assert.spy(nsMocks.SendMessage).was.called(1)
				currencyInfoMocks.GetBasicCurrencyInfo:revert()
				currencyInfoMocks.GetCurrencyInfoFromLink:revert()
			end)

			it("does not show currency if Element creation returns nil", function()
				local currencyLink = "|cffffffff|Hcurrency:241|h[Champion's Seal]|h|r"
				local currencyInfo = {
					currencyID = 241,
					quantity = 1,
					iconFileID = 133784,
					quality = 1,
				}
				local basicInfo = {
					displayAmount = 1,
				}

				nsMocks.ExtractDynamicsFromPattern.returns(currencyLink, 1)
				currencyInfoMocks.GetCurrencyInfoFromLink:revert()
				currencyInfoMocks.GetBasicCurrencyInfo:revert()
				currencyInfoMocks.GetCurrencyInfoFromLink =
					stub(_G.C_CurrencyInfo, "GetCurrencyInfoFromLink").returns(currencyInfo)
				currencyInfoMocks.GetBasicCurrencyInfo =
					stub(_G.C_CurrencyInfo, "GetBasicCurrencyInfo").returns(basicInfo)

				-- Mock Element.new to return nil
				local elementNewStub = stub(CurrencyModule.Element, "new").returns(nil)

				local success = CurrencyModule:CHAT_MSG_CURRENCY(
					"CHAT_MSG_CURRENCY",
					"You receive currency: " .. currencyLink .. "."
				)

				assert.is_true(success)
				assert.spy(nsMocks.SendMessage).was.not_called()
				elementNewStub:revert()
				currencyInfoMocks.GetBasicCurrencyInfo:revert()
				currencyInfoMocks.GetCurrencyInfoFromLink:revert()
			end)
		end)

		describe("ruRU localization", function()
			before_each(function()
				local i = 1
				nsMocks.CreatePatternSegmentsForStringNumber.invokes(function()
					if i == 1 then
						i = i + 1
						return {
							"Вы получаете валюту – ",
							".",
						}
					elseif i == 2 then
						i = i + 1
						return {
							"Вы получаете валюту – ",
							", ",
							" шт.",
						}
					elseif i == 3 then
						i = i + 1
						return {
							"Вы получаете валюту – ",
							", ",
							" шт. (дополнительные задачи)",
						}
					else
						return {}
					end
				end)
				CurrencyModule:OnInitialize()
				nsMocks.SendMessage:clear()
				nsMocks.LogDebug:clear()
			end)

			describe("ParseCurrencyChangeMessage", function()
				it("returns nil if no currency link is found in the Russian message", function()
					nsMocks.ExtractDynamicsFromPattern.returns(nil, nil)

					local currencyLink, quantityChange = CurrencyModule:ParseCurrencyChangeMessage(
						"Какое-то случайное сообщение"
					)

					assert.is_nil(currencyLink)
					assert.is_nil(quantityChange)
				end)

				it("returns currency link and quantity from Russian CURRENCY_GAINED pattern", function()
					local expectedLink = "|cffffffff|Hcurrency:241|h[Печать чемпиона]|h|r"
					nsMocks.ExtractDynamicsFromPattern.returns(expectedLink, nil)

					local currencyLink, quantityChange = CurrencyModule:ParseCurrencyChangeMessage(
						"Вы получаете валюту – |cffffffff|Hcurrency:241|h[Печать чемпиона]|h|r."
					)

					assert.equal(currencyLink, expectedLink)
					assert.equal(quantityChange, 1) -- Default when no quantity specified
				end)

				it("returns currency link and quantity from Russian CURRENCY_GAINED_MULTIPLE pattern", function()
					local expectedLink = "|cffffffff|Hcurrency:241|h[Печать чемпиона]|h|r"
					nsMocks.ExtractDynamicsFromPattern.returns(expectedLink, 5)

					local currencyLink, quantityChange = CurrencyModule:ParseCurrencyChangeMessage(
						"Вы получаете валюту – |cffffffff|Hcurrency:241|h[Печать чемпиона]|h|r, 5 шт."
					)

					assert.equal(currencyLink, expectedLink)
					assert.equal(quantityChange, 5)
				end)

				it("returns currency link and quantity from Russian CURRENCY_GAINED_MULTIPLE_BONUS pattern", function()
					local expectedLink = "|cffffffff|Hcurrency:241|h[Печать чемпиона]|h|r"
					nsMocks.ExtractDynamicsFromPattern.returns(expectedLink, 7)

					local currencyLink, quantityChange = CurrencyModule:ParseCurrencyChangeMessage(
						"Вы получаете валюту – |cffffffff|Hcurrency:241|h[Печать чемпиона]|h|r, 5 шт. (дополнительные задачи)"
					)

					assert.equal(currencyLink, expectedLink)
					assert.equal(quantityChange, 7)
				end)
			end)

			describe("CHAT_MSG_CURRENCY", function()
				it("does not show currency if the Russian currency link cannot be parsed from the message", function()
					nsMocks.ExtractDynamicsFromPattern.returns(nil, nil)

					local success = CurrencyModule:CHAT_MSG_CURRENCY(
						"CHAT_MSG_CURRENCY",
						"Какое-то случайное сообщение"
					)

					assert.is_true(success)
					assert.spy(nsMocks.SendMessage).was.not_called()
				end)

				it("shows currency when parsing Russian message succeeds", function()
					local currencyLink = "|cffffffff|Hcurrency:241|h[Печать чемпиона]|h|r"
					local currencyInfo = {
						currencyID = 241,
						quantity = 1,
						iconFileID = 133784,
						quality = 1,
					}
					local basicInfo = {
						displayAmount = 1,
					}

					nsMocks.ExtractDynamicsFromPattern.returns(currencyLink, 1)
					currencyInfoMocks.GetCurrencyInfoFromLink:revert()
					currencyInfoMocks.GetBasicCurrencyInfo:revert()
					currencyInfoMocks.GetCurrencyInfoFromLink =
						stub(_G.C_CurrencyInfo, "GetCurrencyInfoFromLink").returns(currencyInfo)
					currencyInfoMocks.GetBasicCurrencyInfo =
						stub(_G.C_CurrencyInfo, "GetBasicCurrencyInfo").returns(basicInfo)

					local newElement = spy.on(CurrencyModule.Element, "new")

					local success = CurrencyModule:CHAT_MSG_CURRENCY(
						"CHAT_MSG_CURRENCY",
						"Вы получаете валюту – " .. currencyLink .. "."
					)

					assert.is_true(success)
					assert.spy(newElement).was.called_with(_, currencyLink, currencyInfo, basicInfo)
					assert.spy(nsMocks.SendMessage).was.called(1)
					currencyInfoMocks.GetBasicCurrencyInfo:revert()
					currencyInfoMocks.GetCurrencyInfoFromLink:revert()
				end)

				it("handles Russian currency with multiple quantity", function()
					local currencyLink = "|cffffffff|Hcurrency:241|h[Печать чемпиона]|h|r"
					local currencyInfo = {
						currencyID = 241,
						quantity = 0, -- Zero quantity from link
						iconFileID = 133784,
						quality = 1,
					}
					local basicInfo = {
						displayAmount = 3,
					}

					nsMocks.ExtractDynamicsFromPattern.returns(currencyLink, 3)
					currencyInfoMocks.GetCurrencyInfoFromLink:revert()
					currencyInfoMocks.GetBasicCurrencyInfo:revert()
					currencyInfoMocks.GetCurrencyInfoFromLink =
						stub(_G.C_CurrencyInfo, "GetCurrencyInfoFromLink").returns(currencyInfo)
					currencyInfoMocks.GetBasicCurrencyInfo =
						stub(_G.C_CurrencyInfo, "GetBasicCurrencyInfo").returns(basicInfo)

					local newElement = spy.on(CurrencyModule.Element, "new")

					local success = CurrencyModule:CHAT_MSG_CURRENCY(
						"CHAT_MSG_CURRENCY",
						"Вы получаете валюту – " .. currencyLink .. ", 3 шт."
					)

					assert.is_true(success)
					-- Currency info should have quantity updated to 3
					local expectedCurrencyInfo = {
						currencyID = 241,
						quantity = 3, -- Updated from quantityChange
						iconFileID = 133784,
						quality = 1,
					}
					assert.spy(newElement).was.called_with(_, currencyLink, expectedCurrencyInfo, basicInfo)
					assert.spy(nsMocks.SendMessage).was.called(1)
					currencyInfoMocks.GetBasicCurrencyInfo:revert()
					currencyInfoMocks.GetCurrencyInfoFromLink:revert()
				end)

				it("handles Russian currency with bonus objective", function()
					local currencyLink = "|cffffffff|Hcurrency:241|h[Печать чемпиона]|h|r"
					local currencyInfo = {
						currencyID = 241,
						quantity = 0, -- Zero quantity from link
						iconFileID = 133784,
						quality = 1,
					}
					local basicInfo = {
						displayAmount = 7,
					}

					nsMocks.ExtractDynamicsFromPattern.returns(currencyLink, 7) -- 5 + 2 bonus
					currencyInfoMocks.GetCurrencyInfoFromLink:revert()
					currencyInfoMocks.GetBasicCurrencyInfo:revert()
					currencyInfoMocks.GetCurrencyInfoFromLink =
						stub(_G.C_CurrencyInfo, "GetCurrencyInfoFromLink").returns(currencyInfo)
					currencyInfoMocks.GetBasicCurrencyInfo =
						stub(_G.C_CurrencyInfo, "GetBasicCurrencyInfo").returns(basicInfo)

					local newElement = spy.on(CurrencyModule.Element, "new")

					local success = CurrencyModule:CHAT_MSG_CURRENCY(
						"CHAT_MSG_CURRENCY",
						"Вы получаете валюту – "
							.. currencyLink
							.. ", 5 шт. (дополнительные задачи)"
					)

					assert.is_true(success)
					-- Currency info should have quantity updated to 7
					local expectedCurrencyInfo = {
						currencyID = 241,
						quantity = 7, -- Updated from quantityChange (5 + 2 bonus)
						iconFileID = 133784,
						quality = 1,
					}
					assert.spy(newElement).was.called_with(_, currencyLink, expectedCurrencyInfo, basicInfo)
					assert.spy(nsMocks.SendMessage).was.called(1)
					currencyInfoMocks.GetBasicCurrencyInfo:revert()
					currencyInfoMocks.GetCurrencyInfoFromLink:revert()
				end)
			end)
		end)
	end)
end)
