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

--@alpha@
-- trunk-ignore-begin(no-invalid-prints/invalid-print)
local tests = {}
local prints = ""
local successCount = 0
local failureCount = 0

local function assertEqual(actual, expected, testName)
	tests[testName] = {
		result = actual == expected,
		expected = expected,
		actual = actual,
	}
	if actual == expected then
		prints = prints .. "|cff00ff00•|r"
		successCount = successCount + 1
	else
		prints = prints .. "|cffff0000x|r"
		failureCount = failureCount + 1
	end
end

local function testWoWGlobals()
	assertEqual(type(EventRegistry), "table", "Global: EventRegistry")
	assertEqual(type(C_CVar.SetCVar), "function", "Global C_CVar.SetCVar")
	local value, defaultValue, isStoredServerAccount, isStoredServerCharacter, isLockedFromUser, isSecure, isReadonly =
		C_CVar.GetCVarInfo("autoLootDefault")
	assertEqual(value ~= nil, true, "Global: C_CVar.GetCVarInfo autoLootDefault value")
	assertEqual(defaultValue ~= nil, true, "Global: C_CVar.GetCVarInfo autoLootDefault defaultValue")
	assertEqual(isStoredServerAccount ~= nil, true, "Global: C_CVar.GetCVarInfo autoLootDefault isStoredServerAccount")
	assertEqual(
		isStoredServerCharacter ~= nil,
		true,
		"Global: C_CVar.GetCVarInfo autoLootDefault isStoredServerCharacter"
	)
	assertEqual(isLockedFromUser ~= nil, true, "Global: C_CVar.GetCVarInfo autoLootDefault isLockedFromUser")
	assertEqual(isSecure ~= nil, true, "Global: C_CVar.GetCVarInfo autoLootDefault isSecure")
	assertEqual(isReadonly ~= nil, true, "Global: C_CVar.GetCVarInfo autoLootDefault isReadonly")
	assertEqual(type(ChatFrameUtil.ForEachChatFrame), "function", "Global: ChatFrameUtil.ForEachChatFrame")
	assertEqual(type(ChatFrame_RemoveMessageGroup), "function", "Global: ChatFrame_RemoveMessageGroup")
	assertEqual(type(Enum.ItemQuality), "table", "Global: Enum.ItemQuality")
	assertEqual(type(GetFonts), "function", "Global: GetFonts")
	assertEqual(type(GetPlayerGuid), "function", "Global: GetPlayerGuid")
	assertEqual(type(GetNameAndServerNameFromGUID), "function", "Global: GetNameAndServerNameFromGUID")
	assertEqual(type(BossBanner), "table", "Global: BossBanner")
	assertEqual(type(LootAlertSystem.AddAlert), "function", "Global: LootAlertSystem.AddAlert")
	assertEqual(type(C_CurrencyInfo.GetCurrencyInfo), "function", "Global: C_CurrencyInfo.GetCurrencyInfo")
	local info = C_CurrencyInfo.GetCurrencyInfo(1813)
	assertEqual(info ~= nil, true, "Global: C_CurrencyInfo.GetCurrencyInfo(1813)")
	assertEqual(info.description ~= nil, true, "Global: C_CurrencyInfo.GetCurrencyInfo(1813).description")
	assertEqual(info.iconFileID ~= nil, true, "Global: C_CurrencyInfo.GetCurrencyInfo(1813).iconFileID")
	assertEqual(info.currencyID ~= nil, true, "Global: C_CurrencyInfo.GetCurrencyInfo(1813).currencyID")
	assertEqual(C_CurrencyInfo.GetCurrencyLink(1813) ~= nil, true, "Global: C_CurrencyInfo.GetCurrencyLink")
	assertEqual(type(UnitXP), "function", "Global: UnitXP")
	assertEqual(type(UnitXPMax), "function", "Global: UnitXPMax")
	assertEqual(type(UnitLevel), "function", "Global: UnitLevel")
	assertEqual(type(GetPlayerGuid), "function", "Global: GetPlayerGuid")
	assertEqual(type(C_Item.GetItemInfo), "function", "Global: C_Item.GetItemInfo")
	local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType, expansionID, setID, isCraftingReagent =
		C_Item.GetItemInfo(34494)
	assertEqual(itemName ~= nil, true, "Global: C_Item.GetItemInfo(34494).itemName")
	assertEqual(itemLink ~= nil, true, "Global: C_Item.GetItemInfo(34494).itemLink")
	assertEqual(itemQuality ~= nil, true, "Global: C_Item.GetItemInfo(34494).itemQuality")
	assertEqual(itemLevel ~= nil, true, "Global: C_Item.GetItemInfo(34494).itemLevel")
	assertEqual(itemMinLevel ~= nil, true, "Global: C_Item.GetItemInfo(34494).itemMinLevel")
	assertEqual(itemType ~= nil, true, "Global: C_Item.GetItemInfo(34494).itemType")
	assertEqual(itemSubType ~= nil, true, "Global: C_Item.GetItemInfo(34494).itemSubType")
	assertEqual(itemStackCount ~= nil, true, "Global: C_Item.GetItemInfo(34494).itemStackCount")
	assertEqual(itemEquipLoc ~= nil, true, "Global: C_Item.GetItemInfo(34494).itemEquipLoc")
	assertEqual(itemTexture ~= nil, true, "Global: C_Item.GetItemInfo(34494).itemTexture")
	assertEqual(sellPrice ~= nil, true, "Global: C_Item.GetItemInfo(34494).sellPrice")
	assertEqual(classID ~= nil, true, "Global: C_Item.GetItemInfo(34494).classID")
	assertEqual(subclassID ~= nil, true, "Global: C_Item.GetItemInfo(34494).subclassID")
	assertEqual(bindType ~= nil, true, "Global: C_Item.GetItemInfo(34494).bindType")
	assertEqual(expansionID ~= nil, true, "Global: C_Item.GetItemInfo(34494).expansionID")
	assertEqual(setID == nil, true, "Global: C_Item.GetItemInfo(34494).setID")
	assertEqual(isCraftingReagent ~= nil, true, "Global: C_Item.GetItemInfo(34494).isCraftingReagent")
	assertEqual(type(GetMoney), "function", "Global: GetMoney")
	assertEqual(type(C_CurrencyInfo.GetCoinTextureString), "function", "Global: C_CurrencyInfo.GetCoinTextureString")
	assertEqual(type(FACTION_STANDING_INCREASED), "string", "Global: FACTION_STANDING_INCREASED")
	assertEqual(
		type(FACTION_STANDING_INCREASED_ACCOUNT_WIDE),
		"string",
		"Global: FACTION_STANDING_INCREASED_ACCOUNT_WIDE"
	)
	assertEqual(type(FACTION_STANDING_INCREASED_ACH_BONUS), "string", "Global: FACTION_STANDING_INCREASED_ACH_BONUS")
	assertEqual(
		type(FACTION_STANDING_INCREASED_ACH_BONUS_ACCOUNT_WIDE),
		"string",
		"Global: FACTION_STANDING_INCREASED_ACH_BONUS_ACCOUNT_WIDE"
	)
	assertEqual(type(FACTION_STANDING_INCREASED_BONUS), "string", "Global: FACTION_STANDING_INCREASED_BONUS")
	assertEqual(
		type(FACTION_STANDING_INCREASED_DOUBLE_BONUS),
		"string",
		"Global: FACTION_STANDING_INCREASED_DOUBLE_BONUS"
	)
	assertEqual(type(FACTION_STANDING_DECREASED), "string", "Global: FACTION_STANDING_DECREASED")
	assertEqual(
		type(FACTION_STANDING_DECREASED_ACCOUNT_WIDE),
		"string",
		"Global: FACTION_STANDING_DECREASED_ACCOUNT_WIDE"
	)
	assertEqual(type(C_Reputation), "table", "Global: C_Reputation")
	assertEqual(type(C_Reputation.IsMajorFaction), "function", "Global: C_Reputation.IsMajorFaction")
	assertEqual(type(C_Reputation.IsFactionParagon), "function", "Global: C_Reputation.IsFactionParagon")
	assertEqual(type(C_Reputation.GetFactionDataByID), "function", "Global: C_Reputation.GetFactionDataByID")
	assertEqual(type(ACCOUNT_WIDE_FONT_COLOR), "table", "Global: ACCOUNT_WIDE_FONT_COLOR")
	assertEqual(type(FACTION_GREEN_COLOR), "table", "Global: FACTION_GREEN_COLOR")
	assertEqual(type(FACTION_BAR_COLORS), "table", "Global: FACTION_BAR_COLORS")
