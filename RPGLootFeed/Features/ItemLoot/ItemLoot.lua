---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

---@class RLF_ItemLoot: RLF_Module, AceEvent
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
	info, element.quantity, fromLink = ...
	itemLink = info.itemLink

	element.key = info.itemLink
	if fromLink then
		element.key = "UPGRADE_" .. element.key
	end

	element.icon = info.itemTexture
	element.sellPrice = info.sellPrice

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
		local fontSize = G_RLF.db.global.styling.fontSize

		if fromLink ~= "" and fromLink ~= nil then
			local toItemLevel, fromItemLevel = getItemLevels(itemLink, fromLink)
			if toItemLevel == 0 or fromItemLevel == 0 then
				return ""
			end
			local atlasIconSize = fontSize * 1.5
			local atlasArrow = CreateAtlasMarkup("npe_arrowrightglow", atlasIconSize, atlasIconSize, 0, 0)
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
				str = str .. CreateAtlasMarkup(atlasIcon, atlasIconSize, atlasIconSize, 0, 0) .. "  "
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
		elseif self.isLegendary and soundsConfig.legendaries.enabled and soundsConfig.legendaries.sound ~= "" then
			local willPlay, handle = PlaySoundFile(soundsConfig.legendaries.sound)
			if not willPlay then
				G_RLF:LogWarn("Failed to play sound " .. soundsConfig.legendaries.sound, addonName, ItemLoot.moduleName)
			else
				G_RLF:LogDebug(
					"Sound queued to play " .. soundsConfig.legendaries.sound .. " " .. handle,
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
		self.highlight = self.isMount or self.isLegendary or self.isBetterThanEquipped
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
end

function ItemLoot:OnItemReadyToShow(info, amount, fromLink)
	self.pendingItemRequests[info.itemId] = nil
	local e = ItemLoot.Element:new(info, amount, fromLink)
	e:SetHighlight()
	e:Show(info.itemName, info.itemQuality)
	e:PlaySoundIfEnabled()
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

	-- Only process our own loot now, party loot is handled by PartyLoot module
	if not me then
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
