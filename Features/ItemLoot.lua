local addonName, ns = ...

local ItemLoot = G_RLF.RLF:NewModule("ItemLoot", "AceEvent-3.0")

-- local equipLocToSlotID = {
--   ["INVTYPE_HEAD"] = INVSLOT_HEAD,
--   ["INVTYPE_NECK"] = INVSLOT_NECK,
--   ["INVTYPE_SHOULDER"] = INVSLOT_SHOULDER,
--   ["INVTYPE_CHEST"] = INVSLOT_CHEST,
--   ["INVTYPE_WAIST"] = INVSLOT_WAIST,
--   ["INVTYPE_LEGS"] = INVSLOT_LEGS,
--   ["INVTYPE_FEET"] = INVSLOT_FEET,
--   ["INVTYPE_WRIST"] = INVSLOT_WRIST,
--   ["INVTYPE_HAND"] = INVSLOT_HAND,
--   ["INVSLOT_FINGER1"] = INVSLOT_FINGER1,
--   ["INVSLOT_FINGER2"] = INVSLOT_FINGER2,
--   ["INVSLOT_TRINKET1"] = INVSLOT_TRINKET1,
--   ["INVSLOT_TRINKET2"] = INVSLOT_TRINKET2,
--   ["INVTYPE_BACK"] = INVSLOT_BACK,
--   ["INVTYPE_MAINHAND"] = INVSLOT_MAINHAND,
--   ["INVTYPE_OFFHAND"] = INVSLOT_OFFHAND,
--   ["INVTYPE_RANGED"] = INVSLOT_RANGED,
--   ["INVTYPE_WEAPON"] = INVSLOT_MAINHAND, -- Generally used for one-handed weapons
--   ["INVTYPE_2HWEAPON"] = INVSLOT_MAINHAND, -- Two-handed weapons
--   ["INVTYPE_RANGEDRIGHT"] = INVSLOT_RANGED, -- Ranged weapons
-- }

ItemLoot.Element = {}

local function itemQualityName(enumValue)
	for k, v in pairs(Enum.ItemQuality) do
		if v == enumValue then
			return k
		end
	end
	return nil
end

function ItemLoot.Element:new(...)
	local element = {}
	ns.InitializeLootDisplayProperties(element)

	element.type = "ItemLoot"
	element.IsEnabled = function()
		return ItemLoot:IsEnabled()
	end

	element.isLink = true

	local t
	element.key, t, element.icon, element.quantity = ...

	element.isPassingFilter = function()
		local itemName, _, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType, expansionID, setID, isCraftingReagent =
			C_Item.GetItemInfo(t)

		if not G_RLF.db.global.itemQualityFilter[itemQuality] then
			element:getLogger():Debug(
				itemName .. " ignored by quality: " .. itemQualityName(itemQuality),
				G_RLF.addonName,
				"ItemLoot",
				"",
				nil,
				self.quantity
			)
			return false
		end

		-- if G_RLF.db.global.onlyBetterThanEquipped and itemEquipLoc then
		--   local equippedLink = GetInventoryItemLink("player", equipLocToSlotID[itemEquipLoc])
		--   if equippedLink then
		--     local _, _, _, equippediLvl, _, _, equippedSubType = C_Item.GetItemInfo(equippedLink)
		--     if equippediLvl > itemLevel then
		--         return
		--     elseif equippedSubType ~= itemSubType then
		--         return
		--     end
		--   end
		-- end

		return true
	end

	element.textFn = function(existingQuantity, truncatedLink)
		if not truncatedLink then
			return t
		end
		return truncatedLink .. " x" .. ((existingQuantity or 0) + element.quantity)
	end

	return element
end

local logger
function ItemLoot:OnInitialize()
	if G_RLF.db.global.itemLootFeed then
		self:Enable()
	else
		self:Disable()
	end
end

function ItemLoot:OnDisable()
	self:UnregisterEvent("CHAT_MSG_LOOT")
end

function ItemLoot:OnEnable()
	self:RegisterEvent("CHAT_MSG_LOOT")
end

local function showItemLoot(msg, itemLink)
	local amount = tonumber(msg:match("r ?x(%d+)") or 1)
	local _, _, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType, expansionID, setID, isCraftingReagent =
		C_Item.GetItemInfo(itemLink)

	local itemId = itemLink:match("Hitem:(%d+)")

	local e = ItemLoot.Element:new(itemId, itemLink, itemTexture, amount)
	e:Show()
end

function ItemLoot:CHAT_MSG_LOOT(eventName, ...)
	local msg, _, _, _, _, _, _, _, _, _, _, guid = ...
	local raidLoot = msg:match("HlootHistory:")
	self:getLogger():Info(eventName, "WOWEVENT", self.moduleName, nil, eventName .. " " .. msg)
	if raidLoot then
		-- Ignore this message as it's a raid loot message
		self:getLogger():Debug("Raid Loot Ignored", "WOWEVENT", self.moduleName, "", msg)
		return
	end

	local me = guid == GetPlayerGuid()
	if not me then
		self:getLogger():Debug("Group Member Loot Ignored", "WOWEVENT", self.moduleName, "", msg)
		return
	end

	local itemLink = msg:match("|c%x+|Hitem:.-|h%[.-%]|h|r")
	if itemLink then
		self:fn(showItemLoot, msg, itemLink)
	end
end

return ItemLoot
