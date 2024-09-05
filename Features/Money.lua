local Money = G_RLF.RLF:NewModule("Money", "AceEvent-3.0")

local startingMoney

function Money:OnInitialize()
	if G_RLF.db.global.moneyFeed then
		self:Enable()
	else
		self:Disable()
	end
end

function Money:OnDisable()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:UnregisterEvent("PLAYER_MONEY")
end

function Money:OnEnable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_MONEY")
	startingMoney = GetMoney()
end

function Money:PLAYER_ENTERING_WORLD(eventName)
	-- Get current money to calculate the delta later
	self:getLogger():Info(eventName, "WOWEVENT", self.moduleName)
	startingMoney = GetMoney()
end

function Money:PLAYER_MONEY(eventName)
	self:getLogger():Info(eventName, "WOWEVENT", self.moduleName)
	self:fn(function()
		local newMoney = GetMoney()
		local amountInCopper = newMoney - startingMoney
		startingMoney = newMoney
		G_RLF.LootDisplay:ShowLoot("Money", amountInCopper)
	end)
end

return Money
