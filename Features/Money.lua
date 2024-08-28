local Money = {}

function Money:Snapshot()
	-- Get current money to calculate the delta later
	self.startingMoney = GetMoney()
end

function Money:OnMoneyLooted(msg)
	if not G_RLF.db.global.moneyFeed then
		return
	end

	local amountInCopper
	-- Old method that doesn't work well with other locales
	if self.startingMoney == nil then
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

		amountInCopper = (gold * 100 * 100)
		amountInCopper = amountInCopper + (silver * 100)
		amountInCopper = amountInCopper + copper
	else
		amountInCopper = GetMoney() - self.startingMoney
		self.startingMoney = GetMoney()
	end
	G_RLF.LootDisplay:ShowMoney(amountInCopper)
end

G_RLF.Money = Money
