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
	if self.classID == Enum.ItemClass.Miscellaneous and self.subclassID == Enum.ItemMiscellaneousSubclass.Mount then
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

local function ClassicSkillLineCheck()
	local armorClass = nil
	for i = 1, GetNumSkillLines() do
		local skillName, isHeader, a, skillRank, b, c, skillMaxRank = GetSkillLineInfo(i)
		if not isHeader then
			if skillName == "Plate Mail" then
				armorClass = Enum.ItemArmorSubclass.Plate
			elseif skillName == "Mail" and (armorClass == nil or armorClass < Enum.ItemArmorSubclass.Mail) then
				armorClass = Enum.ItemArmorSubclass.Mail
			elseif skillName == "Leather" and (armorClass == nil or armorClass < Enum.ItemArmorSubclass.Leather) then
				armorClass = Enum.ItemArmorSubclass.Leather
			elseif skillName == "Cloth" and armorClass == nil then
				armorClass = Enum.ItemArmorSubclass.Cloth
			end
		end
	end
	return armorClass
end

local function GetHighestArmorClass()
	if G_RLF.cachedArmorClass and GetExpansionLevel() >= G_RLF.Expansion.CATA then
		return G_RLF.cachedArmorClass
	end
	local _, playerClass = UnitClass("player")

	if GetExpansionLevel() >= G_RLF.Expansion.CATA then
		G_RLF.cachedArmorClass = G_RLF.armorClassMapping[playerClass]
	else
		G_RLF.cachedArmorClass = ClassicSkillLineCheck()
	end

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
