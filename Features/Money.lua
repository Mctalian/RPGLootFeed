local addonName, G_RLF = ...

local Money = G_RLF.RLF:NewModule("Money", "AceEvent-3.0")

Money.Element = {}

local startingMoney

function Money.Element:new(...)
	local element = {}
	G_RLF.InitializeLootDisplayProperties(element)

	element.type = "Money"
	element.IsEnabled = function()
		return Money:IsEnabled()
	end

	element.key = "MONEY_LOOT"
	element.quantity = ...
	if not element.quantity then
		return
	end
	element.textFn = function(existingCopper)
		local sign = ""
		local total = (existingCopper or 0) + element.quantity
		if total < 0 then
			sign = "-"
		end
		return sign .. C_CurrencyInfo.GetCoinTextureString(math.abs(total))
	end

	element.secondaryTextFn = function()
		local money = GetMoney()
		if money > 10000000 then
			money = math.floor(money / 10000) * 10000
		end
		return "    " .. C_CurrencyInfo.GetCoinTextureString(money)
	end

	return element
end

function Money:OnInitialize()
	if G_RLF.db.global.moneyFeed then
		self:Enable()
	else
		self:Disable()
	end
end

function Money:OnDisable()
	self:UnregisterEvent("PLAYER_MONEY")
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function Money:OnEnable()
	self:RegisterEvent("PLAYER_MONEY")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	startingMoney = GetMoney()
end

function Money:PLAYER_ENTERING_WORLD(eventName)
	self:getLogger():Info(eventName, "WOWEVENT", self.moduleName)
	startingMoney = GetMoney()
end

function Money:PLAYER_MONEY(eventName)
	self:getLogger():Info(eventName, "WOWEVENT", self.moduleName)
	self:fn(function()
		local newMoney = GetMoney()
		local amountInCopper = newMoney - startingMoney
		startingMoney = newMoney
		local e = self.Element:new(amountInCopper)
		e:Show()
	end)
end

return Money
