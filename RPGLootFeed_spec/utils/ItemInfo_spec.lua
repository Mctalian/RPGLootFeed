local nsMocks = require("RPGLootFeed_spec._mocks.Internal.addonNamespace")
local assert = require("luassert")
local busted = require("busted")
local before_each = busted.before_each
local describe = busted.describe
local it = busted.it

describe("ItemInfo", function()
	---@type test_G_RLF, RLF_ItemInfo
	local ns, ItemInfo
	local itemMocks, functionMocks

	before_each(function()
		functionMocks = require("RPGLootFeed_spec._mocks.WoWGlobals.Functions")
		require("RPGLootFeed_spec._mocks.WoWGlobals.Enum")
		itemMocks = require("RPGLootFeed_spec._mocks.WoWGlobals.namespaces.C_Item")
		ns = nsMocks:unitLoadedAfter(nsMocks.LoadSections.All)

		assert(loadfile("RPGLootFeed/utils/ItemInfo.lua"))("TestAddon", ns)
		---@type RLF_ItemInfo
		ItemInfo = ns.ItemInfo
	end)

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
			---@diagnostic disable-next-line: duplicate-set-field
			_G.UnitClass = function(unit)
				return nil, "Mage"
			end
			ns.armorClassMapping = { Mage = 1 }

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
			---@diagnostic disable-next-line: duplicate-set-field
			_G.UnitClass = function(unit)
				return nil, "Warrior"
			end
			ns.armorClassMapping = { Warrior = 4 }
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
