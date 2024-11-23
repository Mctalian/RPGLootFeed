local common_stubs = require("spec/common_stubs")

describe("ItemLoot module", function()
	local _ = match._
	local LootModule, ns, showSpy

	before_each(function()
		-- Define the global G_RLF
		common_stubs.stub_C_Item()
		showSpy = spy.new()
		ns = ns or common_stubs.setup_G_RLF(spy)
		ns.InitializeLootDisplayProperties = function(element)
			element.Show = function(...)
				showSpy(...)
			end
		end
		-- Load the list module before each test
		LootModule = assert(loadfile("Features/ItemLoot.lua"))("TestAddon", ns)
		LootModule:OnInitialize()
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
		assert.spy(LootModule.RegisterEvent).was.called_with(_, "GROUP_ROSTER_UPDATE")

		LootModule:OnDisable()
		assert.spy(LootModule.UnregisterEvent).was.called_with(_, "CHAT_MSG_LOOT")
		assert.spy(LootModule.UnregisterEvent).was.called_with(_, "GET_ITEM_INFO_RECEIVED")
		assert.spy(LootModule.UnregisterEvent).was.called_with(_, "GROUP_ROSTER_UPDATE")
	end)

	it("should handle CHAT_MSG_LOOT event", function()
		local msg = "You received |cffa335ee|Hitem:18803::::::::60:::::|h[Finkle's Lava Dredger]|h|r"
		local playerName = "Player"
		local guid = UnitGUID("player")

		LootModule:CHAT_MSG_LOOT("CHAT_MSG_LOOT", msg, playerName, nil, nil, nil, nil, nil, nil, nil, nil, nil, guid)
		assert.spy(showSpy).was.called()
	end)

	it("should handle GET_ITEM_INFO_RECEIVED event", function()
		local itemID = 18803
		local success = true
		local itemLink = "|cffa335ee|Hitem:18803::::::::60:::::|h[Finkle's Lava Dredger]|h|r"
		local amount = 1

		LootModule.pendingItemRequests[itemID] = { itemLink, amount }
		LootModule:GET_ITEM_INFO_RECEIVED("GET_ITEM_INFO_RECEIVED", itemID, success)
		assert.is_nil(LootModule.pendingItemRequests[itemID])
		assert.spy(showSpy).was.called()
	end)

	it("should handle GROUP_ROSTER_UPDATE event", function()
		LootModule:GROUP_ROSTER_UPDATE("GROUP_ROSTER_UPDATE")
		assert.spy(ns.LogInfo).was.called()
	end)

	it("should show party loot", function()
		local msg = "PartyMember received |cffa335ee|Hitem:18803::::::::60:::::|h[Finkle's Lava Dredger]|h|r"
		local itemLink = "|cffa335ee|Hitem:18803::::::::60:::::|h[Finkle's Lava Dredger]|h|r"
		local playerName = "PartyMember"
		local amount = 1
		local itemId = 18803
		ns.db.global.enablePartyLoot = true
		LootModule.nameUnitMap = { PartyMember = "party1" }

		LootModule:CHAT_MSG_LOOT(
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
		assert.spy(showSpy).was.called()
	end)

	it("handles GET_ITEM_INFO_RECEIVED event for party loot", function()
		local itemID = 18803
		local success = true
		local itemLink = "|cffa335ee|Hitem:18803::::::::60:::::|h[Finkle's Lava Dredger]|h|r"
		local amount = 1
		local unit = "Party1"

		LootModule.pendingPartyRequests[itemID] = { itemLink, amount, unit }
		LootModule:GET_ITEM_INFO_RECEIVED("GET_ITEM_INFO_RECEIVED", itemID, success)
		assert.is_nil(LootModule.pendingPartyRequests[itemID])
		assert.spy(showSpy).was.called()
	end)
end)
