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

function ItemLoot:CHAT_MSG_LOOT(_, ...)
	local msg, _, _, _, _, _, _, _, _, _, _, guid = ...
	local raidLoot = msg:match("HlootHistory:")
	if raidLoot then
		-- Ignore this message as it's a raid loot message
		return
	end

	local me = guid == GetPlayerGuid()
	if not me then
		return
	end
	local itemLink = msg:match("|c%x+|Hitem:.-|h%[.-%]|h|r")
	if itemLink then
		local amount = msg:match("r ?x(%d+)") or 1
		local _, _, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType, expansionID, setID, isCraftingReagent =
			C_Item.GetItemInfo(itemLink)
		if not G_RLF.db.global.itemQualityFilter[itemQuality] then
			return
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
		G_RLF.LootDisplay:ShowLoot(itemLink, itemLink, itemTexture, amount)
	end
end
