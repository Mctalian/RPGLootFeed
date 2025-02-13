local common_stubs = require("spec/common_stubs")

describe("Money module", function()
	local _ = match._
	local MoneyModule, ns

	before_each(function()
		ns = ns or common_stubs.setup_G_RLF(spy)
		common_stubs.stub_Money_Funcs()
		-- Load the list module before each test
		MoneyModule = assert(loadfile("Features/Money.lua"))("TestAddon", ns)
	end)

	it("Money:OnInitialize enables or disables the module based on global moneyFeed", function()
		ns.db.global.money.enabled = true
		spy.on(MoneyModule, "Enable")
		MoneyModule:OnInitialize()
		assert.spy(MoneyModule.Enable).was.called()

		ns.db.global.money.enabled = false
		spy.on(MoneyModule, "Disable")
		MoneyModule:OnInitialize()
		assert.spy(MoneyModule.Disable).was.called()
	end)

	it("Money:OnEnable registers events and sets startingMoney", function()
		stub(MoneyModule, "RegisterEvent")
		stub(_G, "GetMoney").returns(1000)

		MoneyModule:OnEnable()

		assert.stub(MoneyModule.RegisterEvent).was_called_with(_, "PLAYER_MONEY")
		assert.stub(MoneyModule.RegisterEvent).was_called_with(_, "PLAYER_ENTERING_WORLD")
		assert.equals(MoneyModule.startingMoney, 1000)

		MoneyModule.RegisterEvent:revert()
		_G.GetMoney:revert()
	end)

	it("Money:OnDisable unregisters events", function()
		stub(MoneyModule, "UnregisterEvent")

		MoneyModule:OnDisable()

		assert.stub(MoneyModule.UnregisterEvent).was_called_with(_, "PLAYER_MONEY")
		assert.stub(MoneyModule.UnregisterEvent).was_called_with(_, "PLAYER_ENTERING_WORLD")

		MoneyModule.UnregisterEvent:revert()
	end)

	it("Money:PLAYER_ENTERING_WORLD sets startingMoney", function()
		stub(_G, "GetMoney").returns(2000)

		MoneyModule:PLAYER_ENTERING_WORLD("PLAYER_ENTERING_WORLD")

		assert.equals(MoneyModule.startingMoney, 2000)

		_G.GetMoney:revert()
	end)

	it("Money:PLAYER_MONEY updates startingMoney and creates a new element", function()
		stub(_G, "GetMoney").returns(3000)
		stub(MoneyModule.Element, "new").returns({ Show = function() end })

		MoneyModule.startingMoney = 1000
		MoneyModule:PLAYER_MONEY("PLAYER_MONEY")

		assert.equals(MoneyModule.startingMoney, 3000)
		assert.stub(MoneyModule.Element.new).was_called_with(MoneyModule.Element, 2000)

		MoneyModule.Element.new:revert()
		_G.GetMoney:revert()
	end)
end)
