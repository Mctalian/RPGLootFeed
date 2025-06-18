---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

---@class RLF_ItemLoot: RLF_Module, AceEvent-3.0, AceBucket-3.0
local ItemLoot = G_RLF.RLF:NewModule(G_RLF.FeatureModule.ItemLoot, "AceEvent-3.0", "AceBucket-3.0")

local C = LibStub("C_Everywhere")

ItemLoot.Element = {}

local ItemInfo = G_RLF.ItemInfo
local TertiaryStats = G_RLF.TertiaryStats

local SocketFDIDMap = {
	["EMPTY_SOCKET_BLUE"] = 136256,
	["EMPTY_SOCKET_META"] = 136257,
	["EMPTY_SOCKET_RED"] = 136258,
	["EMPTY_SOCKET_YELLOW"] = 136259,
	["EMPTY_SOCKET_NO_COLOR"] = 458977,
	["EMPTY_SOCKET_HYDRAULIC"] = 407325,
	["EMPTY_SOCKET_COGWHEEL"] = 407324,
	["EMPTY_SOCKET_PRISMATIC"] = 458977,
	["EMPTY_SOCKET_PUNCHCARDRED"] = 2958630,
	["EMPTY_SOCKET_PUNCHCARDYELLOW"] = 2958631,
	["EMPTY_SOCKET_PUNCHCARDBLUE"] = 2958629,
	["EMPTY_SOCKET_DOMINATION"] = 4095404,
	["EMPTY_SOCKET_CYPHER"] = 407324,
	["EMPTY_SOCKET_TINKER"] = 2958630,
	["EMPTY_SOCKET_PRIMORDIAL"] = 407324,
	["EMPTY_SOCKET_FRAGRANCE"] = 407324,
	["EMPTY_SOCKET_SINGING_THUNDER"] = 2958631,
	["EMPTY_SOCKET_SINGING_SEA"] = 2958629,
	["EMPTY_SOCKET_SINGING_WIND"] = 2958630,
	["EMPTY_SOCKET_SINGINGTHUNDER"] = 2958631,
	["EMPTY_SOCKET_SINGINGSEA"] = 2958629,
	["EMPTY_SOCKET_SINGINGWIND"] = 2958630,
}

local TertiaryStatMap = {
	["ITEM_MOD_CR_SPEED_SHORT"] = TertiaryStats.Speed,
	["ITEM_MOD_CR_LIFESTEAL_SHORT"] = TertiaryStats.Leech,
	["ITEM_MOD_CR_AVOIDANCE_SHORT"] = TertiaryStats.Avoid,
}
local IndestructibleMap = {
	["ITEM_MOD_CR_STURDINESS_SHORT"] = TertiaryStats.Indestructible,
}

--- Convert params into a string with an icon and price
--- @param icon string
--- @param fontSize number
--- @param price number
--- @return string
local function getPriceString(icon, fontSize, price)
	if not icon or not fontSize or not price then
		return ""
	end
	local sizeCoeff = G_RLF.AtlasIconCoefficients[icon] or 1
	local atlasIconSize = fontSize * sizeCoeff
	return CreateAtlasMarkup(icon, atlasIconSize, atlasIconSize, 0, 0)
		.. " "
		.. C_CurrencyInfo.GetCoinTextureString(price)
end

function ItemLoot:ItemQualityName(enumValue)
	for k, v in pairs(Enum.ItemQuality) do
		if v == enumValue then
			return k
		end
	end
	return nil
end

local function IsMount(info)
	return info:IsMount()
end

local function IsLegendary(info)
	return info:IsLegendary()
end

---@class RLF_ItemRolls
---@field tertiaryStat G_RLF.TertiaryStats
---@field socketString string
---@field isSocketed boolean
---@field isIndestructible boolean

