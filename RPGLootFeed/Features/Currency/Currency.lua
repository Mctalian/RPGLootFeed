---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

local C = LibStub("C_Everywhere")

---@class RLF_Currency: RLF_Module, AceEvent
local Currency = G_RLF.RLF:NewModule("Currency", "AceEvent-3.0")

Currency.Element = {}

function Currency.Element:new(...)
	---@class Currency.Element: RLF_LootElement
	local element = {}
	G_RLF.InitializeLootDisplayProperties(element)

	element.type = "Currency"
	element.IsEnabled = function()
		return Currency:IsEnabled()
	end

	element.isLink = true

	local currencyLink, currencyInfo, basicInfo = ...

	if not currencyLink or not currencyInfo or not basicInfo then
		return
	end

	element.key = currencyInfo.currencyID
	element.icon = currencyInfo.iconFileID
	element.quantity = basicInfo.displayAmount
	element.totalCount = currencyInfo.quantity
	element.quality = currencyInfo.quality
	element.totalEarned = currencyInfo.totalEarned
	element.cappedQuantity = currencyInfo.maxQuantity

	if element.key == Constants.CurrencyConsts.ACCOUNT_WIDE_HONOR_CURRENCY_ID then
		element.totalCount = UnitHonorLevel("player")
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
				numerator = element.totalCount
				percentage = element.totalCount / element.cappedQuantity
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
	if G_RLF.db.global.currency.enabled and GetExpansionLevel() >= G_RLF.Expansion.SL then
		self:Enable()
	else
		self:Disable()
	end
end

function Currency:OnDisable()
	if GetExpansionLevel() < G_RLF.Expansion.SL then
		return
	end
	self:UnregisterEvent("CURRENCY_DISPLAY_UPDATE")
	if G_RLF:IsRetail() then
		self:UnregisterEvent("PERKS_PROGRAM_CURRENCY_AWARDED")
		self:UnregisterEvent("PERKS_PROGRAM_CURRENCY_REFRESH")
	end
end

function Currency:OnEnable()
	if GetExpansionLevel() < G_RLF.Expansion.SL then
		return
	end
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
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
		local basicInfo = C.CurrencyInfo.GetBasicCurrencyInfo(currencyType, quantityChange)
		local e = self.Element:new(C.CurrencyInfo.GetCurrencyLink(currencyType), info, basicInfo)
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
