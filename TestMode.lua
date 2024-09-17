TestMode = {}

local logger

local function idExistsInTable(id, table)
	for _, item in pairs(table) do
		if item.id == id then
			return true
		end
	end
	return false
end

-- Initial test items with color variables
local testItemIds = { 50818, 2589, 2592, 1515, 730, 19019, 128507, 132842, 23538, 11754, 128827, 219325 }

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

local testCurrencyIds = { 2245, 1191, 1828, 1792, 1755, 1580, 1273, 1166, 515, 241, 1813, 2778, 3089, 1101, 1704 }

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

local testFactions = {
	"Undercity",
	"Thunder Bluff",
	"Orgrimmar",
}

local function generateRandomLoot()
	if #testItems ~= #testItemIds then
		initializeTestItems()
	end

	if #testCurrencies ~= #testCurrencyIds then
		initializeTestCurrencies()
	end
	-- Randomly decide whether to generate an item or currency
	local numberOfRowsToGenerate = math.random(1, 5)
	for i = 1, numberOfRowsToGenerate do
		local rng = math.random()

		if rng >= 0.8 then
			local experienceGained = math.random(100, 10000)
			local module = G_RLF.RLF:GetModule("Experience")
			local e = module.Element:new(experienceGained)
			e:Show()
		end

		if rng <= 0.2 then
			local copper = math.random(1, 100000000)
			local module = G_RLF.RLF:GetModule("Money")
			local e = module.Element:new(copper)
			e:Show()
		end

		-- 50% chance to show items
		if rng > 0.2 and rng <= 0.7 then
			local item = testItems[math.random(#testItems)]
			local amountLooted = math.random(1, 5)
			local module = G_RLF.RLF:GetModule("ItemLoot")
			local e = module.Element:new(item.id, item.link, item.icon, amountLooted)
			e:Show()

			-- 15% chance to show currency
		elseif rng > 0.7 and rng <= 0.85 then
			local currency = testCurrencies[math.random(#testCurrencies)]
			local amountLooted = math.random(1, 500)
			local module = G_RLF.RLF:GetModule("Currency")
			local e = module.Element:new(currency.id, currency.link, currency.icon, amountLooted)
			e:Show()

			-- 10% chance to show reputation (least frequent)
		elseif rng > 0.85 then
			local reputationGained = math.random(10, 100)
			local factionName = testFactions[math.random(#testFactions)]
			local module = G_RLF.RLF:GetModule("Reputation")
			local e = module.Element:new(reputationGained, factionName)
			e:Show()
		end
	end
end

function TestMode:ToggleTestMode()
	if not logger then
		logger = G_RLF.RLF:GetModule("Logger")
	end
	if self.testMode then
		-- Stop test mode
		self.testMode = false
		if self.testTimer then
			self.testTimer:Cancel()
			self.testTimer = nil
		end
		G_RLF:Print(G_RLF.L["Test Mode Disabled"])
		logger:Debug("Test Mode Disabled", G_RLF.addonName)
	else
		-- Start test mode
		self.testMode = true
		G_RLF:Print(G_RLF.L["Test Mode Enabled"])
		logger:Debug("Test Mode Enabled", G_RLF.addonName)
		self.testTimer = C_Timer.NewTicker(1.5, function()
			G_RLF:fn(generateRandomLoot)
		end)
	end
end

G_RLF:fn(initializeTestItems)
G_RLF:fn(initializeTestCurrencies)

G_RLF.TestMode = TestMode