--- Get the tertiary stat and socket string for an item
--- @param info RLF_ItemInfo
--- @return RLF_ItemRolls
local function getItemStats(info)
	local itemRolls = {
		isIndestructible = false,
		tertiaryStat = TertiaryStats.None,
		isSocketed = false,
		socketString = "",
	}
	local stats = C.Item.GetItemStats(info.itemLink)
	if not stats then
		return itemRolls
	end

	for k, v in pairs(stats) do
		if k:find("ITEM_MOD_CR_") and v > 0 then
			if TertiaryStatMap[k] then
				itemRolls.tertiaryStat = TertiaryStatMap[k]
			elseif IndestructibleMap[k] then
				itemRolls.isIndestructible = true
			else
				G_RLF:LogWarn("Unknown tertiary stat: " .. k, addonName, ItemLoot.moduleName)
			end
		end

		if k:find("EMPTY_SOCKET_") and v > 0 then
			if SocketFDIDMap[k] then
				itemRolls.isSocketed = true
				itemRolls.socketString = "|T" .. SocketFDIDMap[k] .. ":0|t"
			else
				G_RLF:LogWarn("Unknown socket type: " .. k, addonName, ItemLoot.moduleName)
			end
		end
	end

	return itemRolls
end

local function IsBetterThanEquipped(info)
	if info:IsEligibleEquipment() then
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
			return false
		end

		local equippedId = C.Item.GetItemIDForItemInfo(equippedLink)
		local equippedInfo = ItemInfo:new(equippedId, C.Item.GetItemInfo(equippedLink))
		if not equippedInfo then
			return false
		end

		if equippedInfo.itemQuality > G_RLF.ItemQualEnum.Poor and info.itemQuality == G_RLF.ItemQualEnum.Poor then
			-- If the equipped item is better than poor and the new item is poor, we don't consider it an upgrade
			return false
		end
		if equippedInfo.itemQuality > G_RLF.ItemQualEnum.Common and info.itemQuality == G_RLF.ItemQualEnum.Common then
			-- If the equipped item is better than common and the new item is common, we don't consider it an upgrade
			return false
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

	return false
end

--- Return true if it has a tertiary stat or a socket
--- @param stats RLF_ItemRolls
local function HasItemRollBonus(stats)
	return stats.tertiaryStat ~= TertiaryStats.None or stats.isSocketed or stats.isIndestructible
end

local function isKeystoneLink(link)
	local start, stop = link:find("|Hkeystone:")
	if start and stop then
		return true
	end
	return false
end

local function GetKeystoneLevels(toLink, fromLink)
	-- split each link by the ":" character
	local toLinkParts = { strsplit(":", toLink) }
	local fromLinkParts = { strsplit(":", fromLink) }
	local levelIndex = 4
	local toLevel = tonumber(toLinkParts[levelIndex])
	local fromLevel = tonumber(fromLinkParts[levelIndex])
	if toLevel and fromLevel then
		return toLevel, fromLevel
	end
	return 0, 0
end

local function getItemLevels(toLink, fromLink)
	if isKeystoneLink(toLink) and isKeystoneLink(fromLink) then
		return GetKeystoneLevels(toLink, fromLink)
	end
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

