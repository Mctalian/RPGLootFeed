local Currency = G_RLF.RLF:NewModule("Currency", "AceEvent-3.0")

function Currency:OnInitialize()
	if G_RLF.db.global.currencyFeed then
		self:Enable()
	else
		self:Disable()
	end
end

function Currency:OnDisable()
	self:UnregisterEvent("CURRENCY_DISPLAY_UPDATE")
end

function Currency:OnEnable()
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
end

function Currency:CURRENCY_DISPLAY_UPDATE(eventName, ...)
	local currencyType, _quantity, quantityChange, _quantityGainSource, _quantityLostSource = ...

	self:getLogger():Info(eventName, "WOWEVENT", self.moduleName, currencyType, eventName, quantityChange)

	if currencyType == nil or not quantityChange or quantityChange <= 0 then
		self:getLogger():Debug(
			"Skip showing currency",
			G_RLF.addonName,
			self.moduleName,
			currencyType,
			"SKIP: Something was missing, don't display",
			quantityChange
		)
		return
	end

	local info = C_CurrencyInfo.GetCurrencyInfo(currencyType)
	if info == nil or info.description == "" or info.iconFileID == nil then
		self:getLogger():Debug(
			"Skip showing currency",
			G_RLF.addonName,
			self.moduleName,
			currencyType,
			"SKIP: Description or icon was empty",
			quantityChange
		)
		return
	end

	G_RLF:fn(function()
		G_RLF.LootDisplay:ShowLoot(
			"Currency",
			info.currencyID,
			C_CurrencyInfo.GetCurrencyLink(currencyType),
			info.iconFileID,
			quantityChange
		)
	end)
end

return Currency
