TestMode = {}

local function idExistsInTable(id, table)
	for _, item in pairs(table) do
		if item.id == id then
			return true
		end
	end
	return false
end

-- Initial test items with color variables
local testItemIds = {
	50818,
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

local testItems = {}
local function initializeTestItems()
	for _, id in pairs(testItemIds) do
		if not idExistsInTable(id, testItems) then
			local _, link = C_Item.GetItemInfo(id)
			local icon = C_Item.GetItemIconByID(id)
			if link and icon then
				table.insert(testItems, {
					id = id,
					link = link,
					icon = icon,
				})
			end
		end
	end
end

local testCurrencyIds = {
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

local testCurrencies = {}
local function initializeTestCurrencies()
	for _, id in pairs(testCurrencyIds) do
		if not idExistsInTable(id, testCurrencies) then
			local info = C_CurrencyInfo.GetCurrencyInfo(id)
			local link = C_CurrencyInfo.GetCurrencyLink(id)
			if info and link and info.currencyID and info.iconFileID then
				table.insert(testCurrencies, {
					id = info.currencyID,
					link = link,
					icon = info.iconFileID,
				})
			end
		end
	end
end

local function generateRandomLoot()
	if #testItems ~= #testItemIds then
		initializeTestItems()
	end

	if #testCurrencies ~= #testCurrencyIds then
		initializeTestCurrencies()
	end
	-- Randomly decide whether to generate an item or currency
	local rng = math.random()
	if rng < 0.8 then
		-- Generate random item
		local item = testItems[math.random(#testItems)]
		local amountLooted = math.random(1, 5)
		G_RLF.LootDisplay:ShowLoot(item.id, item.link, item.icon, amountLooted)
		if rng < 0.1 then
			local copper = math.random(1, 100000000)
			G_RLF.LootDisplay:ShowMoney(copper)
		end
	else
		-- Generate random currency
		local currency = testCurrencies[math.random(#testCurrencies)]
		local amountLooted = math.random(1, 500)
		G_RLF.LootDisplay:ShowLoot(currency.id, currency.link, currency.icon, amountLooted)
	end
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
			G_RLF:fn(generateRandomLoot)
		end)
	end
end

G_RLF:fn(initializeTestItems)
G_RLF:fn(initializeTestCurrencies)

G_RLF.TestMode = TestMode
