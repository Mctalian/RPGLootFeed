local common_stubs = require("spec/common_stubs")

describe("Currency module", function()
	local _ = match._
	local CurrencyModule, ns

	before_each(function()
		ns = ns or common_stubs.setup_G_RLF(spy)
		common_stubs.stub_C_CurrencyInfo()

		-- Load the LootDisplayProperties module to populate `ns`
		assert(loadfile("Features/LootDisplayProperties.lua"))("TestAddon", ns)

		-- Ensure `ns` has been populated correctly by LootDisplayProperties
		assert.is_not_nil(ns.InitializeLootDisplayProperties)
		assert.is_not_nil(ns.LootDisplayProperties)

		-- Load the list module before each test
		CurrencyModule = assert(loadfile("Features/Currency.lua"))("TestAddon", ns)
	end)

	it("does not show loot if the currency type is nil", function()
		ns.db.global.currencyFeed = true

		CurrencyModule:CURRENCY_DISPLAY_UPDATE(_, nil)

		assert.stub(ns.SendMessage).was.not_called()
	end)

	it("does not show loot if the quantityChange is nil", function()
		ns.db.global.currencyFeed = true

		CurrencyModule:CURRENCY_DISPLAY_UPDATE(_, 123, nil, nil)

		assert.stub(ns.SendMessage).was.not_called()
	end)

	it("does not show loot if the quantityChange is lte 0", function()
		ns.db.global.currencyFeed = true

		CurrencyModule:CURRENCY_DISPLAY_UPDATE(_, 123, nil, -1)

		assert.stub(ns.SendMessage).was.not_called()
	end)

	it("does not show loot if the currency info cannot be found", function()
		ns.db.global.currencyFeed = true
		_G.C_CurrencyInfo.GetCurrencyInfo = function()
			return nil
		end

		CurrencyModule:CURRENCY_DISPLAY_UPDATE(_, 123, 1, 1)

		assert.stub(ns.SendMessage).was.not_called()
	end)

	it("does not show loot if the currency has an empty description", function()
		ns.db.global.currencyFeed = true
		_G.C_CurrencyInfo.GetCurrencyInfo = function()
			return {
				currencyID = 123,
				description = "",
				iconFileID = 123456,
			}
		end

		CurrencyModule:CURRENCY_DISPLAY_UPDATE(_, 123, 5, 2)

		assert.stub(ns.SendMessage).was.not_called()
	end)

	it("shows loot if the currency info is valid", function()
		ns.db.global.currencyFeed = true
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
		_G.C_CurrencyInfo.GetCurrencyInfo = function()
			return info
		end
		_G.GetCurrencyLink = function(currencyType)
			return link
		end
		_G.GetBasicCurrencyInfo = function(currencyType, quantity)
			return basicInfo
		end

		local newElement = spy.on(CurrencyModule.Element, "new")

		CurrencyModule:CURRENCY_DISPLAY_UPDATE(_, 123, 5, 2)

		assert.spy(newElement).was.called_with(_, "|c12345678|Hcurrency:123|r", info, basicInfo)
		assert.stub(ns.SendMessage).was.called()
	end)
end)
