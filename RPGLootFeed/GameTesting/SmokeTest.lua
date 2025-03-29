---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

local C = LibStub("C_Everywhere")

--@alpha@
-- trunk-ignore-begin(no-invalid-prints/invalid-print)
---@type RLF_TestMode
local TestMode = G_RLF.RLF:GetModule("TestMode") --[[@as RLF_TestMode]]

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
		C.Item.GetItemInfo(id)
	assertEqual(itemName ~= nil, true, "Global: C.Item.GetItemInfo(" .. id .. ").itemName")
	assertEqual(itemLink ~= nil, true, "Global: C.Item.GetItemInfo(" .. id .. ").itemLink")
	assertEqual(itemQuality ~= nil, true, "Global: C.Item.GetItemInfo(" .. id .. ").itemQuality")
	assertEqual(itemLevel ~= nil, true, "Global: C.Item.GetItemInfo(" .. id .. ").itemLevel")
	assertEqual(itemMinLevel ~= nil, true, "Global: C.Item.GetItemInfo(" .. id .. ").itemMinLevel")
	assertEqual(itemType ~= nil, true, "Global: C.Item.GetItemInfo(" .. id .. ").itemType")
	assertEqual(itemSubType ~= nil, true, "Global: C.Item.GetItemInfo(" .. id .. ").itemSubType")
	assertEqual(itemStackCount ~= nil, true, "Global: C.Item.GetItemInfo(" .. id .. ").itemStackCount")
	assertEqual(itemEquipLoc ~= nil, true, "Global: C.Item.GetItemInfo(" .. id .. ").itemEquipLoc")
	assertEqual(itemTexture ~= nil, true, "Global: C.Item.GetItemInfo(" .. id .. ").itemTexture")
	assertEqual(sellPrice ~= nil, true, "Global: C.Item.GetItemInfo(" .. id .. ").sellPrice")
	assertEqual(classID ~= nil, true, "Global: C.Item.GetItemInfo(" .. id .. ").classID")
	assertEqual(subclassID ~= nil, true, "Global: C.Item.GetItemInfo(" .. id .. ").subclassID")
	assertEqual(bindType ~= nil, true, "Global: C.Item.GetItemInfo(" .. id .. ").bindType")
	assertEqual(expansionID ~= nil, true, "Global: C.Item.GetItemInfo(" .. id .. ").expansionID")
	assertEqual(isCraftingReagent ~= nil, true, "Global: C.Item.GetItemInfo(" .. id .. ").isCraftingReagent")
end

