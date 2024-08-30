local Money = G_RLF.RLF:NewModule("Money", "AceEvent-3.0")

local oldMethod
local startingMoney

function Money:OnInitialize()
	if G_RLF.db.global.moneyFeed then
		self:Enable()
	else
		self:Disable()
	end
end

function Money:OnDisable()
	self:UnregisterEvent("LOOT_READY")
	self:UnregisterEvent("CHAT_MSG_MONEY")
end

function Money:OnEnable()
	self:RegisterEvent("LOOT_READY")
	self:RegisterEvent("CHAT_MSG_MONEY")
end

function Money:LOOT_READY()
	-- Get current money to calculate the delta later
	startingMoney = GetMoney()
end

local function showMoneyLoot(msg)
	local amountInCopper
	if startingMoney == nil then
		-- Old method that doesn't work well with locales that are missing translation
		amountInCopper = oldMethod(msg)
	else
		amountInCopper = GetMoney() - startingMoney
	end
	startingMoney = GetMoney()
	G_RLF.LootDisplay:ShowMoney(amountInCopper)
end

function Money:CHAT_MSG_MONEY(_, msg)
	G_RLF:fn(showMoneyLoot, msg)
end

oldMethod = function(msg)
	-- Initialize default values
	local gold, silver, copper = 0, 0, 0

	-- Patterns to match optional sections
	local goldPattern = "(%d+) " .. G_RLF.L["Gold"]
	local silverPattern = "(%d+) " .. G_RLF.L["Silver"]
	local copperPattern = "(%d+) " .. G_RLF.L["Copper"]

	-- Find and convert matches to numbers if they exist
	gold = tonumber(msg:match(goldPattern)) or gold
	silver = tonumber(msg:match(silverPattern)) or silver
	copper = tonumber(msg:match(copperPattern)) or copper

	local amountInCopper = (gold * 100 * 100)
	amountInCopper = amountInCopper + (silver * 100)
	amountInCopper = amountInCopper + copper

	return amountInCopper
end

return Money
