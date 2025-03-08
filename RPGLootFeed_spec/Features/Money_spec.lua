local common_stubs = require("RPGLootFeed_spec/common_stubs")

describe("Money module", function()
	local _ = match._
	local MoneyModule, ns

	before_each(function()
		ns = ns or common_stubs.setup_G_RLF(spy)
		common_stubs.stub_Money_Funcs()
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
		---@diagnostic disable-next-line: undefined-field
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
		---@diagnostic disable-next-line: undefined-field
		local stubGetMoney = stub(_G, "GetMoney").returns(2000)

		MoneyModule:PLAYER_ENTERING_WORLD("PLAYER_ENTERING_WORLD")

		assert.equal(MoneyModule.startingMoney, 2000)

		stubGetMoney:revert()
	end)

	it("Money:PLAYER_MONEY updates startingMoney and creates a new element", function()
		local fakeElement = { Show = function() end, PlaySoundIfEnabled = function() end }
		---@diagnostic disable-next-line: undefined-field
		local stubGetMoney = stub(_G, "GetMoney").returns(3000)
		---@diagnostic disable-next-line: undefined-field
		local stubElementNew = stub(MoneyModule.Element, "new").returns(fakeElement)
		local showSpy = spy.on(fakeElement, "Show")
		local playSoundSpy = spy.on(fakeElement, "PlaySoundIfEnabled")

		MoneyModule.startingMoney = 1000
		MoneyModule:PLAYER_MONEY("PLAYER_MONEY")

		assert.equal(MoneyModule.startingMoney, 3000)
		assert.stub(MoneyModule.Element.new).was.called_with(MoneyModule.Element, 2000)
		assert.spy(showSpy).was.called(1)
		assert.spy(playSoundSpy).was.called(1)

		stubElementNew:revert()
		stubGetMoney:revert()
	end)
end)
