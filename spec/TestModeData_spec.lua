
local busted = require("busted")
-- local assert = require("luaassert")

dofile("TestModeData.lua")

describe("G_RLF", function()
  describe("G_RLF.TestItems", function()
    it("should correctly populate TestItems with links", function()
      for _, item in ipairs(G_RLF.TestItems) do
        assert.is_not_nil(item.id, "Item needs to have an ID")
        assert.is_not_nil(item.icon, "Item needs to have an icon")
        assert.is_not_nil(item.link, "Item needs to have a link")
      end
    end)
  end)
end)
