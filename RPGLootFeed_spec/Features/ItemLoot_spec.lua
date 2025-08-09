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

describe("ItemLoot module", function()
	local _ = match._
	local LootModule, ns
	local itemMocks

	before_each(function()
		require("RPGLootFeed_spec._mocks.WoWGlobals.Functions")
		itemMocks = require("RPGLootFeed_spec._mocks.WoWGlobals.namespaces.C_Item")
		require("RPGLootFeed_spec._mocks.Libs.LibStub")
		ns = nsMocks:unitLoadedAfter(nsMocks.LoadSections.All)
		-- Load the LootDisplayProperties module to populate `ns`
		assert(loadfile("RPGLootFeed/Features/_Internals/LootDisplayProperties.lua"))("TestAddon", ns)
		-- Ensure `ns` has been populated correctly by LootDisplayProperties
		assert.is_not_nil(ns.InitializeLootDisplayProperties)
		-- Load the list module before each test
		LootModule = assert(loadfile("RPGLootFeed/Features/ItemLoot/ItemLoot.lua"))("TestAddon", ns)
		LootModule:OnInitialize()
		nsMocks.LogInfo:clear()
	end)

	it("should initialize correctly", function()
		assert.is_function(LootModule.OnInitialize)
		assert.is_function(LootModule.OnEnable)
		assert.is_function(LootModule.OnDisable)
	end)

	it("should enable and disable correctly", function()
		spy.on(LootModule, "RegisterEvent")
		spy.on(LootModule, "UnregisterEvent")

		LootModule:OnEnable()
		assert.spy(LootModule.RegisterEvent).was.called_with(_, "CHAT_MSG_LOOT")
		assert.spy(LootModule.RegisterEvent).was.called_with(_, "GET_ITEM_INFO_RECEIVED")

		LootModule:OnDisable()
		assert.spy(LootModule.UnregisterEvent).was.called_with(_, "CHAT_MSG_LOOT")
		assert.spy(LootModule.UnregisterEvent).was.called_with(_, "GET_ITEM_INFO_RECEIVED")
	end)

	it("should handle CHAT_MSG_LOOT event", function()
		local msg = "You received |cffa335ee|Hitem:18803::::::::60:::::|h[Finkle's Lava Dredger]|h|r"
		local playerName = "Player"
		local spyIsMount = spy.new(function()
			return false
		end)
		local spyIsLegendary = spy.new(function()
			return false
		end)
		local spyIsEligibleEquipment = spy.new(function()
			return false
		end)
		local spyIsEquippableItem = spy.new(function()
			return false
		end)
		local spyIsQuestItem = spy.new(function()
			return false
		end)
		local spyIsAppearanceCollected = spy.new(function()
			return true
		end)
		local spyHasItemRollBonus = spy.new(function()
			return false
		end)
		local spyIsKeystone = spy.new(function()
			return false
		end)
		local guid = UnitGUID("player")
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
			IsEquippableItem = spyIsEquippableItem,
			IsQuestItem = spyIsQuestItem,
			IsAppearanceCollected = spyIsAppearanceCollected,
			IsKeystone = spyIsKeystone,
			HasItemRollBonus = spyHasItemRollBonus,
		})
		local elementMock = mock(LootModule.Element, false)
		local elementShowSpy
		local stubInitializeLootDisplayProperties = stub(ns, "InitializeLootDisplayProperties", function(e)
			elementShowSpy = spy.on(e, "Show")
		end)

		LootModule:CHAT_MSG_LOOT("CHAT_MSG_LOOT", msg, playerName, nil, nil, nil, nil, nil, nil, nil, nil, nil, guid)
		assert.spy(elementShowSpy).was.called(1)
		stubInitializeLootDisplayProperties:revert()
	end)

	it("should handle GET_ITEM_INFO_RECEIVED event", function()
		local itemID = 18803
		local success = true
		local itemLink = "|cffa335ee|Hitem:18803::::::::60:::::|h[Finkle's Lava Dredger]|h|r"
		local amount = 1
		local elementMock = mock(LootModule.Element, false)
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
		local spyIsEquippableItem = spy.new(function()
			return false
		end)
		local spyIsQuestItem = spy.new(function()
			return false
		end)
		local spyIsAppearanceCollected = spy.new(function()
			return true
		end)
		local spyHasItemRollBonus = spy.new(function()
			return false
		end)
		local spyIsKeystone = spy.new(function()
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
			IsEquippableItem = spyIsEquippableItem,
			IsQuestItem = spyIsQuestItem,
			IsAppearanceCollected = spyIsAppearanceCollected,
			IsKeystone = spyIsKeystone,
			HasItemRollBonus = spyHasItemRollBonus,
		})

		LootModule.pendingItemRequests[itemID] = { itemLink, amount }
		LootModule:GET_ITEM_INFO_RECEIVED("GET_ITEM_INFO_RECEIVED", itemID, success)
		assert.is_nil(LootModule.pendingItemRequests[itemID])
		assert.spy(elementShowSpy).was.called(1)
		stubInitializeLootDisplayProperties:revert()
	end)
end)
