---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

---@class RLF_ItemInfo
---@field itemId number
---@field itemName string
---@field itemLink string
---@field itemQuality number
---@field itemLevel number
---@field itemMinLevel number
---@field itemType string
---@field itemSubType string
---@field itemStackCount number
---@field itemEquipLoc string
---@field itemTexture string
---@field sellPrice number
---@field classID number
---@field subclassID number
---@field bindType number
---@field expansionID number
---@field setID number
---@field isCraftingReagent boolean
local ItemInfo = {}
ItemInfo.__index = ItemInfo

--- Create a new ItemInfo object
--- @param ... number | string | boolean | nil
--- @return RLF_ItemInfo | nil
function ItemInfo:new(...)
	local instance = {}
	setmetatable(instance, ItemInfo)
	instance.itemId, instance.itemName, instance.itemLink, instance.itemQuality, instance.itemLevel, instance.itemMinLevel, instance.itemType, instance.itemSubType, instance.itemStackCount, instance.itemEquipLoc, instance.itemTexture, instance.sellPrice, instance.classID, instance.subclassID, instance.bindType, instance.expansionID, instance.setID, instance.isCraftingReagent =
		...
	if instance.itemName == nil then
		return nil
	end
	if instance.itemId == nil then
		instance.itemId = C_Item.GetItemIDForItemInfo(instance.itemLink)
	end
	instance.itemId = tonumber(instance.itemId)
	return instance
end

---Determine if the item is a mount
---@return boolean
function ItemInfo:IsMount()
	-- Highlight Mounts
	if self.classID == Enum.ItemClass.Miscellaneous and self.subclassID == Enum.ItemMiscellaneousSubclass.Mount then
		return true
	end

	return false
end

---Determine if the item is Legendary
---@return boolean
function ItemInfo:IsLegendary()
	-- Highlight Legendary Items
	if self.itemQuality == Enum.ItemQuality.Legendary then
		return true
	end

	return false
end

---Determine the highest armor proficiency the character has; Clients prior to Cata only
---@return number | nil
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

---Determine the highest armor proficiency the character has
---@return number | nil
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
