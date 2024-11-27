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

local function runTestSafely(testFunction, testName, ...)
	local success, err = pcall(testFunction, ...)
	assertEqual(success, true, testName, err)
end

local function displayResults()
	G_RLF:Print("Integration Test")
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

local function runExperienceIntegrationTest()
	local module = G_RLF.RLF:GetModule("Experience")
	local e = module.Element:new(1337)
	runTestSafely(e.Show, "LootDisplay: Experience")
end

local function runMoneyIntegrationTest()
	local module = G_RLF.RLF:GetModule("Money")
	local e = module.Element:new(12345)
	runTestSafely(e.Show, "LootDisplay: Money")
end

local function runItemLootIntegrationTest()
	local module = G_RLF.RLF:GetModule("ItemLoot")
	local info = TestMode.testItems[2]
	local amountLooted = 1
	local e = module.Element:new(info, amountLooted, false)
	if info.itemName == nil then
		G_RLF:Print("Item not cached, skipping ItemLoot test")
	else
		runTestSafely(e.Show, "LootDisplay: Item", e, info.itemName, info.itemQuality)
		e = module.Element:new(info, amountLooted, false)
		e.highlight = true
		runTestSafely(e.Show, "LootDisplay: Item Quantity Update", e, info.itemName, info.itemQuality)
		e = module.Element:new(info, amountLooted, "player")
		runTestSafely(e.Show, "LootDisplay: Item Unit", e, info.itemName, info.itemQuality)
	end
end

local function runCurrencyIntegrationTest()
	local module = G_RLF.RLF:GetModule("Currency")
	local testObj = TestMode.testCurrencies[2]
	local amountLooted = 1
	testObj.basicInfo.displayAmount = amountLooted
	local e = module.Element:new(testObj.link, testObj.info, testObj.basicInfo)
	runTestSafely(e.Show, "LootDisplay: Currency")
	e = module.Element:new(testObj.link, testObj.info, testObj.basicInfo)
	runTestSafely(e.Show, "LootDisplay: Currency Quantity Update")
end

local function runReputationIntegrationTest()
	local module = G_RLF.RLF:GetModule("Reputation")
	local testObj = TestMode.testFactions[2]
	local amountLooted = 664
	local e = module.Element:new(amountLooted, testObj)
	runTestSafely(e.Show, "LootDisplay: Reputation")
	e = module.Element:new(amountLooted, testObj)
	runTestSafely(e.Show, "LootDisplay: Reputation Quantity Update")
end

function TestMode:IntegrationTest()
	if not self.integrationTestReady then
		G_RLF:Print("Integration test not ready")
		return
	end

	tests = {}
	prints = ""
	successCount = 0
	failureCount = 0

	runExperienceIntegrationTest()
	runMoneyIntegrationTest()
	runItemLootIntegrationTest()
	runCurrencyIntegrationTest()
	runReputationIntegrationTest()

	local frame = LootDisplayFrame
	assertEqual(frame ~= nil, true, "LootDisplayFrame")
	C_Timer.After(G_RLF.db.global.fadeOutDelay + 3, function()
		assertEqual(#frame.rowHistory, 6, "LootDisplayFrame: rowHistory")
		displayResults()
	end)
end

-- trunk-ignore-end(no-invalid-prints/invalid-print)
--@end-alpha@
