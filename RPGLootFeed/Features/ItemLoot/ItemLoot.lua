---@type string, G_RLF
local addonName, G_RLF = ...

---@class ItemLoot: RLF_Module, AceEvent
local ItemLoot = G_RLF.RLF:NewModule("ItemLoot", "AceEvent-3.0")

local C = LibStub("C_Everywhere")

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
		else
			G_RLF:LogError("Failed to get name for unit: " .. unit, addonName, self.moduleName)
		end
	end
end

function ItemLoot:SetPartyLootFilters()
	if IsInRaid() and G_RLF.db.global.partyLoot.onlyEpicAndAboveInRaid then
		onlyEpicPartyLoot = true
		return
	end

	if IsInInstance() and G_RLF.db.global.partyLoot.onlyEpicAndAboveInInstance then
		onlyEpicPartyLoot = true
		return
	end

	onlyEpicPartyLoot = false
end

local function IsMount(info)
	if G_RLF.db.global.item.itemHighlights.mounts then
		return info:IsMount()
	end
end

local function IsLegendary(info)
	if G_RLF.db.global.item.itemHighlights.legendaries then
		return info:IsLegendary()
	end
end

local function IsBetterThanEquipped(info)
	-- Highlight Better Than Equipped
	if G_RLF.db.global.item.itemHighlights.betterThanEquipped and info:IsEligibleEquipment() then
		local equippedLink
		local slot = G_RLF.equipSlotMap[info.itemEquipLoc]
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

		local equippedId = C.Item.GetItemIDForItemInfo(equippedLink)
		local equippedInfo = ItemInfo:new(equippedId, C.Item.GetItemInfo(equippedLink))
		if not equippedInfo then
			return
		end

		if equippedInfo.itemLevel and equippedInfo.itemLevel < info.itemLevel then
			return true
		elseif equippedInfo.itemLevel == info.itemLevel then
			local statDelta = C.Item.GetItemStatDelta(equippedLink, info.itemLink)
			for k, v in pairs(statDelta) do
				-- Has a Tertiary Stat
				if k:find("ITEM_MOD_CR_") and v > 0 then
					return true
				end
				-- Has a Gem Socket
				if k:find("EMPTY_SOCKET_") and v > 0 then
					return true
				end
			end
		end
	end
end

local function getItemLevels(toLink, fromLink)
	local toInfo = ItemInfo:new(C.Item.GetItemIDForItemInfo(toLink), C.Item.GetItemInfo(toLink))
	if not toInfo then
		return 0, 0
	end
	local fromInfo = ItemInfo:new(C.Item.GetItemIDForItemInfo(fromLink), C.Item.GetItemInfo(fromLink))
	if not fromInfo then
		return 0, 0
	end
	return toInfo.itemLevel, fromInfo.itemLevel
end

