
local busted = require("busted")
local match = require("luassert.match")

describe("TestMode", function()
  before_each(function()
    -- Set up the G_RLF mock if needed
    _G.G_RLF = {
      TestMode = nil,  -- Will be set by TestMode.lua
      Print = function(message) print(message) end,
      GetCurrencyLink = function(currencyID, name) return "link" end,
      LootDisplay = {
        ShowLoot = spy.new(function() end)
      }
    }

    -- Load the TestMode module
    dofile("TestMode.lua")
  end)

  describe("TestItems", function()
    it("should correctly populate TestItems with links", function()
      for _, item in ipairs(TestMode.TestItems) do
        assert.is_not_nil(item.id, "Item needs to have an ID")
        assert.is_not_nil(item.icon, "Item needs to have an icon")
        assert.is_not_nil(item.link, "Item needs to have a link")
      end
    end)
  end)

  describe("GenerateRandomLoot", function()
    it("should generate and display a random item when the RNG condition is met", function()
      -- Call the method
      TestMode:GenerateRandomLoot()

      -- Extract the call arguments
      assert.stub(_G.G_RLF.LootDisplay.ShowLoot).was_called_with(match._, match.is_number(), match.is_string(), match.is_number(), match.is_number())
    end)
  end)
end)
