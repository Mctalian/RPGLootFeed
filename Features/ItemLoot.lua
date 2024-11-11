local addonName, G_RLF = ...

local ItemLoot = G_RLF.RLF:NewModule("ItemLoot", "AceEvent-3.0")

ItemLoot.SecondaryTextOption = {
	["None"] = "None",
	["SellPrice"] = "Sell Price",
	["iLvl"] = "Item Level",
}

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

local nameUnitMap = {}

local function setNameUnitMap()
	local units = {}
	if IsInRaid() then
		for i = 1, MEMBERS_PER_RAID_GROUP do
			table.insert(units, "raid" .. i)
		end
	else
		table.insert(units, "player")

		for i = 2, MEMBERS_PER_RAID_GROUP do
			table.insert(units, "party" .. (i - 1))
		end
	end

	nameUnitMap = {}
	for _, unit in ipairs(units) do
		local name, server = UnitName(unit)
		if name then
			nameUnitMap[name] = unit
		end
	end
end

function ItemLoot.Element:new(...)
	local element = {}
	G_RLF.InitializeLootDisplayProperties(element)

	element.type = "ItemLoot"
	element.IsEnabled = function()
		return ItemLoot:IsEnabled()
	end

	element.isLink = true

	local t
	element.key, t, element.icon, element.quantity, element.sellPrice, element.unit = ...

	if not G_RLF.db.global.enablePartyLoot then
		element.unit = nil
	end

	function element:isPassingFilter(itemName, itemQuality)
		if not G_RLF.db.global.itemQualityFilter[itemQuality] then
			element:getLogger():Debug(
				itemName .. " ignored by quality: " .. itemQualityName(itemQuality),
				addonName,
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

	element.secondaryTextFn = function(...)
		if element.unit then
			local name, server = UnitName(element.unit)
			if server then
				return "    " .. name .. "-" .. server
			end
			return "    " .. name
		end
		local quantity = ...
		if not element.sellPrice or element.sellPrice == 0 then
			return ""
		end
		return "    " .. C_CurrencyInfo.GetCoinTextureString(element.sellPrice * (quantity or 1))
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
	self:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
	self:UnregisterEvent("GROUP_ROSTER_UPDATE")
end

function ItemLoot:OnEnable()
	self:RegisterEvent("CHAT_MSG_LOOT")
	self:RegisterEvent("GET_ITEM_INFO_RECEIVED")
	self:RegisterEvent("GROUP_ROSTER_UPDATE")
	setNameUnitMap()
end

local pendingItemRequests = {}
local function onItemReadyToShow(itemId, itemLink, itemTexture, amount, itemName, itemQuality, sellPrice)
	pendingItemRequests[itemId] = nil
	local e = ItemLoot.Element:new(itemId, itemLink, itemTexture, amount, sellPrice, false)
	e:Show(itemName, itemQuality)
end

local pendingPartyRequests = {}
local function onPartyReadyToShow(itemId, itemLink, itemTexture, amount, itemName, itemQuality, sellPrice, unit)
	pendingPartyRequests[itemId] = nil
	local e = ItemLoot.Element:new(itemId, itemLink, itemTexture, amount, sellPrice, unit)
	e:Show(itemName, itemQuality)
end

function ItemLoot:GET_ITEM_INFO_RECEIVED(eventName, itemID, success)
	if pendingItemRequests[itemID] then
		local itemLink, amount = unpack(pendingItemRequests[itemID])

		if not success then
			error("Failed to load item: " .. itemID .. " " .. itemLink .. " x" .. amount)
		else
			local itemName, _, itemQuality, _, _, _, _, _, _, itemTexture, sellPrice, _, _, _, _, _, _ =
				C_Item.GetItemInfo(itemLink)
			onItemReadyToShow(itemID, itemLink, itemTexture, amount, itemName, itemQuality, sellPrice)
		end
		return
	end

	if pendingPartyRequests[itemID] then
		local itemLink, amount, unit = unpack(pendingPartyRequests[itemID])

		if not success then
			error("Failed to load item: " .. itemID .. " " .. itemLink .. " x" .. amount .. " for " .. unit)
		else
			local itemName, _, itemQuality, _, _, _, _, _, _, itemTexture, sellPrice, _, _, _, _, _, _ =
				C_Item.GetItemInfo(itemLink)
			onPartyReadyToShow(itemID, itemLink, itemTexture, amount, itemName, itemQuality, sellPrice, unit)
		end
		return
	end
end

local function showPartyLoot(msg, itemLink, unit)
	local amount = tonumber(msg:match("r ?x(%d+)") or 1)
	local itemId = itemLink:match("Hitem:(%d+)")
	pendingPartyRequests[itemId] = { itemLink, amount, unit }
	local itemName, _, itemQuality, _, _, _, _, _, _, itemTexture, sellPrice, _, _, _, _, _, _ =
		C_Item.GetItemInfo(itemLink)
	if itemName ~= nil then
		onPartyReadyToShow(itemId, itemLink, itemTexture, amount, itemName, itemQuality, sellPrice, unit)
	end
end

local function showItemLoot(msg, itemLink)
	local amount = tonumber(msg:match("r ?x(%d+)") or 1)
	local itemId = itemLink:match("Hitem:(%d+)")
	pendingItemRequests[itemId] = { itemLink, amount }
	local itemName, _, itemQuality, _, _, _, _, _, _, itemTexture, sellPrice, _, _, _, _, _, _ =
		C_Item.GetItemInfo(itemLink)
	if itemName ~= nil then
		onItemReadyToShow(itemId, itemLink, itemTexture, amount, itemName, itemQuality, sellPrice)
	end
end

function ItemLoot:CHAT_MSG_LOOT(eventName, ...)
	local msg, playerName, _, _, playerName2, _, _, _, _, _, _, guid = ...
	local raidLoot = msg:match("HlootHistory:")
	self:getLogger():Info(eventName, "WOWEVENT", self.moduleName, nil, eventName .. " " .. msg)
	if raidLoot then
		-- Ignore this message as it's a raid loot message
		self:getLogger():Debug("Raid Loot Ignored", "WOWEVENT", self.moduleName, "", msg)
		return
	end

	local me = guid == GetPlayerGuid()
	if not me then
		if not G_RLF.db.global.enablePartyLoot then
			self:getLogger():Debug("Party Loot Ignored", "WOWEVENT", self.moduleName, "", msg)
			return
		end
		local sanitizedPlayerName = (playerName or playerName2):gsub("%-.+", "")
		local unit = nameUnitMap[sanitizedPlayerName]
		local itemLink = msg:match("|c%x+|Hitem:.-|h%[.-%]|h|r")
		if itemLink then
			self:fn(showPartyLoot, msg, itemLink, unit)
		end
		return
	end

	local itemLink = msg:match("|c%x+|Hitem:.-|h%[.-%]|h|r")
	if itemLink then
		self:fn(showItemLoot, msg, itemLink)
	end
end

function ItemLoot:GROUP_ROSTER_UPDATE(eventName, ...)
	self:getLogger():Info(eventName, "WOWEVENT", self.moduleName, nil, eventName)

	setNameUnitMap()
end

return ItemLoot
