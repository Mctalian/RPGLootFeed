local nsMocks = require("RPGLootFeed_spec._mocks.Internal.addonNamespace")
local assert = require("luassert")
local match = require("luassert.match")
local busted = require("busted")
local before_each = busted.before_each
local describe = busted.describe
local it = busted.it
local mock = busted.mock
local spy = busted.spy
local stub = busted.stub

describe("PartyLoot module", function()
	local _ = match._
	local PartyModule, ns
	local itemMocks, classColorMocks

	before_each(function()
		require("RPGLootFeed_spec._mocks.WoWGlobals.Functions")
		require("RPGLootFeed_spec._mocks.Libs.LibStub")
		itemMocks = require("RPGLootFeed_spec._mocks.WoWGlobals.namespaces.C_Item")
		classColorMocks = require("RPGLootFeed_spec._mocks.WoWGlobals.namespaces.C_ClassColor")
		ns = nsMocks:unitLoadedAfter(nsMocks.LoadSections.All)
		-- Load the LootDisplayProperties module to populate `ns`
		assert(loadfile("RPGLootFeed/Features/_Internals/LootDisplayProperties.lua"))("TestAddon", ns)
		-- Ensure `ns` has been populated correctly by LootDisplayProperties
		assert.is_not_nil(ns.InitializeLootDisplayProperties)
		-- Load the list module before each test
		PartyModule = assert(loadfile("RPGLootFeed/Features/PartyLoot/PartyLoot.lua"))("TestAddon", ns)
		PartyModule:OnInitialize()
		nsMocks.LogInfo:clear()
	end)

	it("should initialize correctly", function()
		assert.is_function(PartyModule.OnInitialize)
		assert.is_function(PartyModule.OnEnable)
		assert.is_function(PartyModule.OnDisable)
	end)

	it("should enable and disable correctly", function()
		spy.on(PartyModule, "RegisterEvent")
		spy.on(PartyModule, "UnregisterEvent")

		PartyModule:OnEnable()
		assert.spy(PartyModule.RegisterEvent).was.called_with(_, "CHAT_MSG_LOOT")
		assert.spy(PartyModule.RegisterEvent).was.called_with(_, "GET_ITEM_INFO_RECEIVED")
		assert.spy(PartyModule.RegisterEvent).was.called_with(_, "GROUP_ROSTER_UPDATE")

		PartyModule:OnDisable()
		assert.spy(PartyModule.UnregisterEvent).was.called_with(_, "CHAT_MSG_LOOT")
		assert.spy(PartyModule.UnregisterEvent).was.called_with(_, "GET_ITEM_INFO_RECEIVED")
		assert.spy(PartyModule.UnregisterEvent).was.called_with(_, "GROUP_ROSTER_UPDATE")
	end)

	it("should handle GROUP_ROSTER_UPDATE event", function()
		PartyModule:GROUP_ROSTER_UPDATE("GROUP_ROSTER_UPDATE")
		assert.spy(ns.LogInfo).was.called(1)
		assert.spy(ns.LogInfo).called_with(_, "GROUP_ROSTER_UPDATE", _, _, _, _)
	end)

	it("should show party loot", function()
		local msg = "PartyMember received |cffa335ee|Hitem:18803::::::::60:::::|h[Finkle's Lava Dredger]|h|r"
		local playerName = "PartyMember"
		ns.db.global.partyLoot.enabled = true
		PartyModule.nameUnitMap = { PartyMember = "party1" }
		local elementMock = mock(PartyModule.Element, false)
		local elementShowSpy
		local stubInitializeLootDisplayProperties = stub(ns, "InitializeLootDisplayProperties", function(e)
			elementShowSpy = spy.on(e, "Show")
		end)
		local spyIsMount = spy.new(function()
			return false
		end)
		local spyIsLegendary = spy.new(function()
			return false
		end)
		local spyIsEligibleEquipment = spy.new(function()
			return false
		end)
		nsMocks.ItemInfo.new.returns({
			itemId = 18803,
			itemName = "Finkle's Lava Dredger",
			itemQuality = 2,
			itemTexture = 123456,
			sellPrice = 10000,
			itemLink = "|cffa335ee|Hitem:18803::::::::60:::::|h[Finkle's Lava Dredger]|h|r",
			IsMount = spyIsMount,
			IsLegendary = spyIsLegendary,
			IsEligibleEquipment = spyIsEligibleEquipment,
			GetEquipmentTypeText = function()
				return "Weapon"
			end,
		})

		PartyModule:CHAT_MSG_LOOT(
			"CHAT_MSG_LOOT",
			msg,
			playerName,
			nil,
			nil,
			nil,
			nil,
			nil,
			nil,
			nil,
			nil,
			nil,
			"Party1"
		)
		assert.spy(elementShowSpy).was.called(1)
	end)

	it("handles GET_ITEM_INFO_RECEIVED event for party loot", function()
		local itemID = 18803
		local success = true
		local itemLink = "|cffa335ee|Hitem:18803::::::::60:::::|h[Finkle's Lava Dredger]|h|r"
		local amount = 1
		local unit = "Party1"
		local elementMock = mock(PartyModule.Element, false)
		local elementShowSpy
		local stubInitializeLootDisplayProperties = stub(ns, "InitializeLootDisplayProperties", function(e)
			elementShowSpy = spy.on(e, "Show")
		end)
		local spyIsMount = spy.new(function()
			return false
		end)
		local spyIsLegendary = spy.new(function()
			return false
		end)
		local spyIsEligibleEquipment = spy.new(function()
			return false
		end)
		nsMocks.ItemInfo.new.returns({
			itemId = 18803,
			itemName = "Finkle's Lava Dredger",
			itemQuality = 2,
			itemTexture = 123456,
			sellPrice = 10000,
			itemLink = "|cffa335ee|Hitem:18803::::::::60:::::|h[Finkle's Lava Dredger]|h|r",
			IsMount = spyIsMount,
			IsLegendary = spyIsLegendary,
			IsEligibleEquipment = spyIsEligibleEquipment,
			GetEquipmentTypeText = function()
				return "Weapon"
			end,
		})

		PartyModule.pendingPartyRequests[itemID] = { itemLink, amount, unit }
		PartyModule:GET_ITEM_INFO_RECEIVED("GET_ITEM_INFO_RECEIVED", itemID, success)
		assert.is_nil(PartyModule.pendingPartyRequests[itemID])
		assert.spy(elementShowSpy).was.called(1)
	end)
end)