function ItemLoot.Element:new(...)
	---@class ItemLoot.Element: RLF_LootElement
	local element = {}
	G_RLF.InitializeLootDisplayProperties(element)

	element.type = "ItemLoot"
	element.IsEnabled = function()
		return ItemLoot:IsEnabled()
	end

	element.isLink = true

	local itemLink, info, fromLink
	info, element.quantity, element.unit, fromLink = ...
	itemLink = info.itemLink

	element.key = info.itemId
	if fromLink then
		element.key = "UPGRADE_" .. element.key
	end

	element.icon = info.itemTexture
	element.sellPrice = info.sellPrice

	if not G_RLF.db.global.partyLoot.enabled then
		element.unit = nil
	end

	function element:isPassingFilter(itemName, itemQuality)
		if not G_RLF.db.global.item.itemQualityFilter[itemQuality] then
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
			return itemLink
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

		local fontSize = G_RLF.db.global.styling.fontSize

		if fromLink ~= "" and fromLink ~= nil then
			local toItemLevel, fromItemLevel = getItemLevels(itemLink, fromLink)
			if toItemLevel == 0 or fromItemLevel == 0 then
				return ""
			end
			local atlasIconSize = fontSize * 1.5
			local atlasArrow = "|A:npe_arrowrightglow:" .. atlasIconSize .. ":" .. atlasIconSize .. ":0:0|a"
			return "    " .. fromItemLevel .. " " .. atlasArrow .. " " .. toItemLevel
		end

		local quantity = ...
		local atlasIconSize = fontSize * 1.5
		local atlasIcon
		local unitPrice
		local pricesForSellableItems = G_RLF.db.global.item.pricesForSellableItems
		if pricesForSellableItems == G_RLF.PricesEnum.Vendor then
			if not element.sellPrice or element.sellPrice == 0 then
				return ""
			end
			if G_RLF:IsRetail() then
				atlasIcon = "spellicon-256x256-selljunk"
			elseif G_RLF:IsClassic() or G_RLF:IsCataClassic() then
				atlasIcon = "bags-junkcoin"
			end
			unitPrice = element.sellPrice
		elseif pricesForSellableItems == G_RLF.PricesEnum.AH then
			local marketPrice = G_RLF.AuctionIntegrations.activeIntegration:GetAHPrice(itemLink)
			if not marketPrice or marketPrice == 0 then
				return ""
			end
			unitPrice = marketPrice
			if G_RLF:IsRetail() then
				atlasIcon = "auctioneer"
			elseif G_RLF:IsClassic() or G_RLF:IsCataClassic() then
				atlasIcon = "Auctioneer"
			end
		end
		if unitPrice then
			local str = "    "
			if atlasIcon then
				str = str .. "|A:" .. atlasIcon .. ":" .. atlasIconSize .. ":" .. atlasIconSize .. ":0:0|a  "
			end
			str = str .. C_CurrencyInfo.GetCoinTextureString(unitPrice * (quantity or 1))
			return str
		end

		return ""
	end

	element.isMount = IsMount(info)
	element.isLegendary = IsLegendary(info)
	element.isBetterThanEquipped = IsBetterThanEquipped(info)

	function element:PlaySoundIfEnabled()
		local soundsConfig = G_RLF.db.global.item.sounds
		if self.isMount and soundsConfig.mounts.enabled and soundsConfig.mounts.sound ~= "" then
			RunNextFrame(function()
				PlaySoundFile(soundsConfig.mounts.sound)
			end)
		elseif self.isLegendary and soundsConfig.legendaries.enabled and soundsConfig.legendaries.sound ~= "" then
			RunNextFrame(function()
				PlaySoundFile(soundsConfig.legendaries.sound)
			end)
		elseif
			self.isBetterThanEquipped
			and soundsConfig.betterThanEquipped.enabled
			and soundsConfig.betterThanEquipped.sound ~= ""
		then
			RunNextFrame(function()
				PlaySoundFile(soundsConfig.betterThanEquipped.sound)
			end)
		end
	end

	function element:SetHighlight()
		self.highlight = self.isMount or self.isLegendary or self.isBetterThanEquipped
	end

	return element
end

function ItemLoot:OnInitialize()
	self.pendingItemRequests = {}
	self.pendingPartyRequests = {}
	self.nameUnitMap = {}
	if G_RLF.db.global.item.enabled then
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
	G_RLF:LogDebug("OnEnable", addonName, self.moduleName)
end

function ItemLoot:OnItemReadyToShow(info, amount, fromLink)
	self.pendingItemRequests[info.itemId] = nil
	local e = ItemLoot.Element:new(info, amount, false, fromLink)
	e:SetHighlight()
	e:Show(info.itemName, info.itemQuality)
	e:PlaySoundIfEnabled()
end

function ItemLoot:OnPartyReadyToShow(info, amount, unit)
	if not unit then
		return
	end
	if onlyEpicPartyLoot and info.itemQuality < Enum.ItemQuality.Epic then
		return
	end
	if G_RLF.db.global.partyLoot.itemQualityFilter[info.itemQuality] == false then
		return
	end
	self.pendingPartyRequests[info.itemId] = nil
	local e = ItemLoot.Element:new(info, amount, unit)
	e:Show(info.itemName, info.itemQuality)
end

