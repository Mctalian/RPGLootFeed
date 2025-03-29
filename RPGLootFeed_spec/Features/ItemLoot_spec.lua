local common_stubs = require("RPGLootFeed_spec/common_stubs")
local assert = require("luassert")
local busted = require("busted")
local setup = busted.setup
local before_each = busted.before_each
local describe = busted.describe
local it = busted.it

describe("ItemLoot module", function()
	local _ = match._
	local LootModule, ns, showSpy

	setup(function()
		require("RPGLootFeed_spec._mocks.WoWGlobals.Functions")
		require("RPGLootFeed_spec._mocks.Libs.LibStub")
	end)

	before_each(function()
		-- Define the global G_RLF
		common_stubs.stub_C_Item()
		showSpy = spy.new(function() end)
		ns = common_stubs.setup_G_RLF()
		ns.InitializeLootDisplayProperties = function(element)
			---@diagnostic disable-next-line: duplicate-set-field
			element.Show = function(...)
				showSpy(...)
			end
		end
		-- Load the list module before each test
		LootModule = assert(loadfile("RPGLootFeed/Features/ItemLoot/ItemLoot.lua"))("TestAddon", ns)
		LootModule:OnInitialize()
		ns.LogInfo:clear()
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
		local guid = UnitGUID("player")

		LootModule:CHAT_MSG_LOOT("CHAT_MSG_LOOT", msg, playerName, nil, nil, nil, nil, nil, nil, nil, nil, nil, guid)
		assert.spy(showSpy).was.called(1)
	end)

	it("should handle GET_ITEM_INFO_RECEIVED event", function()
		local itemID = 18803
		local success = true
		local itemLink = "|cffa335ee|Hitem:18803::::::::60:::::|h[Finkle's Lava Dredger]|h|r"
		local amount = 1

		LootModule.pendingItemRequests[itemID] = { itemLink, amount }
		LootModule:GET_ITEM_INFO_RECEIVED("GET_ITEM_INFO_RECEIVED", itemID, success)
		assert.is_nil(LootModule.pendingItemRequests[itemID])
		assert.spy(showSpy).was.called(1)
	end)
end)
