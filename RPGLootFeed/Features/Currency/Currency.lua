---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

local C = LibStub("C_Everywhere")

---@class RLF_Currency: RLF_Module, AceEvent-3.0
local Currency = G_RLF.RLF:NewModule("Currency", "AceEvent-3.0")

Currency.Element = {}

--- @param currencyLink string
--- @param currencyInfo CurrencyInfo
--- @param basicInfo CurrencyDisplayInfo
function Currency.Element:new(currencyLink, currencyInfo, basicInfo)
	---@class Currency.Element: RLF_BaseLootElement
	local element = {}
	G_RLF.InitializeLootDisplayProperties(element)

	element.type = "Currency"
	element.IsEnabled = function()
		return Currency:IsEnabled()
	end

	element.isLink = true

	if not currencyLink or not currencyInfo or not basicInfo then
		return
	end

	element.key = "CURRENCY_" .. currencyInfo.currencyID
	element.icon = currencyInfo.iconFileID
	element.quantity = basicInfo.displayAmount
	element.itemCount = currencyInfo.quantity
	element.quality = currencyInfo.quality
	element.totalEarned = currencyInfo.totalEarned
	element.cappedQuantity = currencyInfo.maxQuantity

	if element.key == Constants.CurrencyConsts.ACCOUNT_WIDE_HONOR_CURRENCY_ID then
		element.itemCount = UnitHonorLevel("player")
		element.cappedQuantity = UnitHonorMax("player")
		element.totalEarned = UnitHonor("player")
		---@diagnostic disable-next-line: undefined-field
		currencyLink = currencyLink:gsub(currencyInfo.name, _G.LIFETIME_HONOR)
	end

	element.textFn = function(existingQuantity, truncatedLink)
		if not truncatedLink then
			return currencyLink
		end
		return truncatedLink .. " x" .. ((existingQuantity or 0) + element.quantity)
	end

	element.secondaryTextFn = function(...)
		if element.cappedQuantity and element.cappedQuantity > 0 then
			local percentage, numerator
			if element.totalEarned > 0 then
				numerator = element.totalEarned
				percentage = element.totalEarned / element.cappedQuantity
			else
				numerator = element.itemCount
				percentage = element.itemCount / element.cappedQuantity
			end
			local currencyDb = G_RLF.db.global.currency
			local lowThreshold = currencyDb.lowerThreshold
			local upperThreshold = currencyDb.upperThreshold
			local lowestColor = currencyDb.lowestColor
			local midColor = currencyDb.midColor
			local upperColor = currencyDb.upperColor
			local color = G_RLF:RGBAToHexFormat(unpack(lowestColor))
			if element.key ~= Constants.CurrencyConsts.ACCOUNT_WIDE_HONOR_CURRENCY_ID then
				if percentage < lowThreshold then
					color = G_RLF:RGBAToHexFormat(unpack(lowestColor))
				elseif percentage >= lowThreshold and percentage < upperThreshold then
					color = G_RLF:RGBAToHexFormat(unpack(midColor))
				else
					color = G_RLF:RGBAToHexFormat(unpack(upperColor))
				end
			end

			return "    " .. color .. numerator .. " / " .. element.cappedQuantity .. "|r"
		end

		return ""
	end

	return element
end

local function isHiddenCurrency(id)
	return G_RLF.hiddenCurrencies[id] == true
end

function Currency:OnInitialize()
	if G_RLF.db.global.currency.enabled and GetExpansionLevel() >= G_RLF.Expansion.WOTLK then
		self:Enable()
	else
		self:Disable()
	end
end

function Currency:OnDisable()
	if GetExpansionLevel() < G_RLF.Expansion.WOTLK then
		G_RLF:LogDebug("OnEnable", addonName, self.moduleName, "Disabled because expansion is below WOTLK")
		return
	end
	if GetExpansionLevel() < G_RLF.Expansion.BFA then
		self:UnregisterEvent("CHAT_MSG_CURRENCY")
	else
		self:UnregisterEvent("CURRENCY_DISPLAY_UPDATE")
	end
	if G_RLF:IsRetail() then
		self:UnregisterEvent("PERKS_PROGRAM_CURRENCY_AWARDED")
		self:UnregisterEvent("PERKS_PROGRAM_CURRENCY_REFRESH")
	end
