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
--- @param itemId? string|number
--- @param itemName? string
--- @param itemLink? string
--- @param itemQuality? number
--- @param itemLevel? number
--- @param itemMinLevel? number
--- @param itemType? string
--- @param itemSubType? string
--- @param itemStackCount? number
--- @param itemEquipLoc? string
--- @param itemTexture? string
--- @param sellPrice? number
--- @param classID? number
--- @param subclassID? number
--- @param bindType? number
--- @param expansionID? number
--- @param setID? number
--- @param isCraftingReagent? boolean
--- @return RLF_ItemInfo | nil
function ItemInfo:new(
	itemId,
	itemName,
	itemLink,
	itemQuality,
	itemLevel,
	itemMinLevel,
	itemType,
	itemSubType,
	itemStackCount,
	itemEquipLoc,
	itemTexture,
	sellPrice,
	classID,
	subclassID,
	bindType,
	expansionID,
	setID,
	isCraftingReagent
)
	local instance = {}
	setmetatable(instance, ItemInfo)
	if type(itemId) == "string" then
		instance.itemId = tonumber(itemId)
	else
		instance.itemId = itemId
	end
	instance.itemName = itemName
	instance.itemLink = itemLink
	instance.itemQuality = itemQuality
	instance.itemLevel = itemLevel
	instance.itemMinLevel = itemMinLevel
	instance.itemType = itemType
	instance.itemSubType = itemSubType
	instance.itemStackCount = itemStackCount
	instance.itemEquipLoc = itemEquipLoc
	instance.itemTexture = itemTexture
	instance.sellPrice = sellPrice
	instance.classID = classID
	instance.subclassID = subclassID
	instance.bindType = bindType
	instance.expansionID = expansionID
	instance.setID = setID
	instance.isCraftingReagent = isCraftingReagent

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
