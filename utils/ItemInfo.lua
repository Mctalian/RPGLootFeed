local addonName, G_RLF = ...

local ItemInfo = {}
ItemInfo.__index = ItemInfo
function ItemInfo:new(...)
	local self = {}
	setmetatable(self, ItemInfo)
	self.itemId, self.itemName, self.itemLink, self.itemQuality, self.itemLevel, self.itemMinLevel, self.itemType, self.itemSubType, self.itemStackCount, self.itemEquipLoc, self.itemTexture, self.sellPrice, self.classID, self.subclassID, self.bindType, self.expansionID, self.setID, self.isCraftingReagent =
		...
	if not self.itemName then
		return nil
	end
	if not self.itemId then
		self.itemId = C_Item.GetItemIDForItemInfo(self.itemLink)
	end
	return self
end

function ItemInfo:IsMount()
	-- Highlight Mounts
	if
		self.classID == Enum.ItemClass.Miscellaneous
		and self.subclassID == Enum.ItemMiscellaneousSubclass.Mount
	then
		return true
	end

	return false
end

function ItemInfo:IsLegendary()
	-- Highlight Legendary Items
	if self.itemQuality == Enum.ItemQuality.Legendary then
		return true
	end

	return false
end

local function GetHighestArmorClass()
	if G_RLF.cachedArmorClass then
		return G_RLF.cachedArmorClass
	end
	local _, playerClass = UnitClass("player")
	G_RLF.cachedArmorClass = G_RLF.armorClassMapping[playerClass]
	return G_RLF.cachedArmorClass
end

function ItemInfo:IsEligibleEquipment()
	if self.classID ~= Enum.ItemClass.Armor then
		return false
	end

	if not self.itemEquipLoc then
		return false
	end

	local armorClass = GetHighestArmorClass()
	if not armorClass then
		return false
	end

	if self.subclassID ~= armorClass and self.subclassID ~= Enum.ItemArmorSubclass.Generic then
		return false
	end

	local slot = G_RLF.equipSlotMap[self.itemEquipLoc]
	if not slot then
		return false
	end

	return true
end

G_RLF.ItemInfo = ItemInfo