local function testWoWGlobals()
	assertEqual(type(EventRegistry), "table", "Global: EventRegistry")
	assertEqual(type(C.CVar.SetCVar), "function", "Global C.CVar.SetCVar")
	local value, defaultValue, isStoredServerAccount, isStoredServerCharacter, isLockedFromUser, isSecure, isReadonly =
		C.CVar.GetCVarInfo("autoLootDefault")
	assertEqual(value ~= nil, true, "Global: C.CVar.GetCVarInfo autoLootDefault value")
	assertEqual(defaultValue ~= nil, true, "Global: C.CVar.GetCVarInfo autoLootDefault defaultValue")
	assertEqual(isStoredServerAccount ~= nil, true, "Global: C.CVar.GetCVarInfo autoLootDefault isStoredServerAccount")
	assertEqual(
		isStoredServerCharacter ~= nil,
		true,
		"Global: C.CVar.GetCVarInfo autoLootDefault isStoredServerCharacter"
	)
	assertEqual(isLockedFromUser ~= nil, true, "Global: C.CVar.GetCVarInfo autoLootDefault isLockedFromUser")
	assertEqual(isSecure ~= nil, true, "Global: C.CVar.GetCVarInfo autoLootDefault isSecure")
	assertEqual(isReadonly ~= nil, true, "Global: C.CVar.GetCVarInfo autoLootDefault isReadonly")
	assertEqual(type(ChatFrameUtil.ForEachChatFrame), "function", "Global: ChatFrameUtil.ForEachChatFrame")
	assertEqual(type(ChatFrame_RemoveMessageGroup), "function", "Global: ChatFrame_RemoveMessageGroup")
	assertEqual(type(Enum.ItemQuality), "table", "Global: Enum.ItemQuality")
	assertEqual(type(GetFonts), "function", "Global: GetFonts")

	if GetExpansionLevel() > G_RLF.Expansion.CLASSIC then
		assertEqual(type(GetPlayerGuid), "function", "Global: GetPlayerGuid")
	end

	if GetExpansionLevel() >= G_RLF.Expansion.DF then
		assertEqual(type(GetNameAndServerNameFromGUID), "function", "Global: GetNameAndServerNameFromGUID")
	end

	if GetExpansionLevel() >= G_RLF.Expansion.WOD then
		assertEqual(type(BossBanner), "table", "Global: BossBanner")
	end

	assertEqual(type(LootAlertSystem.AddAlert), "function", "Global: LootAlertSystem.AddAlert")

	if GetExpansionLevel() >= G_RLF.Expansion.SL then
		assertEqual(type(C.CurrencyInfo.GetCurrencyInfo), "function", "Global: C.CurrencyInfo.GetCurrencyInfo")
		local info = C.CurrencyInfo.GetCurrencyInfo(1813)
		assertEqual(info ~= nil, true, "Global: C.CurrencyInfo.GetCurrencyInfo(1813)")
		assertEqual(info.description ~= nil, true, "Global: C.CurrencyInfo.GetCurrencyInfo(1813).description")
		assertEqual(info.iconFileID ~= nil, true, "Global: C.CurrencyInfo.GetCurrencyInfo(1813).iconFileID")
		assertEqual(info.currencyID ~= nil, true, "Global: C.CurrencyInfo.GetCurrencyInfo(1813).currencyID")
		assertEqual(C.CurrencyInfo.GetCurrencyLink(1813) ~= nil, true, "Global: C.CurrencyInfo.GetCurrencyLink")
	end

	assertEqual(type(UnitXP), "function", "Global: UnitXP")
	assertEqual(type(UnitXPMax), "function", "Global: UnitXPMax")
	assertEqual(type(UnitLevel), "function", "Global: UnitLevel")
	assertEqual(type(C.Item.GetItemInfo), "function", "Global: C.Item.GetItemInfo")
	assertEqual(type(GetInventoryItemLink), "function", "Global: GetInventoryItemLink")
	local legSlot = G_RLF.equipSlotMap["INVTYPE_LEGS"] --[[@as number]]
	local link = GetInventoryItemLink("player", legSlot)
	local isCached = C.Item.GetItemInfo(link) ~= nil
	if not isCached then
		G_RLF:Print("Item not cached, skipping GetItemInfo test")
	else
		testGetItemInfo(link)
	end
	assertEqual(type(GetMoney), "function", "Global: GetMoney")
	assertEqual(type(C.CurrencyInfo.GetCoinTextureString), "function", "Global: C.CurrencyInfo.GetCoinTextureString")
	assertEqual(type(FACTION_STANDING_INCREASED), "string", "Global: FACTION_STANDING_INCREASED")
	assertEqual(type(FACTION_STANDING_INCREASED_ACH_BONUS), "string", "Global: FACTION_STANDING_INCREASED_ACH_BONUS")
	assertEqual(type(FACTION_STANDING_INCREASED_BONUS), "string", "Global: FACTION_STANDING_INCREASED_BONUS")
	assertEqual(
		type(FACTION_STANDING_INCREASED_DOUBLE_BONUS),
		"string",
		"Global: FACTION_STANDING_INCREASED_DOUBLE_BONUS"
	)
	assertEqual(type(FACTION_STANDING_DECREASED), "string", "Global: FACTION_STANDING_DECREASED")

	if GetExpansionLevel() >= G_RLF.Expansion.SL then
		assertEqual(
			type(FACTION_STANDING_INCREASED_ACCOUNT_WIDE),
			"string",
			"Global: FACTION_STANDING_INCREASED_ACCOUNT_WIDE"
		)
		assertEqual(
			type(FACTION_STANDING_DECREASED_ACCOUNT_WIDE),
			"string",
			"Global: FACTION_STANDING_DECREASED_ACCOUNT_WIDE"
		)
	end

	if GetExpansionLevel() >= G_RLF.Expansion.TWW then
		assertEqual(
			type(FACTION_STANDING_INCREASED_ACH_BONUS_ACCOUNT_WIDE),
			"string",
			"Global: FACTION_STANDING_INCREASED_ACH_BONUS_ACCOUNT_WIDE"
		)
	end

	assertEqual(type(C.Reputation), "table", "Global: C.Reputation")

	if GetExpansionLevel() >= G_RLF.Expansion.DF then
		assertEqual(type(C.Reputation.IsMajorFaction), "function", "Global: C.Reputation.IsMajorFaction")
		assertEqual(type(ACCOUNT_WIDE_FONT_COLOR), "table", "Global: ACCOUNT_WIDE_FONT_COLOR")
	end

	if GetExpansionLevel() >= G_RLF.Expansion.LEGION then
		assertEqual(type(C.Reputation.IsFactionParagon), "function", "Global: C.Reputation.IsFactionParagon")
	end

	if GetExpansionLevel() >= G_RLF.Expansion.TWW then
		assertEqual(type(C.Reputation.GetFactionDataByID), "function", "Global: C.Reputation.GetFactionDataByID")
	end

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
