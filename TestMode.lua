TestMode = {}

-- Initial test items with color variables
local testItems = {
	2589,
	2592,
	1515,
	730,
	19019,
	128507,
	132842,
	23538,
	11754,
	128827,
	219325,
}

TestMode.TestItems = {}
for _, id in pairs(testItems) do
	local _, _, _, _, icon = C_Item.GetItemInfoInstant(id)
	local _, link = C_Item.GetItemInfo(id)
	table.insert(TestMode.TestItems, {
		id = id,
		link = link,
		icon = icon,
	})
end

local testCurrencies = {
	2245,
	1191,
	1828,
	1792,
	1755,
	1580,
	1273,
	1166,
	515,
	241,
	1813,
	2778,
	3089,
	1101,
	1704,
}

TestMode.TestCurrencies = {}
for _, id in pairs(testCurrencies) do
	local info = C_CurrencyInfo.GetCurrencyInfo(id)
	table.insert(TestMode.TestCurrencies, {
		id = info.currencyID,
		link = C_CurrencyInfo.GetCurrencyLink(id),
		icon = info.iconFileID,
	})
end

function TestMode:ToggleTestMode()
	if self.testMode then
		-- Stop test mode
		self.testMode = false
		if self.testTimer then
			self.testTimer:Cancel()
			self.testTimer = nil
		end
		G_RLF:Print(G_RLF.L["Test Mode Disabled"])
	else
		-- Start test mode
		self.testMode = true
		G_RLF:Print(G_RLF.L["Test Mode Enabled"])
		self.testTimer = C_Timer.NewTicker(1.5, function()
			self:GenerateRandomLoot()
		end)
	end
end

function TestMode:GenerateRandomLoot()
	-- Randomly decide whether to generate an item or currency
	local rng = math.random()
	if rng < 0.8 then
		-- Generate random item
		local item = self.TestItems[math.random(#self.TestItems)]
		local amountLooted = math.random(1, 5)
		G_RLF.LootDisplay:ShowLoot(item.id, item.link, item.icon, amountLooted)
		if rng < 0.1 then
			local copper = math.random(1, 100000000)
			G_RLF.LootDisplay:ShowMoney(copper)
		end
	else
		-- Generate random currency
		local currency = self.TestCurrencies[math.random(#self.TestCurrencies)]
		local amountLooted = math.random(1, 500)
		G_RLF.LootDisplay:ShowLoot(currency.id, currency.link, currency.icon, amountLooted)
	end
end

G_RLF.TestMode = TestMode
