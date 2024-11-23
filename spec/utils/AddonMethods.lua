local common_stubs = require("spec/common_stubs")

describe("AddonMethods", function()
  local ns
  before_each(function()
    -- Define the global G_RLF
    ns = ns or common_stubs.setup_G_RLF(spy)

    -- Load the module before each test
    assert(loadfile("utils/AddonMethods.lua"))("TestAddon", ns)
  end)
  describe("RGBAToHexFormat", function()
    it("converts RGBA01 to WoW's hex color format", function()
      local result = ns:RGBAToHexFormat(0.1, 0.2, 0.3, 0.4)
      assert.are.equal(result, "|c6619334C")
    end)
  end)
end)