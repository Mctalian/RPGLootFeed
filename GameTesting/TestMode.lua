local addonName, G_RLF = ...

local TestMode = G_RLF.RLF:NewModule("TestMode", "AceEvent-3.0")

local logger
local allItemsInitialized = false
local allCurrenciesInitialized = false
local allFactionsInitialized = false
local isLootDisplayReady = false
local pendingRequests = {}
TestMode.testItems = {}
TestMode.testCurrencies = {}
TestMode.testFactions = {}

local function idExistsInTable(id, table)
	for _, item in pairs(table) do
		if item.id and item.id == id then
			return true
		end
		if item.itemId and item.itemId == id then
			return true
		end
	end
	return false
end

local function anyPendingRequests()
	for _, v in pairs(pendingRequests) do
		if v ~= nil then
			return true
		end
	end
	return false
end

local function signalIntegrationTestReady()
	if not TestMode.integrationTestReady
		and allItemsInitialized
		and isLootDisplayReady
		and allCurrenciesInitialized
		and allFactionsInitialized
	then
		--@alpha@
		TestMode:IntegrationTestReady()
		--@end-alpha@
	end
end

local function getItem(id)
	local name, link, quality, icon, sellPrice, _
	local info = G_RLF.ItemInfo:new(id, C_Item.GetItemInfo(id))
	local isCached = info ~= nil
	if isCached then
		if not idExistsInTable(id, TestMode.testItems) then
			pendingRequests[id] = nil
			table.insert(TestMode.testItems, info)
		end
	else
		pendingRequests[id] = true
	end
end

local testItemIds = { 50818, 2589, 2592, 1515, 730, 128827, 219325, 34494 }
local function initializeTestItems()
	for _, id in pairs(testItemIds) do
		getItem(id)
	end

	if #TestMode.testItems == #testItemIds then
		allItemsInitialized = true
		signalIntegrationTestReady()
		return
	end
end

local testCurrencyIds = { 2245, 1191, 1828, 1792, 1755, 1580, 1273, 1166, 515, 241, 1813, 2778, 3089, 1101, 1704 }
local function initializeTestCurrencies()
	for _, id in pairs(testCurrencyIds) do
		if not idExistsInTable(id, TestMode.testCurrencies) then
			local info = C_CurrencyInfo.GetCurrencyInfo(id)
			local link = C_CurrencyInfo.GetCurrencyLink(id)
			local basicInfo = C_CurrencyInfo.GetBasicCurrencyInfo(id, 100)
			if info and link and info.currencyID and info.iconFileID then
				table.insert(TestMode.testCurrencies, {
					id = info.currencyID,
					link = link,
					icon = info.iconFileID,
					quantity = info.quantity,
					quality = info.quality,
					totalEarned = info.totalEarned,
					maxQuantity = info.maxQuantity,
				})
			end
		end
	end

	allCurrenciesInitialized = true
	signalIntegrationTestReady()
end

local numTestFactions = 3
local function initializeTestFactions()
	for i = 1, numTestFactions do
		local factionInfo = C_Reputation.GetFactionDataByIndex(i)
		if factionInfo and factionInfo.name then
			table.insert(TestMode.testFactions, factionInfo.name)
		end
	end
	allFactionsInitialized = true
	signalIntegrationTestReady()
end

function TestMode:OnInitialize()
	isLootDisplayReady = false
	allItemsInitialized = false
	self.testCurrencies = {}
	self.testItems = {}
	self.testFactions = {}
	self:RegisterEvent("GET_ITEM_INFO_RECEIVED")
	RunNextFrame(function()
		self:InitializeTestData()
	end)
	--@alpha@
	RunNextFrame(function()
		self:SmokeTest()
	end)
	--@end-alpha@
end

function TestMode:IntegrationTestReady()
	self.integrationTestReady = true
end

function TestMode:OnLootDisplayReady()
	isLootDisplayReady = true
	signalIntegrationTestReady()
end

local failedRetrievals = {}
function TestMode:GET_ITEM_INFO_RECEIVED(eventName, itemID, success)
	if not pendingRequests[itemID] then
		return
	end

	if not success then
		failedRetrievals[itemID] = (failedRetrievals[itemID] or 0) + 1
		if failedRetrievals[itemID] >= 5 then
			--@alpha@
			error("Failed to load item 5 times: " .. itemID)
			--@end-alpha@
			return
		end
	end

	G_RLF:ProfileFunction(getItem, "getItem")(itemID)
	-- getItem(itemID)

	if #self.testItems == #testItemIds and not anyPendingRequests() then
		allItemsInitialized = true
		signalIntegrationTestReady()
	end
end

local function generateRandomLoot()
	if #TestMode.testItems ~= #testItemIds then
		initializeTestItems()
	end

	if #TestMode.testCurrencies ~= #testCurrencyIds then
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
			local info = TestMode.testItems[math.random(#TestMode.testItems)]
			local amountLooted = math.random(1, 5)
			local module = G_RLF.RLF:GetModule("ItemLoot")
			local e = module.Element:new(info, amountLooted, false)
			e:Show(info.itemName, info.itemQuality)

			-- 10% chance of iitem loot to show up as a party member
			if rng < 0.3 then
				local unit = "player"
				local module = G_RLF.RLF:GetModule("ItemLoot")
				local e = module.Element:new(info, amountLooted, unit)
				e:Show(info.itemName, info.itemQuality)
			end

			-- 15% chance to show currency
		elseif rng > 0.7 and rng <= 0.85 then
			local currency = TestMode.testCurrencies[math.random(#TestMode.testCurrencies)]
			local amountLooted = math.random(1, 500)
			local module = G_RLF.RLF:GetModule("Currency")
			local e = module.Element:new(
				currency.id,
				currency.link,
				currency.icon,
				amountLooted,
				currency.quantity,
				currency.quality,
				currency.totalEarned,
				currency.maxQuantity
			)
			e:Show()

			-- 10% chance to show reputation (least frequent)
		elseif rng > 0.85 then
			local reputationGained = math.random(10, 100)
			local factionName = TestMode.testFactions[math.random(#TestMode.testFactions)]
			local module = G_RLF.RLF:GetModule("Reputation")
			local e = module.Element:new(reputationGained, factionName)
			e:Show()
		end
	end
end

function TestMode:InitializeTestData()
	G_RLF:fn(initializeTestItems)
	G_RLF:fn(initializeTestCurrencies)
	G_RLF:fn(initializeTestFactions)
end

function TestMode:ToggleTestMode()
	if not logger then
		logger = G_RLF.RLF:GetModule("Logger")
	end
	if not isLootDisplayReady then
		error("LootDisplay did not signal it was ready (or we didn't receive the signal) - cannot start TestMode")
	end
	if self.testMode then
		-- Stop test mode
		self.testMode = false
		if self.testTimer then
			self.testTimer:Cancel()
			self.testTimer = nil
		end
		G_RLF:Print(G_RLF.L["Test Mode Disabled"])
		G_RLF:LogDebug("Test Mode Disabled", addonName)
	else
		-- Start test mode
		self.testMode = true
		G_RLF:Print(G_RLF.L["Test Mode Enabled"])
		G_RLF:LogDebug("Test Mode Enabled", addonName)
		self.testTimer = C_Timer.NewTicker(1.5, function()
			G_RLF:fn(generateRandomLoot)
		end)
	end
end