---@param info RLF_ItemInfo
---@param quantity number
---@param fromLink? string
function ItemLoot.Element:new(info, quantity, fromLink)
	---@class ItemLoot.Element: RLF_BaseLootElement
	local element = {}
	G_RLF.InitializeLootDisplayProperties(element)

	element.type = "ItemLoot"
	element.IsEnabled = function()
		return ItemLoot:IsEnabled()
	end

	element.isLink = true
	element.quantity = quantity

	local itemLink = info.itemLink

	element.key = info.itemLink
	if fromLink then
		element.key = "UPGRADE_" .. element.key
	end

	element.icon = info.itemTexture
	element.sellPrice = info.sellPrice
	local itemQualitySettings = G_RLF.db.global.item.itemQualitySettings[info.itemQuality]
	if itemQualitySettings and itemQualitySettings.enabled and itemQualitySettings.duration > 0 then
		element.showForSeconds = itemQualitySettings.duration
	end
	local fromInfo = nil
	element.isKeystone = info.keystoneInfo ~= nil
	if element.isKeystone then
		-- Force icon to be the item texture, not using the link
		element.quality = G_RLF.ItemQualEnum.Epic
		if fromLink then
			fromInfo = ItemInfo:new(C.Item.GetItemIDForItemInfo(fromLink), C.Item.GetItemInfo(fromLink))
		end
	end

	element.itemCount = C.Item.GetItemCount(info.itemLink, true, false, true, true)

	local stats = getItemStats(info)

	element.topLeftText = nil
	element.topLeftColor = nil
	if info:IsEquippableItem() and info.itemQuality > G_RLF.ItemQualEnum.Poor then
		element.topLeftText = tostring(info.itemLevel)
		local r, g, b = C_Item.GetItemQualityColor(info.itemQuality)
		element.topLeftColor = { r, g, b }
	end

	function element:isPassingFilter(itemName, itemQuality)
		if not G_RLF.db.global.item.itemQualitySettings[itemQuality].enabled then
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
		local stylingDb = G_RLF.DbAccessor:Styling(G_RLF.Frames.MAIN)
		local secondaryFontSize = stylingDb.secondaryFontSize

		if element.isKeystone and fromInfo then
			local toItemLevel, fromItemLevel = getItemLevels(info.itemLink, fromInfo.itemLink)
			if toItemLevel ~= 0 and fromItemLevel ~= 0 then
				local fromStr = G_RLF:RGBAToHexFormat(1, 1, 1, 1) .. fromItemLevel .. "|r"
				local toStr
				if toItemLevel > fromItemLevel then
					toStr = G_RLF:RGBAToHexFormat(0.12, 1.0, 0, 1) .. toItemLevel .. "|r"
				else
					toStr = G_RLF:RGBAToHexFormat(1.0, 0.12, 0.12, 1) .. toItemLevel .. "|r"
				end
				local atlasIcon = "npe_arrowrightglow"
				local sizeCoeff = G_RLF.AtlasIconCoefficients[atlasIcon] or 1
				local atlasIconSize = secondaryFontSize * sizeCoeff
				local atlasArrow = CreateAtlasMarkup(atlasIcon, atlasIconSize, atlasIconSize, 0, 0)
				return "    " .. fromStr .. " " .. atlasArrow .. " " .. toStr
			end
		end

		if fromLink ~= "" and fromLink ~= nil then
			local toItemLevel, fromItemLevel = getItemLevels(itemLink, fromLink)
			if toItemLevel == 0 or fromItemLevel == 0 then
				return ""
			end
			local fromStr = G_RLF:RGBAToHexFormat(1, 1, 1, 1) .. fromItemLevel .. "|r"
			local toStr
			if toItemLevel > fromItemLevel then
				toStr = G_RLF:RGBAToHexFormat(0.12, 1.0, 0, 1) .. toItemLevel .. "|r"
			else
				toStr = G_RLF:RGBAToHexFormat(1.0, 0.12, 0.12, 1) .. toItemLevel .. "|r"
			end
			local atlasIcon = "npe_arrowrightglow"
			local sizeCoeff = G_RLF.AtlasIconCoefficients[atlasIcon] or 1
			local atlasIconSize = secondaryFontSize * sizeCoeff
			local atlasArrow = CreateAtlasMarkup(atlasIcon, atlasIconSize, atlasIconSize, 0, 0)
			return "    " .. fromStr .. " " .. atlasArrow .. " " .. toStr
		end

		if info:IsEligibleEquipment() then
			local secondaryText = ""
			if HasItemRollBonus(stats) then
				if stats.isSocketed then
					secondaryText = string.format(
						"%s%s%s %s|r ",
						G_RLF:RGBAToHexFormat(0.95, 0.90, 0.60, 1),
						secondaryText,
						stats.socketString,
						G_RLF.L["Socket"]
					)
				end
				if stats.tertiaryStat ~= TertiaryStats.None then
					secondaryText = string.format(
						"%s%s%s|r ",
						G_RLF:RGBAToHexFormat(0.00, 0.55, 0.50, 1),
						secondaryText,
						G_RLF.tertiaryToString[stats.tertiaryStat]
					)
				end
				if stats.isIndestructible then
					secondaryText = string.format(
						"%s%s%s|r",
						G_RLF:RGBAToHexFormat(0.80, 0.60, 0.00, 1),
						secondaryText,
						G_RLF.tertiaryToString[TertiaryStats.Indestructible]
					)
				end
				return secondaryText
			end
		end

		local quantity = ...
		local effectiveQuantity = quantity or 1
		local vendorIcon = G_RLF.db.global.item.vendorIconTexture
		local auctionIcon = G_RLF.db.global.item.auctionHouseIconTexture
		local vendorPrice, auctionPrice = 0, 0
		local pricesForSellableItems = G_RLF.db.global.item.pricesForSellableItems
		if element.sellPrice and element.sellPrice > 0 then
			vendorPrice = element.sellPrice
		end
		local marketPrice = G_RLF.AuctionIntegrations.activeIntegration:GetAHPrice(itemLink)
		if marketPrice and marketPrice > 0 then
			auctionPrice = marketPrice
		end
		local showVendorPrice = vendorPrice > 0
		local showAuctionPrice = auctionPrice > 0
		local str = ""
		if pricesForSellableItems == G_RLF.PricesEnum.Vendor and showVendorPrice then
			str = str .. getPriceString(vendorIcon, secondaryFontSize, vendorPrice * effectiveQuantity)
		elseif pricesForSellableItems == G_RLF.PricesEnum.AH and showAuctionPrice then
			str = str .. getPriceString(auctionIcon, secondaryFontSize, auctionPrice * effectiveQuantity)
		elseif pricesForSellableItems == G_RLF.PricesEnum.VendorAH then
			if showVendorPrice then
				str = str .. getPriceString(vendorIcon, secondaryFontSize, vendorPrice * effectiveQuantity) .. "    "
			end
			if showAuctionPrice then
				str = str .. getPriceString(auctionIcon, secondaryFontSize, auctionPrice * effectiveQuantity)
			end
		elseif pricesForSellableItems == G_RLF.PricesEnum.AHVendor then
			if showAuctionPrice then
				str = str .. getPriceString(auctionIcon, secondaryFontSize, auctionPrice * effectiveQuantity) .. "    "
			end
			if showVendorPrice then
				str = str .. getPriceString(vendorIcon, secondaryFontSize, vendorPrice * effectiveQuantity)
			end
		elseif pricesForSellableItems == G_RLF.PricesEnum.Highest then
			if auctionPrice > vendorPrice then
				str = str .. getPriceString(auctionIcon, secondaryFontSize, auctionPrice * effectiveQuantity)
			elseif showVendorPrice then
				str = str .. getPriceString(vendorIcon, secondaryFontSize, vendorPrice * effectiveQuantity)
			end
		end

		return str
	end

	element.isMount = IsMount(info)
	element.isLegendary = IsLegendary(info)
	element.isBetterThanEquipped = IsBetterThanEquipped(info)
	element.hasTertiaryOrSocket = HasItemRollBonus(stats)
	function element:PlaySoundIfEnabled()
		local soundsConfig = G_RLF.db.global.item.sounds
		if self.isMount and soundsConfig.mounts.enabled and soundsConfig.mounts.sound ~= "" then
			local willPlay, handle = PlaySoundFile(soundsConfig.mounts.sound)
			if not willPlay then
				G_RLF:LogWarn("Failed to play sound " .. soundsConfig.mounts.sound, addonName, ItemLoot.moduleName)
			else
				G_RLF:LogDebug(
					"Sound queued to play " .. soundsConfig.mounts.sound .. " " .. handle,
					addonName,
					ItemLoot.moduleName
				)
			end
		elseif self.isLegendary and soundsConfig.legendary.enabled and soundsConfig.legendary.sound ~= "" then
			local willPlay, handle = PlaySoundFile(soundsConfig.legendary.sound)
			if not willPlay then
				G_RLF:LogWarn("Failed to play sound " .. soundsConfig.legendary.sound, addonName, ItemLoot.moduleName)
			else
				G_RLF:LogDebug(
					"Sound queued to play " .. soundsConfig.legendary.sound .. " " .. handle,
					addonName,
					ItemLoot.moduleName
				)
			end
		elseif
			self.isBetterThanEquipped
			and soundsConfig.betterThanEquipped.enabled
			and soundsConfig.betterThanEquipped.sound ~= ""
		then
			local willPlay, handle = PlaySoundFile(soundsConfig.betterThanEquipped.sound)
			if not willPlay then
				G_RLF:LogWarn(
					"Failed to play sound " .. soundsConfig.betterThanEquipped.sound,
					addonName,
					ItemLoot.moduleName
				)
			else
				G_RLF:LogDebug(
					"Sound queued to play " .. soundsConfig.betterThanEquipped.sound .. " " .. handle,
					addonName,
					ItemLoot.moduleName
				)
			end
		end
	end

	function element:SetHighlight()
		local itemHighlights = G_RLF.db.global.item.itemHighlights
		self.highlight = (self.isMount and itemHighlights.mounts)
			or (self.isLegendary and itemHighlights.legendary)
			or (self.isBetterThanEquipped and itemHighlights.betterThanEquipped)
			or (self.hasTertiaryOrSocket and itemHighlights.tertiaryOrSocket)
	end

	return element