end

function Currency:OnEnable()
	if GetExpansionLevel() < G_RLF.Expansion.WOTLK then
		G_RLF:LogDebug("OnEnable", addonName, self.moduleName, "Disabled because expansion is below WOTLK")
		return
	end
	if GetExpansionLevel() < G_RLF.Expansion.BFA then
		self:RegisterEvent("CHAT_MSG_CURRENCY")
	else
		self:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
	end
	if G_RLF:IsRetail() then
		self:RegisterEvent("PERKS_PROGRAM_CURRENCY_AWARDED")
	end
	G_RLF:LogDebug("OnEnable", addonName, self.moduleName)
end

function Currency:Process(eventName, currencyType, quantityChange)
	G_RLF:LogInfo(eventName, "WOWEVENT", self.moduleName, currencyType, eventName, quantityChange)

	if currencyType == nil or not quantityChange or quantityChange <= 0 then
		G_RLF:LogDebug(
			"Skip showing currency",
			addonName,
			self.moduleName,
			currencyType,
			"SKIP: Something was missing, don't display",
			quantityChange
		)
		return
	end

	if isHiddenCurrency(currencyType) then
		G_RLF:LogDebug(
			"Skip showing currency",
			addonName,
			self.moduleName,
			currencyType,
			"SKIP: This is a known hidden currencyType",
			quantityChange
		)
		return
	end

	---@type CurrencyInfo
	local info = C.CurrencyInfo.GetCurrencyInfo(currencyType)
	if info == nil or info.description == "" or info.iconFileID == nil then
		G_RLF:LogDebug(
			"Skip showing currency",
			addonName,
			self.moduleName,
			currencyType,
			"SKIP: Description or icon was empty",
			quantityChange
		)
		return
	end

	self:fn(function()
		---@type CurrencyDisplayInfo
		local basicInfo = C.CurrencyInfo.GetBasicCurrencyInfo(currencyType, quantityChange)
		local link
		if C_CurrencyInfo.GetCurrencyLink then
			link = C.CurrencyInfo.GetCurrencyLink(currencyType)
		else
			-- Fallback for pre-SL clients
			link = GetCurrencyLink(currencyType, quantityChange)
		end
		local e = self.Element:new(link, info, basicInfo)
		if e then
			e:Show()
		else
			G_RLF:LogDebug(
				"Skip showing currency",
				addonName,
				self.moduleName,
				currencyType,
				"SKIP: Element was nil",
				quantityChange
			)
		end
	end)
end

function Currency:CURRENCY_DISPLAY_UPDATE(eventName, ...)
	local currencyType, _quantity, quantityChange, _quantityGainSource, _quantityLostSource = ...

	self:Process(eventName, currencyType, quantityChange)
end

