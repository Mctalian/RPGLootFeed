local addonName, G_RLF = ...

--@alpha@
-- trunk-ignore-begin(no-invalid-prints/invalid-print)
local TestMode = G_RLF.RLF:GetModule("TestMode")

local tests = {}
local prints = ""
local successCount = 0
local failureCount = 0

local function assertEqual(actual, expected, testName, err)
	tests[testName] = {
		result = actual == expected,
		expected = expected,
		actual = actual,
		err = err,
	}
	if actual == expected then
		prints = prints .. "|cff00ff00•|r"
		successCount = successCount + 1
	else
		prints = prints .. "|cffff0000x|r"
		failureCount = failureCount + 1
	end
end

local function testGetItemInfo(id)
	local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType, expansionID, _, isCraftingReagent =
		C_Item.GetItemInfo(id)
	assertEqual(itemName ~= nil, true, "Global: C_Item.GetItemInfo(" .. id .. ").itemName")
	assertEqual(itemLink ~= nil, true, "Global: C_Item.GetItemInfo(" .. id .. ").itemLink")
	assertEqual(itemQuality ~= nil, true, "Global: C_Item.GetItemInfo(" .. id .. ").itemQuality")
	assertEqual(itemLevel ~= nil, true, "Global: C_Item.GetItemInfo(" .. id .. ").itemLevel")
	assertEqual(itemMinLevel ~= nil, true, "Global: C_Item.GetItemInfo(" .. id .. ").itemMinLevel")
	assertEqual(itemType ~= nil, true, "Global: C_Item.GetItemInfo(" .. id .. ").itemType")
	assertEqual(itemSubType ~= nil, true, "Global: C_Item.GetItemInfo(" .. id .. ").itemSubType")
	assertEqual(itemStackCount ~= nil, true, "Global: C_Item.GetItemInfo(" .. id .. ").itemStackCount")
	assertEqual(itemEquipLoc ~= nil, true, "Global: C_Item.GetItemInfo(" .. id .. ").itemEquipLoc")
	assertEqual(itemTexture ~= nil, true, "Global: C_Item.GetItemInfo(" .. id .. ").itemTexture")
	assertEqual(sellPrice ~= nil, true, "Global: C_Item.GetItemInfo(" .. id .. ").sellPrice")
	assertEqual(classID ~= nil, true, "Global: C_Item.GetItemInfo(" .. id .. ").classID")
	assertEqual(subclassID ~= nil, true, "Global: C_Item.GetItemInfo(" .. id .. ").subclassID")
	assertEqual(bindType ~= nil, true, "Global: C_Item.GetItemInfo(" .. id .. ").bindType")
	assertEqual(expansionID ~= nil, true, "Global: C_Item.GetItemInfo(" .. id .. ").expansionID")
	assertEqual(isCraftingReagent ~= nil, true, "Global: C_Item.GetItemInfo(" .. id .. ").isCraftingReagent")
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
	assertEqual(type(GetInventoryItemLink), "function", "Global: GetInventoryItemLink")
	local link = GetInventoryItemLink("player", G_RLF.equipSlotMap["INVTYPE_CHEST"])
	local isCached = C_Item.GetItemInfo(link) ~= nil
	if not isCached then
		G_RLF:Print("Item not cached, skipping GetItemInfo test")
	else
		testGetItemInfo(link)
	end
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

local function displayResults()
	G_RLF:Print("Smoke Test")
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
			if testData.err then
				msg = msg .. " Error: " .. testData.err
			end
			msg = msg .. "|r|n\n"
		end
	end

	if failureCount > 0 then
		error(msg)
	end
end

function TestMode:SmokeTest()
	tests = {}
	prints = ""
	successCount = 0
	failureCount = 0
	testWoWGlobals()
	displayResults()
end

-- trunk-ignore-end(no-invalid-prints/invalid-print)
--@end-alpha@
