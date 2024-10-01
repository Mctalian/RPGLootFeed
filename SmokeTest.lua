local addonName, G_RLF = ...

--@alpha@
-- trunk-ignore-begin(no-invalid-prints/invalid-print)
local TestMode = G_RLF.RLF:GetModule("TestMode")
local testItems, testCurrencies, testFactions

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

function TestMode:SmokeTest(...)
	testItems, testCurrencies, testFactions = ...

	tests = {}
	prints = ""
	successCount = 0
	failureCount = 0
	testWoWGlobals()
	testLootDisplay()

	print(addonName .. " Smoke Test")
	print(prints)
	print("|cff00ff00Successes: " .. successCount .. "|r")
	if failureCount > 0 then
		print("|cffff0000Failures: " .. failureCount .. "|r")
	end

	local msg = ""
	for testName, testData in pairs(tests) do
		if not testData.result then
			msg = msg
				.. "|cffff0000Failure: "
				.. testName
				.. " failed: expected "
				.. tostring(testData.expected)
				.. ", got "
				.. tostring(testData.actual)
				.. "|r|n"
		end
	end

	if failureCount > 0 then
		error(msg)
	end
end

-- trunk-ignore-end(no-invalid-prints/invalid-print)
--@end-alpha@
