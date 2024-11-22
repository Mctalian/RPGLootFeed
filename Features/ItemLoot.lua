local addonName, G_RLF = ...

local ItemLoot = G_RLF.RLF:NewModule("ItemLoot", "AceEvent-3.0")

ItemLoot.SecondaryTextOption = {
	["None"] = "None",
	["SellPrice"] = "Sell Price",
	["iLvl"] = "Item Level",
}

local cachedArmorClass = nil
local function GetHighestArmorClass()
	if cachedArmorClass then
		return cachedArmorClass
	end
	local _, playerClass = UnitClass("player")
	local armorClassMapping = {
		WARRIOR = Enum.ItemArmorSubclass.Plate,
		PALADIN = Enum.ItemArmorSubclass.Plate,
		DEATHKNIGHT = Enum.ItemArmorSubclass.Plate,
		HUNTER = Enum.ItemArmorSubclass.Mail,
		SHAMAN = Enum.ItemArmorSubclass.Mail,
		EVOKER = Enum.ItemArmorSubclass.Mail,
		ROGUE = Enum.ItemArmorSubclass.Leather,
		DRUID = Enum.ItemArmorSubclass.Leather,
		DEMONHUNTER = Enum.ItemArmorSubclass.Leather,
		MONK = Enum.ItemArmorSubclass.Leather,
		PRIEST = Enum.ItemArmorSubclass.Cloth,
		MAGE = Enum.ItemArmorSubclass.Cloth,
		WARLOCK = Enum.ItemArmorSubclass.Cloth,
	}
	cachedArmorClass = armorClassMapping[playerClass]
	return cachedArmorClass
end

local equipSlotMap = {
	INVTYPE_HEAD = 1,
	INVTYPE_NECK = 2,
	INVTYPE_SHOULDER = 3,
	INVTYPE_BODY = 4,
	INVTYPE_CHEST = 5,
	INVTYPE_WAIST = 6,
	INVTYPE_LEGS = 7,
	INVTYPE_FEET = 8,
	INVTYPE_WRIST = 9,
	INVTYPE_HAND = 10,
	INVTYPE_FINGER = { 11, 12 }, -- Rings
	INVTYPE_TRINKET = { 13, 14 }, -- Trinkets
	INVTYPE_CLOAK = 15,
	INVTYPE_WEAPON = { 16, 17 }, -- One-handed weapons
	INVTYPE_SHIELD = 17, -- Off-hand
	INVTYPE_2HWEAPON = 16, -- Two-handed weapons
	INVTYPE_WEAPONMAINHAND = 16,
	INVTYPE_WEAPONOFFHAND = 17,
	INVTYPE_HOLDABLE = 17, -- Off-hand items
	INVTYPE_RANGED = 18, -- Bows, guns, wands
	INVTYPE_TABARD = 19,
}

ItemLoot.Element = {}

local ItemInfo = G_RLF.ItemInfo

function ItemLoot:ItemQualityName(enumValue)
	for k, v in pairs(Enum.ItemQuality) do
		if v == enumValue then
			return k
		end
	end
	return nil
end

function ItemLoot:SetNameUnitMap()
	local units = {}
	local groupMembers = GetNumGroupMembers()
	if IsInRaid() then
		for i = 1, groupMembers do
			table.insert(units, "raid" .. i)
		end
	else
		table.insert(units, "player")

		for i = 2, groupMembers do
			table.insert(units, "party" .. (i - 1))
		end
	end

	self.nameUnitMap = {}
	for _, unit in ipairs(units) do
		local name, server = UnitName(unit)
		if name then
			self.nameUnitMap[name] = unit
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

	local t, info
	info, element.quantity, element.unit = ...
	t = info.itemLink

	element.key = info.itemId
	element.icon = info.itemTexture
	element.sellPrice = info.sellPrice

	if not G_RLF.db.global.enablePartyLoot then
		element.unit = nil
	end

	function element:isPassingFilter(itemName, itemQuality)
		if not G_RLF.db.global.itemQualityFilter[itemQuality] then
			element:getLogger():Debug(
				itemName .. " ignored by quality: " .. ItemLoot:ItemQualityName(itemQuality),
				addonName,
				"ItemLoot",
				"",
				nil,
				self.quantity
			)
			return false
		end

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

	function element:SetHighlight()
		-- Highlight Mounts
		if
			info.classID == Enum.ItemClass.Miscellaneous
			and info.subclassID == Enum.ItemMiscellaneousSubclass.Mount
			and G_RLF.db.global.itemHighlights.mounts
		then
			self.highlight = true
			return
		end
		-- Highlight Legendary Items
		if info.itemQuality == Enum.ItemQuality.Legendary and G_RLF.db.global.itemHighlights.legendary then
			self.highlight = true
			return
		end
		-- Highlight Better Than Equipped
		if G_RLF.db.global.itemHighlights.betterThanEquipped and info.classID == Enum.ItemClass.Armor then
			local armorClass = GetHighestArmorClass()
			if
				(armorClass and info.subclassID == armorClass)
				or (info.subclassID == Enum.ItemArmorSubclass.Generic and info.itemEquipLoc)
			then
				local slot = equipSlotMap[info.itemEquipLoc]
				if not slot then
					return
				end
				local equippedLink
				if type(slot) == "table" then
					for _, s in ipairs(slot) do
						equippedLink = GetInventoryItemLink("player", s)
						if equippedLink then
							break
						end
					end
				else
					equippedLink = GetInventoryItemLink("player", slot)
				end
				if not equippedLink then
					return
				end
				local equippedId = C_Item.GetItemIDForItemInfo(equippedLink)
				local equippedInfo = ItemInfo:new(nil, C_Item.GetItemInfo(equippedLink))
				if equippedInfo and equippedInfo.itemLevel and equippedInfo.itemLevel < info.itemLevel then
					self.highlight = true
					return
				elseif equippedInfo and equippedInfo.itemLevel == info.itemLevel then
					local statDelta = C_Item.GetItemStatDelta(equippedLink, info.itemLink)
					for k, v in pairs(statDelta) do
						-- Has a Tertiary Stat
						if k:find("ITEM_MOD_CR_") and v > 0 then
							self.highlight = true
							return
						end
						if k:find("EMPTY_SOCKET_") and v > 0 then
							self.highlight = true
							return
						end
					end
				end
			end
		end
	end

	return element
