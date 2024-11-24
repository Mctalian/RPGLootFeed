local addonName, G_RLF = ...

local ItemLoot = G_RLF.RLF:NewModule("ItemLoot", "AceEvent-3.0")

ItemLoot.SecondaryTextOption = {
	["None"] = "None",
	["SellPrice"] = "Sell Price",
	["iLvl"] = "Item Level",
}

local cachedArmorClass = nil
local onlyEpicPartyLoot = false

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

function ItemLoot:SetPartyLootFilters()
	if IsInRaid() then
		onlyEpicPartyLoot = true
		return
	end

	if IsInInstance() then
		onlyEpicPartyLoot = true
		return
	end

	onlyEpicPartyLoot = false
end

local function IsMount(info)
	if G_RLF.db.global.itemHighlights.mounts then
		return info:IsMount()
	end
end

local function IsLegendary(info)
	if G_RLF.db.global.itemHighlights.legendaries then
		return info:IsLegendary()
	end
end

local function IsBetterThanEquipped(info)
	-- Highlight Better Than Equipped
	if G_RLF.db.global.itemHighlights.betterThanEquipped then 
		

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
		local equippedInfo = ItemInfo:new(equippedId, C_Item.GetItemInfo(equippedLink))
		if not equippedInfo then
			return
		end

		if equippedInfo.itemLevel and equippedInfo.itemLevel < info.itemLevel then
			self.highlight = true
			return
		elseif equippedInfo.itemLevel == info.itemLevel then
			local statDelta = C_Item.GetItemStatDelta(equippedLink, info.itemLink)
			for k, v in pairs(statDelta) do
				-- Has a Tertiary Stat
				if k:find("ITEM_MOD_CR_") and v > 0 then
					self.highlight = true
					return
				end
				-- Has a Gem Socket
				if k:find("EMPTY_SOCKET_") and v > 0 then
					self.highlight = true
					return
				end
			end
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
			G_RLF:LogDebug(
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
			if not name then
				return "A former party member"
			end
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
		self.highlight = IsMount(info) or
			IsLegendary(info) or
			IsBetterThanEquipped(info)
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
	if onlyEpicPartyLoot and info.itemQuality < Enum.ItemQuality.Epic then
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
	G_RLF:LogInfo(eventName, "WOWEVENT", self.moduleName, nil, eventName .. " " .. msg)
	if raidLoot then
		-- Ignore this message as it's a raid loot message
		G_RLF:LogDebug("Raid Loot Ignored", "WOWEVENT", self.moduleName, "", msg)
		return
	end

	local me = guid == GetPlayerGuid()
	if not me then
		if not G_RLF.db.global.enablePartyLoot then
			G_RLF:LogDebug("Party Loot Ignored", "WOWEVENT", self.moduleName, "", msg)
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
	G_RLF:LogInfo(eventName, "WOWEVENT", self.moduleName, nil, eventName)

	self:SetNameUnitMap()
	self:SetPartyLootFilters()
end

return ItemLoot
