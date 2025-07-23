---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

---@class RLF_KeystoneInfo
---@field itemId number
---@field dungeonId number
---@field dungeonName string
---@field level number
---@field affixId1? number
---@field affixId2? number
---@field affixId3? number
---@field affixId4? number
---@field link string

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
---@field keystoneInfo RLF_KeystoneInfo
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
	instance:populateKeystoneInfo()

	return instance
end

function ItemInfo:populateKeystoneInfo()
	self.keystoneInfo = nil
	if not self.itemLink then
		return
	end

	if not (C_Item.IsItemKeystoneByID and C_Item.IsItemKeystoneByID(self.itemId)) then
		return
	end

	local itemLink = self.itemLink
	-- "|cffa335ee|Hitem:180653::::::::60:250::::6:17:381:18:13:19:9:20:7:21:124:22:121:::::|h[Mythic Keystone]|h|r"
	-- Need to strip off everything before and including |Hitem:
	local start, stop = string.find(itemLink, "|Hitem:")
	if not start then
		return
	end
	local fieldString = string.sub(itemLink, stop + 1)
	start, stop = string.find(fieldString, "|h")
	fieldString = string.sub(fieldString, 1, start - 1)
	-- 180653::::::::60:250::::6:17:381:18:13:19:9:20:7:21:124:22:121:::::
	-- Now we need to split the string by ":", include the empty fields
	local fields = {}
	for field in string.gmatch(fieldString, "(.-)" .. ":") do
		table.insert(fields, field)
	end

	local keystoneInfo = {}
	local itemId = tonumber(fields[1])
	if not itemId then
		return
	end
	keystoneInfo.itemId = itemId
	local numModifiers = fields[14]
	for i = 1, numModifiers do
		local modifierValue = tonumber(fields[14 + i * 2])
		if modifierValue then
			if i == 1 then
				keystoneInfo.dungeonId = modifierValue
				keystoneInfo.dungeonName = C_ChallengeMode.GetMapUIInfo(keystoneInfo.dungeonId)
			elseif i == 2 then
				keystoneInfo.level = modifierValue
			elseif i == 3 then
				keystoneInfo.affixId1 = modifierValue
			elseif i == 4 then
				keystoneInfo.affixId2 = modifierValue
			elseif i == 5 then
				keystoneInfo.affixId3 = modifierValue
			elseif i == 6 then
				keystoneInfo.affixId4 = modifierValue
			end
		end
	end
	self.keystoneInfo = keystoneInfo
	local linkPrefix = string.format(
		"|cnIQ4:|Hkeystone:%d:%d:%d:%d:%d:%d:%d|h[",
		self.keystoneInfo.itemId,
		self.keystoneInfo.dungeonId,
		self.keystoneInfo.level,
		self.keystoneInfo.affixId1 or 0,
		self.keystoneInfo.affixId2 or 0,
		self.keystoneInfo.affixId3 or 0,
		self.keystoneInfo.affixId4 or 0
	)
	local linkText =
		string.format(CHALLENGE_MODE_KEYSTONE_NAME, keystoneInfo.dungeonName .. " (" .. keystoneInfo.level .. ")")
	local linkPostFix = "]|h|r"
	self.keystoneInfo.link = linkPrefix .. linkText .. linkPostFix

	self.itemLink = self.keystoneInfo.link
	self.itemName = linkText
	self.itemLevel = keystoneInfo.level
end

---Determine if the item is a mount
---@return boolean
function ItemInfo:IsMount()
	return self.classID == Enum.ItemClass.Miscellaneous and self.subclassID == Enum.ItemMiscellaneousSubclass.Mount
end

---Determine if the item is a quest item
---@return boolean
function ItemInfo:IsQuestItem()
	return self.classID == Enum.ItemClass.Questitem
end

---Determine if the item is Legendary
---@return boolean
function ItemInfo:IsLegendary()
	return self.itemQuality == G_RLF.ItemQualEnum.Legendary
end

function ItemInfo:IsAppearanceCollected()
	if not self:IsEquippableItem() then
		return true -- non-equippable items are not tracked for appearances
	end

	if C_TransmogCollection and C_TransmogCollection.GetItemInfo then
		local appearanceId, modId = C_TransmogCollection.GetItemInfo(self.itemLink)
		if not appearanceId or not modId then
			G_RLF:LogDebug(
				string.format(
					"ItemInfo:IsAppearanceCollected: Unable to determine appearanceId or modId for item %s",
					self.itemLink
				),
				addonName,
				"General",
				tostring(self.itemId)
			)
			return true -- If we can't determine, assume it's collected
		end

		-- Classic implementation
		if
			GetExpansionLevel() < G_RLF.Expansion.SL
			and self.itemQuality > G_RLF.ItemQualEnum.Poor
			and self:IsEligibleEquipment()
			and C_TransmogCollection.PlayerHasTransmog
		then
			G_RLF:LogDebug(
				string.format(
					"ItemInfo:IsAppearanceCollected: Checking appearanceId %d, modId %d for item %s",
					appearanceId,
					modId,
					self.itemLink
				),
				addonName,
				"General",
				tostring(self.itemId)
			)
			return C_TransmogCollection.PlayerHasTransmog(self.itemId, modId)
		end
		-- Pre Warband implementation
		if
			GetExpansionLevel() >= G_RLF.Expansion.SL
			and GetExpansionLevel() < G_RLF.Expansion.TWW
			and self:IsEligibleEquipment()
			and C_TransmogCollection.PlayerHasTransmogByItemInfo
		then
			return C_TransmogCollection.PlayerHasTransmogByItemInfo(self.itemLink)
		end
		-- Retail implementation
		if G_RLF:IsRetail() and C_TransmogCollection.PlayerHasTransmogByItemInfo then
			return C_TransmogCollection.PlayerHasTransmogByItemInfo(self.itemLink)
		end
	end

	return true -- If we can't determine, assume it's collected
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

