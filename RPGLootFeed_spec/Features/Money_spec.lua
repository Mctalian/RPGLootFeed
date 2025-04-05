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

describe("Money module", function()
	local _ = match._
	local MoneyModule, ns

	before_each(function()
		require("RPGLootFeed_spec._mocks.WoWGlobals.Functions")
		ns = nsMocks:unitLoadedAfter(nsMocks.LoadSections.All)
		-- Load the LootDisplayProperties module to populate `ns`
		assert(loadfile("RPGLootFeed/Features/_Internals/LootDisplayProperties.lua"))("TestAddon", ns)

		-- Ensure `ns` has been populated correctly by LootDisplayProperties
		assert.is_not_nil(ns.InitializeLootDisplayProperties)
		-- Load the list module before each test
		MoneyModule = assert(loadfile("RPGLootFeed/Features/Money.lua"))("TestAddon", ns)
	end)

	it("Money:OnInitialize enables or disables the module based on global moneyFeed", function()
		ns.db.global.money.enabled = true
		local spyEnable = spy.on(MoneyModule, "Enable")
		MoneyModule:OnInitialize()
		assert.spy(spyEnable).was.called(1)

		ns.db.global.money.enabled = false
		local spyDisable = spy.on(MoneyModule, "Disable")
		MoneyModule:OnInitialize()
		assert.spy(spyDisable).was.called(1)
	end)

	it("Money:OnEnable registers events and sets startingMoney", function()
		stub(MoneyModule, "RegisterEvent")
		local stubGetMoney = stub(_G, "GetMoney").returns(1000)

		MoneyModule:OnEnable()

		assert.stub(MoneyModule.RegisterEvent).was.called_with(_, "PLAYER_MONEY")
		assert.stub(MoneyModule.RegisterEvent).was.called_with(_, "PLAYER_ENTERING_WORLD")
		assert.equal(MoneyModule.startingMoney, 1000)

		MoneyModule.RegisterEvent:revert()
		stubGetMoney:revert()
	end)

	it("Money:OnDisable unregisters events", function()
		stub(MoneyModule, "UnregisterEvent")

		MoneyModule:OnDisable()

		assert.stub(MoneyModule.UnregisterEvent).was.called_with(_, "PLAYER_MONEY")
		assert.stub(MoneyModule.UnregisterEvent).was.called_with(_, "PLAYER_ENTERING_WORLD")

		MoneyModule.UnregisterEvent:revert()
	end)

	it("Money:PLAYER_ENTERING_WORLD sets startingMoney", function()
		local stubGetMoney = stub(_G, "GetMoney").returns(2000)

		MoneyModule:PLAYER_ENTERING_WORLD("PLAYER_ENTERING_WORLD")

		assert.equal(MoneyModule.startingMoney, 2000)

		stubGetMoney:revert()
	end)

	it("Money:PLAYER_MONEY updates startingMoney and creates a new element", function()
		local stubGetMoney = stub(_G, "GetMoney").returns(3000)
		local elementMock = mock(MoneyModule.Element, false)
		local elementShowSpy, elementPlaySoundSpy
		local stubInitializeLootDisplayProperties = stub(ns, "InitializeLootDisplayProperties", function(e)
			elementShowSpy = spy.on(e, "Show")
		end)

		MoneyModule.startingMoney = 1000
		MoneyModule:PLAYER_MONEY("PLAYER_MONEY")

		assert.equal(MoneyModule.startingMoney, 3000)
		assert.spy(elementMock.new).was.called_with(MoneyModule.Element, 2000)
		assert.spy(elementShowSpy).was.called(1)

		stubGetMoney:revert()
		stubInitializeLootDisplayProperties:revert()
	end)
end)
