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

function Currency:CURRENCY_DISPLAY_UPDATE(_, ...)
	local currencyType, _quantity, quantityChange, _quantityGainSource, _quantityLostSource = ...

	if currencyType == nil or not quantityChange or quantityChange <= 0 then
		return
	end

	local info = C_CurrencyInfo.GetCurrencyInfo(currencyType)
	if info == nil or info.description == "" then
		return
	end

	G_RLF:fn(function()
		G_RLF.LootDisplay:ShowLoot(
			info.currencyID,
			C_CurrencyInfo.GetCurrencyLink(currencyType),
			info.iconFileID,
			quantityChange
		)
	end)
end

return Currency
