local common_stubs = require("spec.common_stubs")

describe("ItemInfo", function()
  local ns, ItemInfo

  before_each(function()
    ns = common_stubs.setup_G_RLF(spy)
    common_stubs.stub_C_Item()

    assert(loadfile("utils/ItemInfo.lua"))("TestAddon", ns)
    ItemInfo = ns.ItemInfo
  end)

  it("creates a new ItemInfo instance", function()
    local item = ItemInfo:new(18803, "Test Item", "itemLink", 2, 10, 1, "Weapon", "Sword", 1, "INVTYPE_WEAPON", "texture", 100, 2, 1, 1, 1, 1, false)
    assert.are.equal(item.itemId, 18803)
    assert.are.equal(item.itemName, "Test Item")
  end)

  it("returns nil if itemName is not provided", function()
    local item = ItemInfo:new(18803, nil, "itemLink", 2, 10, 1, "Weapon", "Sword", 1, "INVTYPE_WEAPON", "texture", 100, 2, 1, 1, 1, 1, false)
    assert.is_nil(item)
  end)

  it("retrieves the item ID if not provided", function()
    local item = ItemInfo:new(nil, "Test Item", "itemLink", 2, 10, 1, "Weapon", "Sword", 1, "INVTYPE_WEAPON", "texture", 100, 2, 1, 1, 1, 1, false)
    assert.are.equal(item.itemId, 18803)
  end)

  it("checks if an item is a mount", function()
    local item = ItemInfo:new(18803, "Test Mount", "itemLink", 2, 10, 1, "Miscellaneous", "Mount", 1, "INVTYPE_WEAPON", "texture", 100, 15, 5, 1, 1, 1, false)
    assert.is_true(item:IsMount())
  end)

  it("checks if an item is not a mount", function()
    local item = ItemInfo:new(18803, "Test Item", "itemLink", 2, 10, 1, "Weapon", "Sword", 1, "INVTYPE_WEAPON", "texture", 100, 2, 1, 1, 1, 1, false)
    assert.is_false(item:IsMount())
  end)

  it("checks if an item is legendary", function()
    local item = ItemInfo:new(18803, "Test Legendary", "itemLink", 5, 10, 1, "Weapon", "Sword", 1, "INVTYPE_WEAPON", "texture", 100, 2, 1, 1, 1, 1, false)
    assert.is_true(item:IsLegendary())
  end)

  it("checks if an item is not legendary", function()
    local item = ItemInfo:new(18803, "Test Item", "itemLink", 2, 10, 1, "Weapon", "Sword", 1, "INVTYPE_WEAPON", "texture", 100, 2, 1, 1, 1, 1, false)
    assert.is_false(item:IsLegendary())
  end)

  describe("IsEligibleEquipment", function()
    it("checks if an item is eligible equipment", function()
      _G.UnitClass = function() return nil, "Warrior" end
      ns.armorClassMapping = { Warrior = 4 }
      ns.equipSlotMap = { INVTYPE_CHEST = 5 }
    
      local item = ItemInfo:new(18803, "Test Armor", "itemLink", 2, 10, 1, "Armor", "Plate", 1, "INVTYPE_CHEST", "texture", 100, Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Plate, 1, 1, 1, false)
      assert.is_true(item:IsEligibleEquipment())
    end)
    
    it("checks if an item is not eligible equipment due to classID", function()
      local item = ItemInfo:new(18803, "Test Weapon", "itemLink", 2, 10, 1, "Weapon", "Sword", 1, "INVTYPE_WEAPON", "texture", 100, 2, 1, 1, 1, 1, false)
      assert.is_false(item:IsEligibleEquipment())
    end)
    
    it("checks if an item is not eligible equipment due to missing itemEquipLoc", function()
      local item = ItemInfo:new(18803, "Test Armor", "itemLink", 2, 10, 1, "Armor", "Plate", 1, nil, "texture", 100, 4, 4, 1, 1, 1, false)
      assert.is_false(item:IsEligibleEquipment())
    end)
    
    it("checks if an item is not eligible equipment due to mismatched armor class", function()
      _G.UnitClass = function() return nil, "Mage" end
      ns.armorClassMapping = { Mage = 1 }
    
      local item = ItemInfo:new(18803, "Test Armor", "itemLink", 2, 10, 1, "Armor", "Plate", 1, "INVTYPE_CHEST", "texture", 100, 4, 4, 1, 1, 1, false)
      assert.is_false(item:IsEligibleEquipment())
    end)
    
    it("checks if an item is not eligible equipment due to missing equip slot", function()
      _G.UnitClass = function() return nil, "Warrior" end
      ns.armorClassMapping = { Warrior = 4 }
      ns.equipSlotMap = {}
    
      local item = ItemInfo:new(18803, "Test Armor", "itemLink", 2, 10, 1, "Armor", "Plate", 1, "INVTYPE_CHEST", "texture", 100, 4, 4, 1, 1, 1, false)
      assert.is_false(item:IsEligibleEquipment())
    end)
  end)
end)