end

function ItemLoot:OnInitialize()
	self.pendingItemRequests = {}
	if G_RLF.db.global.item.enabled then
		self:Enable()
	else
		self:Disable()
	end
end

function ItemLoot:OnDisable()
	self:UnregisterEvent("CHAT_MSG_LOOT")
	self:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
end

function ItemLoot:OnEnable()
	self:RegisterEvent("CHAT_MSG_LOOT")
	self:RegisterEvent("GET_ITEM_INFO_RECEIVED")
	G_RLF:LogDebug("OnEnable", addonName, self.moduleName)
	if GetExpansionLevel() == G_RLF.Expansion.CATA then
		self:SetEquippableArmorClass()
	end
end

function ItemLoot:SetEquippableArmorClass()
	local _, playerClass = UnitClass("player")

	if
		playerClass == "ROGUE"
		or playerClass == "DRUID"
		or playerClass == "PRIEST"
		or playerClass == "MAGE"
		or playerClass == "WARLOCK"
	then
		return
	end

	local playerLevel = UnitLevel("player")
	if playerLevel < 40 then
		if not self.armorLevelListener then
			self.armorLevelListener = self:RegisterBucketEvent("PLAYER_LEVEL_UP", 1, "SetEquippableArmorClass")
		end
		G_RLF.armorClassMapping = G_RLF.cataArmorClassMappingLowLevel
		return
	end

	if self.armorLevelListener then
		self:UnregisterBucket(self.armorLevelListener)
		self.armorLevelListener = nil
	end

	G_RLF.armorClassMapping = G_RLF.standardArmorClassMapping
