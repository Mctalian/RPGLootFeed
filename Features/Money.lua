local addonName, ns = ...

local Money = G_RLF.RLF:NewModule("Money", "AceEvent-3.0")

Money.Element = {}

function Money.Element:new(...)
	ns.InitializeLootDisplayProperties(self)

	self.type = "Money"
	self.IsEnabled = function()
		return Money:IsEnabled()
	end

	self.key = "MONEY_LOOT"
	self.quantity = ...
	if not self.quantity then
		return
	end
	self.textFn = function(existingCopper)
		local sign = ""
		local total = (existingCopper or 0) + self.quantity
		if total < 0 then
			sign = "-"
		end
		return sign .. C_CurrencyInfo.GetCoinTextureString(math.abs(total))
	end

	return self
end

local startingMoney

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