function ItemLoot:GET_ITEM_INFO_RECEIVED(eventName, itemID, success)
	if self.pendingItemRequests[itemID] then
		local itemLink, amount, fromLink = unpack(self.pendingItemRequests[itemID])

		if not success then
			error("Failed to load item: " .. itemID .. " " .. itemLink .. " x" .. amount)
		else
			local info = ItemInfo:new(itemID, C.Item.GetItemInfo(itemLink))
			self:OnItemReadyToShow(info, amount, fromLink)
		end
		return
	end

	if self.pendingPartyRequests[itemID] then
		local itemLink, amount, unit = unpack(self.pendingPartyRequests[itemID])

		if not success then
			error("Failed to load item: " .. itemID .. " " .. itemLink .. " x" .. amount .. " for " .. unit)
		else
			local info = ItemInfo:new(itemID, C.Item.GetItemInfo(itemLink))
			self:OnPartyReadyToShow(info, amount, unit)
		end
		return
	end
end

function ItemLoot:ShowPartyLoot(msg, itemLink, unit)
	local amount = tonumber(msg:match("r ?x(%d+)") or 1)
	local itemId = itemLink:match("Hitem:(%d+)")
	self.pendingPartyRequests[itemId] = { itemLink, amount, unit }
	local info = ItemInfo:new(itemId, C.Item.GetItemInfo(itemLink))
	if info ~= nil then
		self:OnPartyReadyToShow(info, amount, unit)
	end
end

function ItemLoot:ShowItemLoot(msg, itemLink, fromLink)
	local amount = tonumber(msg:match("r ?x(%d+)") or 1)
	local itemId = C.Item.GetItemIDForItemInfo(itemLink)
	self.pendingItemRequests[itemId] = { itemLink, amount, fromLink }
	local info = ItemInfo:new(itemId, C.Item.GetItemInfo(itemLink))
	if info ~= nil then
		self:OnItemReadyToShow(info, amount, fromLink)
	end
end

-- Function to extract item links from the message
local function extractItemLinks(message)
	local itemLinks = {}
	for itemLink in message:gmatch("|c%x+|Hitem:.-|h%[.-%]|h|r") do
		table.insert(itemLinks, itemLink)
	end
	return itemLinks
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

	local me = false
	if G_RLF:IsRetail() then
		me = guid == GetPlayerGuid()
	elseif G_RLF:IsClassic() or G_RLF:IsCataClassic() then
		me = playerName2 == UnitName("player")
	end

	local itemLink, fromLink = nil, nil
	local itemLinks = extractItemLinks(msg)

	-- Item Upgrades
	if #itemLinks == 2 then
		fromLink = itemLinks[1]
		itemLink = itemLinks[2]
	else
		itemLink = itemLinks[1]
	end

	if not me then
		if not G_RLF.db.global.partyLoot.enabled then
			G_RLF:LogDebug("Party Loot Ignored", "WOWEVENT", self.moduleName, "", msg)
			return
		end
		local name = playerName
		if name == "" or name == nil then
			name = playerName2
		end
		local sanitizedPlayerName = name:gsub("%-.+", "")
		local unit = self.nameUnitMap[sanitizedPlayerName]
		if not unit then
			G_RLF:LogDebug(
				"Party Loot Ignored - no matching party member (" .. sanitizedPlayerName .. ")",
				"WOWEVENT",
				self.moduleName,
				"",
				msg
			)
			return
		end

		if fromLink then
			G_RLF:LogDebug(
				"Party item upgrades are apparently captured in CHAT_MSG_LOOT. TODO: may need to support this."
			)
			return
		end
		if itemLink then
			self:fn(self.ShowPartyLoot, self, msg, itemLink, unit)
		end
		return
	end

	if itemLink then
		self:fn(self.ShowItemLoot, self, msg, itemLink, fromLink)
	end
end

function ItemLoot:GROUP_ROSTER_UPDATE(eventName, ...)
	G_RLF:LogInfo(eventName, "WOWEVENT", self.moduleName, nil, eventName)

	self:SetNameUnitMap()
	self:SetPartyLootFilters()
end

return ItemLoot
