local common_stubs = require("spec/common_stubs")

describe("Currency module", function()
	local _ = match._
	local CurrencyModule

	before_each(function()
		common_stubs.setup_G_RLF(spy)
		common_stubs.stub_C_CurrencyInfo()

		-- Load the list module before each test
		CurrencyModule = require("Features/Currency")
	end)

	it("does not show loot if the currency type is nil", function()
		_G.G_RLF.db.global.currencyFeed = true

		CurrencyModule:CURRENCY_DISPLAY_UPDATE(_, nil)

		assert.stub(_G.G_RLF.LootDisplay.ShowLoot).was.not_called()
	end)

	it("does not show loot if the quantityChange is nil", function()
		_G.G_RLF.db.global.currencyFeed = true

		CurrencyModule:CURRENCY_DISPLAY_UPDATE(_, 123, nil, nil)

		assert.stub(_G.G_RLF.LootDisplay.ShowLoot).was.not_called()
	end)

	it("does not show loot if the quantityChange is lte 0", function()
		_G.G_RLF.db.global.currencyFeed = true

		CurrencyModule:CURRENCY_DISPLAY_UPDATE(_, 123, nil, -1)

		assert.stub(_G.G_RLF.LootDisplay.ShowLoot).was.not_called()
	end)

	it("does not show loot if the currency info cannot be found", function()
		_G.G_RLF.db.global.currencyFeed = true
		_G.C_CurrencyInfo.GetCurrencyInfo = function()
			return nil
		end

		CurrencyModule:CURRENCY_DISPLAY_UPDATE(_, 123, 1, 1)

		assert.stub(_G.G_RLF.LootDisplay.ShowLoot).was.not_called()
	end)

	it("does not show loot if the currency has an empty description", function()
		_G.G_RLF.db.global.currencyFeed = true
		_G.C_CurrencyInfo.GetCurrencyInfo = function()
			return {
				currencyID = 123,
				description = "",
				iconFileID = 123456,
			}
		end

		CurrencyModule:CURRENCY_DISPLAY_UPDATE(_, 123, 5, 2)

		assert.stub(_G.G_RLF.LootDisplay.ShowLoot).was.not_called()
	end)

	it("shows loot if the currency info is valid", function()
		_G.G_RLF.db.global.currencyFeed = true
		_G.C_CurrencyInfo.GetCurrencyInfo = function()
			return {
				currencyID = 123,
				description = "An awesome currency",
				iconFileID = 123456,
			}
		end

		CurrencyModule:CURRENCY_DISPLAY_UPDATE(_, 123, 5, 2)

		assert.stub(_G.G_RLF.LootDisplay.ShowLoot).was.called()
		assert
			.stub(_G.G_RLF.LootDisplay.ShowLoot).was
			.called_with(_, "Currency", 123, "|c12345678|Hcurrency:123|r", 123456, 2)
	end)
end)