function Currency:CHAT_MSG_CURRENCY(eventName, ...)
	local msg = ...
	G_RLF:LogInfo(eventName, "WOWEVENT", self.moduleName, nil, msg)

	local itemLinks = G_RLF:ExtractItemLinks(msg)
	local isItem = true
	if not itemLinks or #itemLinks == 0 then
		itemLinks = G_RLF:ExtractCurrencyLinks(msg)
		isItem = false
	end

	if isItem then
		G_RLF:LogDebug(
			"Currency message contains an item link",
			addonName,
			self.moduleName,
			nil,
			"Item links found in message"
		)
	end

	if not itemLinks or #itemLinks == 0 then
		G_RLF:LogDebug(
			"Skip showing currency",
			addonName,
			self.moduleName,
			nil,
			"SKIP: No item or currency links found in message",
			msg
		)
		return
	end

	local itemLink = itemLinks[1]
	local amount = tonumber(msg:match("r ?x(%d+)") or 1) or 1
	local currencyInfo, basicInfo
	if isItem then
		local itemId = C.Item.GetItemIDForItemInfo(itemLink)
		if not itemId then
			G_RLF:LogDebug(
				"Skip showing currency",
				addonName,
				self.moduleName,
				nil,
				"SKIP: No item ID found for item link = " .. tostring(itemLink)
			)
			return
		end

		local info = G_RLF.ItemInfo:new(itemId, C.Item.GetItemInfo(itemLink))
		if not info then
			G_RLF:LogDebug(
				"Skip showing currency",
				addonName,
				self.moduleName,
				nil,
				"SKIP: No item info found for item link = " .. tostring(itemLink)
			)
			return
		end

		local total = C.Item.GetItemCount(info.itemLink, true, false, true, true)

		---@type CurrencyInfo
		currencyInfo = {
			name = info.itemName,
			description = "",
			currencyID = info.itemId,
			---@diagnostic disable-next-line: assign-type-mismatch
			iconFileID = info.itemTexture,
			quantity = amount,
			quality = info.itemQuality or G_RLF.ItemQualEnum.Common,
			totalEarned = total,
			isHeader = false,
			isHeaderExpanded = false,
			isAccountTransferable = false,
			isAccountWide = false,
			currencyListDepth = 0,
			isTypeUnused = false,
			isShowInBackpack = false,
			rechargingAmountPerCycle = 0,
			rechargingCycleDurationMS = 0,
			maxQuantity = 0,
			trackedQuantity = 0,
			canEarnPerWeek = true,
			quantityEarnedThisWeek = 0,
			isTradeable = false,
			maxWeeklyQuantity = 0,
			discovered = true,
			useTotalEarnedForMaxQty = false,
		}
		---@type CurrencyDisplayInfo
		basicInfo = {
			name = info.itemName,
			displayAmount = amount,
			description = "",
			---@diagnostic disable-next-line: assign-type-mismatch
			icon = info.itemTexture,
			quality = info.itemQuality or G_RLF.ItemQualEnum.Common,
			actualAmount = amount,
		}
	else
		currencyInfo = C_CurrencyInfo.GetCurrencyInfoFromLink(itemLink)
		if not currencyInfo then
			G_RLF:LogDebug(
				"Skip showing currency",
				addonName,
				self.moduleName,
				nil,
				"SKIP: No currency info found for currency link = " .. tostring(itemLink)
			)
			return
		end

		if currencyInfo.quantity == 0 then
			currencyInfo.quantity = amount
		end

		if currencyInfo.currencyID == 0 then
			local currencyId = G_RLF:ExtractCurrencyID(itemLink)
			if currencyId == 0 or currencyId == nil then
				G_RLF:LogDebug(
					"Skip showing currency",
					addonName,
					self.moduleName,
					nil,
					"SKIP: No currency ID found for currency link = " .. tostring(itemLink)
				)
				return
			end
			currencyInfo.currencyID = currencyId
		end

		basicInfo = C_CurrencyInfo.GetBasicCurrencyInfo(currencyInfo.currencyID, amount)
		if not basicInfo then
			basicInfo = {
				displayAmount = amount,
			}
		end
	end

	local e = self.Element:new(itemLink, currencyInfo, basicInfo)
	if e then
		e:Show()
	else
		G_RLF:LogDebug("Skip showing currency", addonName, self.moduleName, nil, "SKIP: Element was nil")
	end
end

function Currency:PERKS_PROGRAM_CURRENCY_AWARDED(eventName, quantityChange)
	self:RegisterEvent("PERKS_PROGRAM_CURRENCY_REFRESH")
	local currencyType = Constants.CurrencyConsts.CURRENCY_ID_PERKS_PROGRAM_DISPLAY_INFO
	G_RLF:LogInfo(eventName, "WOWEVENT", self.moduleName, tostring(currencyType), eventName, quantityChange)
	self:UnregisterEvent("PERKS_PROGRAM_CURRENCY_AWARDED")
end

function Currency:PERKS_PROGRAM_CURRENCY_REFRESH(eventName, oldQuantity, newQuantity)
	local currencyType = Constants.CurrencyConsts.CURRENCY_ID_PERKS_PROGRAM_DISPLAY_INFO

	local quantityChange = newQuantity - oldQuantity
	if quantityChange == 0 then
		return
	end
	self:Process(eventName, currencyType, quantityChange)
end

return Currency