end

local function runTestSafely(testFunction, testName)
	local success, err = pcall(testFunction)
	assertEqual(success, true, testName)
end

local function testLootDisplay()
	if #testItems ~= #testItemIds then
		initializeTestItems()
	end

	if #testCurrencies ~= #testCurrencyIds then
		initializeTestCurrencies()
	end

	local module, e, testObj, amountLooted
	module = G_RLF.RLF:GetModule("Experience")
	e = module.Element:new(1337)
	runTestSafely(e.Show, "LootDisplay: Experience")
	module = G_RLF.RLF:GetModule("Money")
	e = module.Element:new(12345)
	runTestSafely(e.Show, "LootDisplay: Money")
	module = G_RLF.RLF:GetModule("ItemLoot")
	testObj = testItems[2]
	amountLooted = 1
	e = module.Element:new(testObj.id, testObj.link, testObj.icon, amountLooted)
	runTestSafely(e.Show, "LootDisplay: Item")
	runTestSafely(e.Show, "LootDisplay: Item Quantity Update")
	module = G_RLF.RLF:GetModule("Currency")
	testObj = testCurrencies[2]
	e = module.Element:new(testObj.id, testObj.link, testObj.icon, amountLooted)
	runTestSafely(e.Show, "LootDisplay: Currency")
	runTestSafely(e.Show, "LootDisplay: Currency Quantity Update")
	module = G_RLF.RLF:GetModule("Reputation")
	testObj = testFactions[2]
	amountLooted = 664
	e = module.Element:new(amountLooted, testObj)
	runTestSafely(e.Show, "LootDisplay: Reputation")
	runTestSafely(e.Show, "LootDisplay: Reputation Quantity Update")
end

function TestMode:SmokeTest()
	tests = {}
	prints = ""
	successCount = 0
	failureCount = 0
	testWoWGlobals()
	testLootDisplay()

	print(G_RLF.addonName .. " Smoke Test")
	print(prints)
	print("|cff00ff00Successes: " .. successCount .. "|r")
	if failureCount > 0 then
		print("|cffff0000Failures: " .. failureCount .. "|r")
	end

	for testName, testData in pairs(tests) do
		if not testData.result then
			local msg = "|cffff0000Failure: "
				.. testName
				.. " failed: expected "
				.. tostring(testData.expected)
				.. ", got "
				.. tostring(testData.actual)
				.. "|r"
			error(msg)
		end
	end
end

-- trunk-ignore-end(no-invalid-prints/invalid-print)
--@end-alpha@

G_RLF.TestMode = TestMode
