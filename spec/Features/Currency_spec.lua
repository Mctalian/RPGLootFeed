describe("Currency module", function()
  local mockLootDisplay
  local mockCurrencyInfo
  local _ = match._

  before_each(function()
      -- Define the global G_RLF
      _G.G_RLF = {
        db = {
          global = {}
        },
        LootDisplay = {
          ShowLoot = function() end
        }
      }

      _G.C_CurrencyInfo = {
        GetCurrencyInfo = function()
          print("Original")
        end,
        GetCurrencyLink = function()
            return "|c12345678|Hcurrency:123|r"
        end
      }

      mockLootDisplay = mock(_G.G_RLF.LootDisplay, true)
      mockCurrencyInfo = mock(_G.C_CurrencyInfo)

      -- Load the list module before each test
      dofile("Features/Currency.lua")
  end)

  it("does not run if the feature is disabled", function()
      _G.G_RLF.db.global.currencyFeed = false

      _G.G_RLF.Currency:OnUpdate(123, 1, 1)

      assert.stub(mockLootDisplay.ShowLoot).was.not_called()
  end)

  it("does not show loot if the currency type is nil", function()
      _G.G_RLF.db.global.currencyFeed = true

      _G.G_RLF.Currency:OnUpdate(nil)

      assert.stub(mockLootDisplay.ShowLoot).was.not_called()
  end)

  it("does not show loot if the quantityChange is nil", function()
    _G.G_RLF.db.global.currencyFeed = true

    _G.G_RLF.Currency:OnUpdate(123, nil, nil)

    assert.stub(mockLootDisplay.ShowLoot).was.not_called()
end)

  it("does not show loot if the quantityChange is lte 0", function()
      _G.G_RLF.db.global.currencyFeed = true

      _G.G_RLF.Currency:OnUpdate(123, nil, -1)

      assert.stub(mockLootDisplay.ShowLoot).was.not_called()
  end)

  it("does not show loot if the currency info cannot be found", function()
      _G.G_RLF.db.global.currencyFeed = true
      _G.C_CurrencyInfo.GetCurrencyInfo = function()
          print("nilled")
          return nil
      end

      _G.G_RLF.Currency:OnUpdate(123, 1, 1)

      assert.stub(mockLootDisplay.ShowLoot).was.not_called()
  end)

  it("shows loot if the currency info is valid", function()
      _G.G_RLF.db.global.currencyFeed = true
      mockCurrencyInfo.GetCurrencyInfo:revert()
      _G.C_CurrencyInfo.GetCurrencyInfo = function()
          print("Overridden")
          return {
            currencyID = 123,
            iconFileID = 123456
          }
        end

      _G.G_RLF.Currency:OnUpdate(123, 5, 2)

      assert.stub(mockLootDisplay.ShowLoot).was.called()
  end)
end)