end

local logger
function ItemLoot:OnInitialize()
	self.pendingItemRequests = {}
	self.pendingPartyRequests = {}
	self.nameUnitMap = {}
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
	self:SetNameUnitMap()
end

function ItemLoot:OnItemReadyToShow(info, amount)
	self.pendingItemRequests[info.itemId] = nil
	local e = ItemLoot.Element:new(info, amount, false)
	e:SetHighlight()
	e:Show(info.itemName, info.itemQuality)
end

function ItemLoot:OnPartyReadyToShow(info, amount, unit)
	if not unit then
		return
	end
	self.pendingPartyRequests[info.itemId] = nil
	local e = ItemLoot.Element:new(info, amount, unit)
	e:Show(info.itemName, info.itemQuality)
end

function ItemLoot:GET_ITEM_INFO_RECEIVED(eventName, itemID, success)
	if self.pendingItemRequests[itemID] then
		local itemLink, amount = unpack(self.pendingItemRequests[itemID])

		if not success then
			error("Failed to load item: " .. itemID .. " " .. itemLink .. " x" .. amount)
		else
			local info = ItemInfo:new(itemID, C_Item.GetItemInfo(itemLink))
			self:OnItemReadyToShow(info, amount)
		end
		return
	end

	if self.pendingPartyRequests[itemID] then
		local itemLink, amount, unit = unpack(self.pendingPartyRequests[itemID])

		if not success then
			error("Failed to load item: " .. itemID .. " " .. itemLink .. " x" .. amount .. " for " .. unit)
		else
			local info = ItemInfo:new(itemID, C_Item.GetItemInfo(itemLink))
			self:OnPartyReadyToShow(info, amount, unit)
		end
		return
	end
end

function ItemLoot:ShowPartyLoot(msg, itemLink, unit)
	local amount = tonumber(msg:match("r ?x(%d+)") or 1)
	local itemId = itemLink:match("Hitem:(%d+)")
	self.pendingPartyRequests[itemId] = { itemLink, amount, unit }
	local info = ItemInfo:new(itemId, C_Item.GetItemInfo(itemLink))
	if info ~= nil then
		self:OnPartyReadyToShow(info, amount, unit)
	end
end

function ItemLoot:ShowItemLoot(msg, itemLink)
	local amount = tonumber(msg:match("r ?x(%d+)") or 1)
	local itemId = C_Item.GetItemIDForItemInfo(itemLink)
	self.pendingItemRequests[itemId] = { itemLink, amount }
	local info = ItemInfo:new(itemId, C_Item.GetItemInfo(itemLink))
	if info ~= nil then
		self:OnItemReadyToShow(info, amount)
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
		local unit = self.nameUnitMap[sanitizedPlayerName]
		if not unit then
			return
		end
		local itemLink = msg:match("|c%x+|Hitem:.-|h%[.-%]|h|r")
		if itemLink then
			self:fn(self.ShowPartyLoot, self, msg, itemLink, unit)
		end
		return
	end

	local itemLink = msg:match("|c%x+|Hitem:.-|h%[.-%]|h|r")
	if itemLink then
		self:fn(self.ShowItemLoot, self, msg, itemLink)
	end
end

function ItemLoot:GROUP_ROSTER_UPDATE(eventName, ...)
	self:getLogger():Info(eventName, "WOWEVENT", self.moduleName, nil, eventName)

	self:SetNameUnitMap()
end

return ItemLoot
