local common_stubs = require("RPGLootFeed_spec/common_stubs")

describe("Currency module", function()
	local _ = match._
	local CurrencyModule, ns

	before_each(function()
		ns = ns or common_stubs.setup_G_RLF(spy)
		common_stubs.stub_C_CurrencyInfo()

		-- Load the LootDisplayProperties module to populate `ns`
		assert(loadfile("RPGLootFeed/Features/LootDisplayProperties.lua"))("TestAddon", ns)

		-- Ensure `ns` has been populated correctly by LootDisplayProperties
		assert.is_not_nil(ns.InitializeLootDisplayProperties)
		assert.is_not_nil(ns.LootDisplayProperties)

		-- Load the list module before each test
		CurrencyModule = assert(loadfile("RPGLootFeed/Features/Currency.lua"))("TestAddon", ns)
	end)

	it("does not show loot if the currency type is nil", function()
		ns.db.global.currency.enabled = true

		CurrencyModule:CURRENCY_DISPLAY_UPDATE(_, nil)

		assert.stub(ns.SendMessage).was.not_called()
	end)

	it("does not show loot if the quantityChange is nil", function()
		ns.db.global.currency.enabled = true

		CurrencyModule:CURRENCY_DISPLAY_UPDATE(_, 123, nil, nil)

		assert.stub(ns.SendMessage).was.not_called()
	end)

	it("does not show loot if the quantityChange is lte 0", function()
		ns.db.global.currency.enabled = true

		CurrencyModule:CURRENCY_DISPLAY_UPDATE(_, 123, nil, -1)

		assert.stub(ns.SendMessage).was.not_called()
	end)

	it("does not show loot if the currency info cannot be found", function()
		ns.db.global.currency.enabled = true
		---@diagnostic disable-next-line: undefined-field
		local stubGetCurrencyInfo = stub(_G.C_CurrencyInfo, "GetCurrencyInfo").returns(nil)

		CurrencyModule:CURRENCY_DISPLAY_UPDATE(_, 123, 1, 1)

		assert.stub(ns.SendMessage).was.not_called()
		stubGetCurrencyInfo:revert()
	end)

	it("does not show loot if the currency has an empty description", function()
		ns.db.global.currency.enabled = true
		---@diagnostic disable-next-line: undefined-field
		local stubGetCurrencyInfo = stub(_G.C_CurrencyInfo, "GetCurrencyInfo").returns({
			currencyID = 123,
			description = "",
			iconFileID = 123456,
		})

		CurrencyModule:CURRENCY_DISPLAY_UPDATE(_, 123, 5, 2)

		assert.stub(ns.SendMessage).was.not_called()
		stubGetCurrencyInfo:revert()
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
		---@diagnostic disable-next-line: undefined-field
		local stubGetCurrencyInfo = stub(_G.C_CurrencyInfo, "GetCurrencyInfo").returns(info)
		---@diagnostic disable-next-line: undefined-field
		local stubGetCurrencyLink = stub(_G, "GetCurrencyLink").returns(link)
		---@diagnostic disable-next-line: undefined-field
		local stubGetBasicCurrencyInfo = stub(_G, "GetBasicCurrencyInfo").returns(basicInfo)

		local newElement = spy.on(CurrencyModule.Element, "new")

		CurrencyModule:CURRENCY_DISPLAY_UPDATE(_, 123, 5, 2)

		assert.spy(newElement).was.called_with(_, "|c12345678|Hcurrency:123|r", info, basicInfo)
		assert.stub(ns.SendMessage).was.called(1)
		stubGetBasicCurrencyInfo:revert()
		stubGetCurrencyLink:revert()
		stubGetCurrencyInfo:revert()
	end)
end)