function ItemInfo:IsEquippableItem()
	return C_Item.IsEquippableItem(self.itemLink)
end

function ItemInfo:IsEligibleEquipment()
	if self.classID ~= Enum.ItemClass.Armor then
		G_RLF:LogDebug(
			string.format("ItemInfo:IsEligibleEquipment: Item class %d is not Armor", self.classID),
			addonName,
			"General",
			tostring(self.itemId)
		)
		return false
	end

	if not self.itemEquipLoc then
		G_RLF:LogDebug(
			string.format("ItemInfo:IsEligibleEquipment: Item %s has no itemEquipLoc", self.itemLink),
			addonName,
			"General",
			tostring(self.itemId)
		)
		return false
	end

	local armorClass = GetHighestArmorClass()
	if not armorClass then
		G_RLF:LogDebug(
			"ItemInfo:IsEligibleEquipment: Unable to determine highest armor class",
			addonName,
			"General",
			tostring(self.itemId)
		)
		return false
	end

	if self.subclassID ~= armorClass and self.subclassID ~= Enum.ItemArmorSubclass.Generic then
		G_RLF:LogDebug(
			string.format(
				"ItemInfo:IsEligibleEquipment: Item subclass %d does not match highest armor class %d",
				self.subclassID,
				armorClass
			),
			addonName,
			"General",
			tostring(self.itemId)
		)
		return false
	end

	local slot = G_RLF.equipSlotMap[self.itemEquipLoc]
	if not slot then
		G_RLF:LogDebug(
			string.format(
				"ItemInfo:IsEligibleEquipment: Item %s has an invalid itemEquipLoc %s",
				self.itemLink,
				self.itemEquipLoc
			),
			addonName,
			"General",
			tostring(self.itemId)
		)
		return false
	end

	return true
end

function ItemInfo:GetEquipmentTypeText()
	if not self.itemEquipLoc or not self:IsEquippableItem() then
		return nil
	end

	if not _G[self.itemEquipLoc] then
		G_RLF:LogDebug(
			string.format(
				"ItemInfo:GetEquipmentTypeText: Item %s has an invalid itemEquipLoc %s",
				self.itemLink,
				self.itemEquipLoc
			),
			addonName,
			G_RLF.FeatureModule.ItemLoot,
			tostring(self.itemId)
		)
		return nil
	end

	local alwaysShowArmorSubTypes = {
		[Enum.ItemArmorSubclass.Cloth] = true,
		[Enum.ItemArmorSubclass.Leather] = true,
		[Enum.ItemArmorSubclass.Mail] = true,
		[Enum.ItemArmorSubclass.Plate] = true,
	}
	local equipLocShowSubType = { INVTYPE_WEAPONMAINHAND = true, INVTYPE_WEAPONOFFHAND = true }
	local equipLocShowOnlySubType = {
		INVTYPE_WEAPON = true,
		INVTYPE_2HWEAPON = true,
		INVTYPE_SHIELD = true,
		INVTYPE_RANGEDRIGHT = true,
		INVTYPE_RANGED = true,
	}

	local equipmentTypeText = " [" .. _G[self.itemEquipLoc] .. "]"
	if self.itemSubType and self.subclassID then
		if self.classID == Enum.ItemClass.Armor and alwaysShowArmorSubTypes[self.subclassID] then
			equipmentTypeText = " [" .. _G[self.itemEquipLoc] .. " - " .. self.itemSubType .. "]"
		elseif equipLocShowSubType[self.itemEquipLoc] then
			equipmentTypeText = " [" .. _G[self.itemEquipLoc] .. " - " .. self.itemSubType .. "]"
		elseif equipLocShowOnlySubType[self.itemEquipLoc] then
			equipmentTypeText = " [" .. self.itemSubType .. "]"
		end
	else
		G_RLF:LogDebug(
			string.format(
				"ItemInfo:GetEquipmentTypeText: Item %s has no itemSubType. subClassID? %d",
				self.itemLink,
				self.subclassID or -1
			),
			addonName,
			G_RLF.FeatureModule.ItemLoot,
			tostring(self.itemId)
		)
	end

	if not self:IsEligibleEquipment() and self.classID == Enum.ItemClass.Armor then
		equipmentTypeText = string.format("%s%s|r", G_RLF:RGBAToHexFormat(1, 0, 0, 1), equipmentTypeText)
	else
		equipmentTypeText = string.format("%s%s|r", G_RLF:RGBAToHexFormat(1, 1, 1, 1), equipmentTypeText)
	end
	return equipmentTypeText
end

G_RLF.ItemInfo = ItemInfo
