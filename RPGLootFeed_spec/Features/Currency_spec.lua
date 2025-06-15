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

	it("does not show loot if the quantityChange is equal to 0", function()
		ns.db.global.currency.enabled = true

		CurrencyModule:CURRENCY_DISPLAY_UPDATE("CURRENCY_DISPLAY_UPDATE", 123, nil, 0)

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

		assert.spy(newElement).was.called_with(CurrencyModule.Element, "|c12345678|Hcurrency:123|r", info, basicInfo)
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

		assert.spy(newElement).was.called_with(CurrencyModule.Element, "|c12345678|Hcurrency:123|r", info, basicInfo)
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
			nsMocks.ExtractCurrencyID.invokes(function(_, currencyLink)
				-- Use actual implementation
				local currencyID = currencyLink:match("|Hcurrency:(%d+):")
				return currencyID and tonumber(currencyID) or nil
			end)
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
			it("returns currency link and quantity from CURRENCY_GAINED pattern", function()
				local quantityChange = CurrencyModule:ParseCurrencyChangeMessage(
					"You receive currency: |cffffffff|Hcurrency:241:0|h[Champion's Seal]|h|r."
				)

				assert.equal(1, quantityChange) -- Default when no quantity specified
			end)

			it("returns currency link and quantity from CURRENCY_GAINED_MULTIPLE pattern", function()
				local quantityChange = CurrencyModule:ParseCurrencyChangeMessage(
					"You receive currency: |cffffffff|Hcurrency:241:0|h[Champion's Seal]|h|r x5."
				)

				assert.equal(5, quantityChange)
			end)

			it("returns currency link and quantity from CURRENCY_GAINED_MULTIPLE_BONUS pattern", function()
				local quantityChange = CurrencyModule:ParseCurrencyChangeMessage(
					"You receive currency: |cffffffff|Hcurrency:241:0|h[Champion's Seal]|h|r x5 (Bonus Objective)."
				)

				assert.equal(5, quantityChange)
			end)
		end)

		describe("CHAT_MSG_CURRENCY", function()
			local currencyLink = "|cffffffff|Hcurrency:241:0|h[Champion's Seal]|h|r"
			local currencyInfo, basicInfo
			before_each(function()
				currencyInfoMocks = require("RPGLootFeed_spec._mocks.WoWGlobals.namespaces.C_CurrencyInfo")
				functionMocks.GetCurrencyLink.returns(currencyLink)
				basicInfo = {
					displayAmount = 1,
				}
				currencyInfoMocks.GetBasicCurrencyInfo =
					stub(_G.C_CurrencyInfo, "GetBasicCurrencyInfo").returns(basicInfo)
				currencyInfo = {
					currencyID = 241,
					quantity = 0, -- Zero quantity from link
					iconFileID = 133784,
					quality = 1,
				}
				currencyInfoMocks.GetCurrencyInfo = stub(_G.C_CurrencyInfo, "GetCurrencyInfo").returns(currencyInfo)
			end)
			it("does not show currency if the currency link cannot be parsed from the message", function()
				CurrencyModule:CHAT_MSG_CURRENCY("CHAT_MSG_CURRENCY", "Some random message")

				assert.spy(nsMocks.SendMessage).was.not_called()
			end)

			it("does not show currency if the currency ID cannot be extracted when currencyID is 0", function()
				nsMocks.ExtractCurrencyID.returns(0)

				local success = CurrencyModule:CHAT_MSG_CURRENCY(
					"CHAT_MSG_CURRENCY",
					"You receive currency: " .. currencyLink .. "."
				)

				assert.spy(nsMocks.SendMessage).was.not_called()
			end)

			it("does not show currency if it is a hidden currency", function()
				ns.hiddenCurrencies = { [241] = true }

				local success = CurrencyModule:CHAT_MSG_CURRENCY(
					"CHAT_MSG_CURRENCY",
					"You receive currency: " .. currencyLink .. "."
				)

				assert.spy(nsMocks.SendMessage).was.not_called()
			end)

			it("shows currency when parsing succeeds", function()
				local newElement = spy.on(CurrencyModule.Element, "new")

				CurrencyModule:CHAT_MSG_CURRENCY("CHAT_MSG_CURRENCY", "You receive currency: " .. currencyLink .. ".")

				assert.spy(newElement).was.called_with(CurrencyModule.Element, currencyLink, currencyInfo, basicInfo)
				assert.spy(nsMocks.SendMessage).was.called(1)
			end)

			it("handles currency with zero quantity by setting it to quantityChange", function()
				local newElement = spy.on(CurrencyModule.Element, "new")

				CurrencyModule:CHAT_MSG_CURRENCY(
					"CHAT_MSG_CURRENCY",
					"You receive currency: " .. currencyLink .. " x3."
				)

				-- Currency info should have quantity updated to 3
				local expectedCurrencyInfo = {
					currencyID = 241,
					quantity = 3, -- Updated from quantityChange
					iconFileID = 133784,
					quality = 1,
				}
				local expectedBasicInfo = {
					displayAmount = 3,
				}
				assert
					.spy(newElement).was
					.called_with(CurrencyModule.Element, currencyLink, expectedCurrencyInfo, expectedBasicInfo)
				assert.spy(nsMocks.SendMessage).was.called(1)
			end)

			it("handles currency with zero currencyID by extracting it from the link", function()
				local currencyLink = "|cffffffff|Hcurrency:241:0|h[Champion's Seal]|h|r"
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

				-- Currency info should have currencyID updated to 241
				local expectedCurrencyInfo = {
					currencyID = 241, -- Updated from ExtractCurrencyID
					quantity = 1,
					iconFileID = 133784,
					quality = 1,
				}
				assert
					.spy(newElement).was
					.called_with(CurrencyModule.Element, currencyLink, expectedCurrencyInfo, basicInfo)
				assert.spy(nsMocks.SendMessage).was.called(1)
				currencyInfoMocks.GetBasicCurrencyInfo:revert()
				currencyInfoMocks.GetCurrencyInfoFromLink:revert()
			end)

			it("creates fallback basicInfo when GetBasicCurrencyInfo returns nil", function()
				local currencyLink = "|cffffffff|Hcurrency:241:0|h[Champion's Seal]|h|r"
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

				-- Should create fallback basicInfo with displayAmount = quantityChange
				local expectedBasicInfo = {
					displayAmount = 1,
				}
				assert
					.spy(newElement).was
					.called_with(CurrencyModule.Element, currencyLink, currencyInfo, expectedBasicInfo)
				assert.spy(nsMocks.SendMessage).was.called(1)
				currencyInfoMocks.GetBasicCurrencyInfo:revert()
				currencyInfoMocks.GetCurrencyInfoFromLink:revert()
			end)

			it("does not show currency if Element creation returns nil", function()
				local currencyLink = "|cffffffff|Hcurrency:241:0|h[Champion's Seal]|h|r"
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

				assert.spy(nsMocks.SendMessage).was.not_called()
				elementNewStub:revert()
				currencyInfoMocks.GetBasicCurrencyInfo:revert()
				currencyInfoMocks.GetCurrencyInfoFromLink:revert()
			end)
		end)

		describe("ruRU localization", function()
			before_each(function()
				_G.CURRENCY_GAINED = "Вы получаете валюту – %s."
				_G.CURRENCY_GAINED_MULTIPLE = "Вы получаете валюту – %s, %d шт."
				_G.CURRENCY_GAINED_MULTIPLE_BONUS =
					"Вы получаете валюту – %s, %d шт. (дополнительные задачи)"
				CurrencyModule:OnInitialize()
				nsMocks.SendMessage:clear()
				nsMocks.LogDebug:clear()
			end)

			describe("ParseCurrencyChangeMessage", function()
				it("returns nil if no currency link is found in the Russian message", function()
					local quantityChange = CurrencyModule:ParseCurrencyChangeMessage(
						"Какое-то случайное сообщение"
					)
					assert.equal(1, quantityChange)
				end)

				it("returns currency link and quantity from Russian CURRENCY_GAINED pattern", function()
					local quantityChange = CurrencyModule:ParseCurrencyChangeMessage(
						"Вы получаете валюту – |cffffffff|Hcurrency:241:0|h[Печать чемпиона]|h|r."
					)

					assert.equal(1, quantityChange) -- Default when no quantity specified
				end)

				it("returns currency link and quantity from Russian CURRENCY_GAINED_MULTIPLE pattern", function()
					local quantityChange = CurrencyModule:ParseCurrencyChangeMessage(
						"Вы получаете валюту – |cffffffff|Hcurrency:241:0|h[Печать чемпиона]|h|r, 5 шт."
					)

					assert.equal(5, quantityChange)
				end)

				it("returns currency link and quantity from Russian CURRENCY_GAINED_MULTIPLE_BONUS pattern", function()
					local quantityChange = CurrencyModule:ParseCurrencyChangeMessage(
						"Вы получаете валюту – |cffffffff|Hcurrency:241:0|h[Печать чемпиона]|h|r, 5 шт. (дополнительные задачи)"
					)

					assert.equal(5, quantityChange)
				end)
			end)

			describe("CHAT_MSG_CURRENCY", function()
				local currencyLink = "|cffffffff|Hcurrency:241:0|h[Печать чемпиона]|h|r"
				local currencyInfo, basicInfo
				before_each(function()
					currencyInfoMocks = require("RPGLootFeed_spec._mocks.WoWGlobals.namespaces.C_CurrencyInfo")
					functionMocks.GetCurrencyLink.returns(currencyLink)
					basicInfo = {
						displayAmount = 1,
					}
					currencyInfoMocks.GetBasicCurrencyInfo =
						stub(_G.C_CurrencyInfo, "GetBasicCurrencyInfo").returns(basicInfo)
					currencyInfo = {
						currencyID = 241,
						quantity = 0, -- Zero quantity from link
						iconFileID = 133784,
						quality = 1,
					}
					currencyInfoMocks.GetCurrencyInfo = stub(_G.C_CurrencyInfo, "GetCurrencyInfo").returns(currencyInfo)
				end)

				it("does not show currency if the Russian currency link cannot be parsed from the message", function()
					local success = CurrencyModule:CHAT_MSG_CURRENCY(
						"CHAT_MSG_CURRENCY",
						"Какое-то случайное сообщение"
					)

					assert.spy(nsMocks.SendMessage).was.not_called()
				end)

				it("shows currency when parsing Russian message succeeds", function()
					local newElement = spy.on(CurrencyModule.Element, "new")

					CurrencyModule:CHAT_MSG_CURRENCY(
						"CHAT_MSG_CURRENCY",
						"Вы получаете валюту – " .. currencyLink .. "."
					)

					assert
						.spy(newElement).was
						.called_with(CurrencyModule.Element, currencyLink, currencyInfo, basicInfo)
					assert.spy(nsMocks.SendMessage).was.called(1)
				end)

				it("handles Russian currency with multiple quantity", function()
					local newElement = spy.on(CurrencyModule.Element, "new")

					CurrencyModule:CHAT_MSG_CURRENCY(
						"CHAT_MSG_CURRENCY",
						"Вы получаете валюту – " .. currencyLink .. ", 3 шт."
					)

					-- Currency info should have quantity updated to 3
					local expectedCurrencyInfo = {
						currencyID = 241,
						quantity = 3, -- Updated from quantityChange
						iconFileID = 133784,
						quality = 1,
					}

					local expectedBasicInfo = {
						displayAmount = 3,
					}
					assert
						.spy(newElement).was
						.called_with(CurrencyModule.Element, currencyLink, expectedCurrencyInfo, expectedBasicInfo)
					assert.spy(nsMocks.SendMessage).was.called(1)
				end)

				it("handles Russian currency with bonus objective", function()
					local newElement = spy.on(CurrencyModule.Element, "new")

					CurrencyModule:CHAT_MSG_CURRENCY(
						"CHAT_MSG_CURRENCY",
						"Вы получаете валюту – "
							.. currencyLink
							.. ", 5 шт. (дополнительные задачи)"
					)

					local expectedBasicInfo = {
						displayAmount = 5,
					}

					assert
						.spy(newElement).was
						.called_with(CurrencyModule.Element, currencyLink, currencyInfo, expectedBasicInfo)
					assert.spy(nsMocks.SendMessage).was.called(1)
				end)

				it("correctly handles quantity mismatch between parsed amount and basicInfo.displayAmount", function()
					-- This test reproduces the issue seen in Russian logs where:
					-- - The chat message shows "83 шт." (83 pieces)
					-- - But basicInfo.displayAmount is 0
					-- - The parsed quantityChange should be used for display
					local currencyLink = "|cffffffff|Hcurrency:395:0|h[Очки справедливости]|h|r"
					local currencyInfo = {
						currencyID = 395,
						quantity = 2540, -- Current total
						iconFileID = 133784,
						quality = 1,
						name = "Очки справедливости",
					}
					local basicInfo = {
						displayAmount = 0, -- This is the problem - should be 83 but API returns 0
					}

					-- Mock the Russian currency message parsing
					nsMocks.ExtractCurrencyID.returns(395)
					currencyInfoMocks.GetCurrencyInfo:revert()
					currencyInfoMocks.GetBasicCurrencyInfo:revert()
					currencyInfoMocks.GetCurrencyInfo = stub(_G.C_CurrencyInfo, "GetCurrencyInfo").returns(currencyInfo)
					currencyInfoMocks.GetBasicCurrencyInfo =
						stub(_G.C_CurrencyInfo, "GetBasicCurrencyInfo").returns(basicInfo)
					functionMocks.GetCurrencyLink.returns(currencyLink)

					-- Mock ParseCurrencyChangeMessage to return the correct parsed amount
					local parseStub = stub(CurrencyModule, "ParseCurrencyChangeMessage")
					parseStub.returns(83) -- This is what should be parsed from "83 шт."

					local newElement = spy.on(CurrencyModule.Element, "new")

					CurrencyModule:CHAT_MSG_CURRENCY(
						"CHAT_MSG_CURRENCY",
						"Вы получаете валюту – [Очки справедливости], 83 шт."
					)

					-- The basicInfo should be overridden because displayAmount is 0
					local expectedBasicInfo = {
						displayAmount = 83, -- Should use the parsed quantity change
					}

					assert
						.spy(newElement).was
						.called_with(CurrencyModule.Element, currencyLink, currencyInfo, expectedBasicInfo)
					assert.spy(nsMocks.SendMessage).was.called(1)

					parseStub:revert()
					currencyInfoMocks.GetBasicCurrencyInfo:revert()
					currencyInfoMocks.GetCurrencyInfo:revert()
				end)

				it("preserves basicInfo structure when overriding displayAmount to 0", function()
					-- Test that when basicInfo exists but displayAmount is 0, we preserve other fields
					local currencyLink = "|cffffffff|Hcurrency:396:0|h[Очки доблести]|h|r"
					local currencyInfo = {
						currencyID = 396,
						quantity = 1410,
						iconFileID = 133785,
						quality = 1,
						name = "Очки доблести",
					}
					local basicInfo = {
						displayAmount = 0, -- Problem: should be 240 but API returns 0
						name = "Очки доблести",
						icon = 133785,
						quality = 1,
						actualAmount = 240,
					}

					nsMocks.ExtractCurrencyID.returns(396)
					currencyInfoMocks.GetCurrencyInfo:revert()
					currencyInfoMocks.GetBasicCurrencyInfo:revert()
					currencyInfoMocks.GetCurrencyInfo = stub(_G.C_CurrencyInfo, "GetCurrencyInfo").returns(currencyInfo)
					currencyInfoMocks.GetBasicCurrencyInfo =
						stub(_G.C_CurrencyInfo, "GetBasicCurrencyInfo").returns(basicInfo)
					functionMocks.GetCurrencyLink.returns(currencyLink)

					local parseStub = stub(CurrencyModule, "ParseCurrencyChangeMessage")
					parseStub.returns(240) -- Parsed from "240 шт."

					local newElement = spy.on(CurrencyModule.Element, "new")

					CurrencyModule:CHAT_MSG_CURRENCY(
						"CHAT_MSG_CURRENCY",
						"Вы получаете валюту – [Очки доблести], 240 шт."
					)

					-- The basicInfo should be replaced with just displayAmount when displayAmount is 0
					-- This current behavior might not be ideal - we're losing other basicInfo fields
					local expectedBasicInfo = {
						displayAmount = 240,
					}

					assert
						.spy(newElement).was
						.called_with(CurrencyModule.Element, currencyLink, currencyInfo, expectedBasicInfo)
					assert.spy(nsMocks.SendMessage).was.called(1)

					parseStub:revert()
					currencyInfoMocks.GetBasicCurrencyInfo:revert()
					currencyInfoMocks.GetCurrencyInfo:revert()
				end)
			end)
		end)
	end)
end)
