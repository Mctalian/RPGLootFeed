local nsMocks = require("RPGLootFeed_spec._mocks.Internal.addonNamespace")
local assert = require("luassert")
local busted = require("busted")
local before_each = busted.before_each
local describe = busted.describe
local it = busted.it

describe("ItemInfo", function()
	---@type test_G_RLF, RLF_ItemInfo
	local ns, ItemInfo
	local itemMocks, functionMocks, transmogCollectionMocks

	before_each(function()
		functionMocks = require("RPGLootFeed_spec._mocks.WoWGlobals.Functions")
		require("RPGLootFeed_spec._mocks.WoWGlobals.Enum")
		itemMocks = require("RPGLootFeed_spec._mocks.WoWGlobals.namespaces.C_Item")
		transmogCollectionMocks = require("RPGLootFeed_spec._mocks.WoWGlobals.namespaces.C_TransmogCollection")
		ns = nsMocks:unitLoadedAfter(nsMocks.LoadSections.All)

		assert(loadfile("RPGLootFeed/utils/ItemInfo.lua"))("TestAddon", ns)
		---@type RLF_ItemInfo
		ItemInfo = ns.ItemInfo
	end)

	describe("new", function()
		it("creates a new ItemInfo instance", function()
			local item = ItemInfo:new(
				18803,
				"Test Item",
				"itemLink",
				2,
				10,
				1,
				"Weapon",
				"Sword",
				1,
				"INVTYPE_WEAPON",
				"texture",
				100,
				2,
				1,
				1,
				1,
				1,
				false
			)
			if not item then
				assert.is_not_nil(item)
				return
			end
			assert.are.equal(item.itemId, 18803)
			assert.are.equal(item.itemName, "Test Item")
		end)

		it("returns nil if itemName is not provided", function()
			local item = ItemInfo:new(
				18803,
				nil,
				"itemLink",
				2,
				10,
				1,
				"Weapon",
				"Sword",
				1,
				"INVTYPE_WEAPON",
				"texture",
				100,
				2,
				1,
				1,
				1,
				1,
				false
			)
			assert.is_nil(item)
		end)

		it("retrieves the item ID if not provided", function()
			local item = ItemInfo:new(
				nil,
				"Test Item",
				"itemLink",
				2,
				10,
				1,
				"Weapon",
				"Sword",
				1,
				"INVTYPE_WEAPON",
				"texture",
				100,
				2,
				1,
				1,
				1,
				1,
				false
			)
			if not item then
				assert.is_not_nil(item)
				return
			end
			assert.are.equal(item.itemId, 18803)
		end)
	end)

	describe("IsMount", function()
		it("checks if an item is a mount", function()
			local item = ItemInfo:new(
				18803,
				"Test Mount",
				"itemLink",
				2,
				10,
				1,
				"Miscellaneous",
				"Mount",
				1,
				"INVTYPE_WEAPON",
				"texture",
				100,
				15,
				5,
				1,
				1,
				1,
				false
			)
			if not item then
				assert.is_not_nil(item)
				return
			end
			assert.is_true(item:IsMount())
		end)

		it("checks if an item is not a mount", function()
			local item = ItemInfo:new(
				18803,
				"Test Item",
				"itemLink",
				2,
				10,
				1,
				"Weapon",
				"Sword",
				1,
				"INVTYPE_WEAPON",
				"texture",
				100,
				2,
				1,
				1,
				1,
				1,
				false
			)
			if not item then
				assert.is_not_nil(item)
				return
			end
			assert.is_false(item:IsMount())
		end)
	end)

	describe("IsQuestItem", function()
		it("checks if an item is a quest item", function()
			local item = ItemInfo:new(
				18803,
				"Test Quest Item",
				"itemLink",
				2,
				10,
				1,
				"Quest",
				"Item",
				1,
				"INVTYPE_QUEST",
				"texture",
				100,
				12,
				0,
				1,
				1,
				1,
				false
			)
			if not item then
				assert.is_not_nil(item)
				return
			end
			assert.is_true(item:IsQuestItem())
		end)

		it("checks if an item is not a quest item", function()
			local item = ItemInfo:new(
				18803,
				"Test Item",
				"itemLink",
				2,
				10,
				1,
				"Weapon",
				"Sword",
				1,
				"INVTYPE_WEAPON",
				"texture",
				100,
				2,
				1,
				1,
				1,
				1,
				false
			)
			if not item then
				assert.is_not_nil(item)
				return
			end
			assert.is_false(item:IsQuestItem())
		end)
	end)

	describe("IsAppearanceCollected", function()
		it("checks if the item appearance has been collected", function()
			transmogCollectionMocks.PlayerHasTransmogByItemInfo.returns(true)
			local item = ItemInfo:new(
				18803,
				"Test Appearance",
				"itemLink",
				2,
				10,
				1,
				"Armor",
				"Cloth",
				1,
				"INVTYPE_CLOAK",
				"texture",
				100,
				4,
				1,
				1,
				1,
				1,
				false
			)
			if not item then
				assert.is_not_nil(item)
				return
			end
			assert.is_true(item:IsAppearanceCollected())
		end)

		it("returns true if the appearance id is nil", function()
			transmogCollectionMocks.GetItemInfo.returns(nil, nil)
			local item = ItemInfo:new(
				18803,
				"Test Appearance",
				"itemLink",
				2,
				10,
				1,
				"Armor",
				"Cloth",
				1,
				"INVTYPE_CLOAK",
				"texture",
				100,
				4,
				1,
				1,
				1,
				1,
				false
			)
			if not item then
				assert.is_not_nil(item)
				return
			end
			assert.is_true(item:IsAppearanceCollected())

			transmogCollectionMocks.GetItemInfo.returns(18803, 1)
		end)

		it("handles classic", function()
			ns.armorClassMapping = { MAGE = 1 }
			functionMocks.GetExpansionLevel.returns(ns.Expansion.CATA)
			transmogCollectionMocks.PlayerHasTransmog.returns(false)
			functionMocks.UnitClass.returns("Mage", "MAGE", 1)
			local item = ItemInfo:new(
				18803, -- itemId
				"Test Appearance", -- itemName
				"itemLink", -- itemLink
				2, -- itemQuality
				10, -- itemLevel
				1, -- itemMinLevel
				"Armor", -- itemType
				"Cloth", -- itemSubType
				1, -- itemStackCount
				"INVTYPE_CLOAK", -- itemEquipLoc
				"texture", -- itemTexture
				100, -- sellPrice
				4, -- classID
				1, -- subclassID
				1, -- bindType
				1, -- expansionID
				1, -- setID
				false -- isCraftingReagent
			)
			if not item then
				assert.is_not_nil(item)
				return
			end
			local result = item:IsAppearanceCollected()
			functionMocks.UnitClass.returns("Warrior", "WARRIOR", 1)
			assert.is_false(result)
		end)

		it("checks if the item appearance has not been collected", function()
			transmogCollectionMocks.PlayerHasTransmogByItemInfo.returns(false)
			local item = ItemInfo:new(
				18803,
				"Test Appearance",
				"itemLink",
				2,
				10,
				1,
				"Armor",
				"Cloth",
				1,
				"INVTYPE_CLOAK",
				"texture",
				100,
				4,
				1,
				1,
				1,
				1,
				false
			)
			if not item then
				assert.is_not_nil(item)
				return
			end
			assert.is_false(item:IsAppearanceCollected())
		end)
	end)

	describe("IsLegendary", function()
		it("checks if an item is legendary", function()
			local item = ItemInfo:new(
				18803,
				"Test Legendary",
				"itemLink",
				5,
				10,
				1,
				"Weapon",
				"Sword",
				1,
				"INVTYPE_WEAPON",
				"texture",
				100,
				2,
				1,
				1,
				1,
				1,
				false
			)
			if not item then
				assert.is_not_nil(item)
				return
			end
			assert.is_true(item:IsLegendary())
		end)

		it("checks if an item is not legendary", function()
			local item = ItemInfo:new(
				18803,
				"Test Item",
				"itemLink",
				2,
				10,
				1,
				"Weapon",
				"Sword",
				1,
				"INVTYPE_WEAPON",
				"texture",
				100,
				2,
				1,
				1,
				1,
				1,
				false
			)
			if not item then
				assert.is_not_nil(item)
				return
			end
			assert.is_false(item:IsLegendary())
		end)
	end)

	describe("IsEligibleEquipment", function()
		it("checks if an item is eligible equipment", function()
			ns.armorClassMapping = { WARRIOR = 4 }
			ns.equipSlotMap = { INVTYPE_CHEST = 5 }

			local item = ItemInfo:new(
				18803,
				"Test Armor",
				"itemLink",
				2,
				10,
				1,
				"Armor",
				"Plate",
				1,
				"INVTYPE_CHEST",
				"texture",
				100,
				Enum.ItemClass.Armor,
				Enum.ItemArmorSubclass.Plate,
				1,
				1,
				1,
				false
			)
			if not item then
				assert.is_not_nil(item)
				return
			end
			assert.is_true(item:IsEligibleEquipment())
		end)

		it("checks if an item is not eligible equipment due to classID", function()
			local item = ItemInfo:new(
				18803,
				"Test Weapon",
				"itemLink",
				2,
				10,
				1,
				"Weapon",
				"Sword",
				1,
				"INVTYPE_WEAPON",
				"texture",
				100,
				2,
				1,
				1,
				1,
				1,
				false
			)
			if not item then
				assert.is_not_nil(item)
				return
			end
			assert.is_false(item:IsEligibleEquipment())
		end)

		it("checks if an item is not eligible equipment due to missing itemEquipLoc", function()
			local item = ItemInfo:new(
				18803,
				"Test Armor",
				"itemLink",
				2,
				10,
				1,
				"Armor",
				"Plate",
				1,
				nil,
				"texture",
				100,
				4,
				4,
				1,
				1,
				1,
				false
			)
			if not item then
				assert.is_not_nil(item)
				return
			end
			assert.is_false(item:IsEligibleEquipment())
		end)

		it("checks if an item is not eligible equipment due to mismatched armor class", function()
			functionMocks.UnitClass.returns("Mage", "MAGE", 1)
			ns.armorClassMapping = { MAGE = 1 }

			local item = ItemInfo:new(
				18803,
				"Test Armor",
				"itemLink",
				2,
				10,
				1,
				"Armor",
				"Plate",
				1,
				"INVTYPE_CHEST",
				"texture",
				100,
				4,
				4,
				1,
				1,
				1,
				false
			)
			if not item then
				assert.is_not_nil(item)
				return
			end
			assert.is_false(item:IsEligibleEquipment())
		end)

		it("checks if an item is not eligible equipment due to missing equip slot", function()
			functionMocks.UnitClass.returns("Warrior", "WARRIOR", 1)
			ns.armorClassMapping = { WARRIOR = 4 }
			ns.equipSlotMap = {}

			local item = ItemInfo:new(
				18803,
				"Test Armor",
				"itemLink",
				2,
				10,
				1,
				"Armor",
				"Plate",
				1,
				"INVTYPE_CHEST",
				"texture",
				100,
				4,
				4,
				1,
				1,
				1,
				false
			)
			if not item then
				assert.is_not_nil(item)
				return
			end
			assert.is_false(item:IsEligibleEquipment())
		end)
	end)
end)