end

---@param info RLF_ItemInfo
---@param amount number
---@param fromLink? string
function ItemLoot:OnItemReadyToShow(info, amount, fromLink)
	self.pendingItemRequests[info.itemId] = nil
	local e = ItemLoot.Element:new(info, amount, fromLink)
	e:SetHighlight()
	e:Show(info.itemName, info.itemQuality)
	e:PlaySoundIfEnabled()
end

function ItemLoot:GET_ITEM_INFO_RECEIVED(eventName, itemID, success)
	G_RLF:LogInfo(eventName, "WOWEVENT", self.moduleName, nil, eventName .. " " .. itemID)
	if self.pendingItemRequests[itemID] then
		local itemLink, amount, fromLink = unpack(self.pendingItemRequests[itemID])

		if not success then
			error("Failed to load item: " .. itemID .. " " .. itemLink .. " x" .. amount)
		else
			local info = ItemInfo:new(itemID, C.Item.GetItemInfo(itemLink))
			if info == nil then
				G_RLF:LogDebug("ItemInfo is nil for " .. itemLink, addonName, self.moduleName)
				return
			end
			self:OnItemReadyToShow(info, amount, fromLink)
		end
	end
end

function ItemLoot:ShowItemLoot(msg, itemLink, fromLink)
	local amount = tonumber(msg:match("r ?x(%d+)") or 1) or 1
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
	for itemLink in message:gmatch("|c.-|Hitem:.-|h%[.-%]|h|r") do
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
	-- So far, MoP Classic and below doesn't work with GetPlayerGuid()
	else
		me = playerName2 == UnitName("player")
	end

	-- Only process our own loot now, party loot is handled by PartyLoot module
	if not me then
		G_RLF:LogDebug("Loot ignored, not me", "WOWEVENT", self.moduleName, "", msg)
		return
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

	if itemLink then
		self:fn(self.ShowItemLoot, self, msg, itemLink, fromLink)
	end
end

return ItemLoot
