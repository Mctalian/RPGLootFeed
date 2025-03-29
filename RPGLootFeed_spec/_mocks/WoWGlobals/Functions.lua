local busted = require("busted")
local stub = busted.stub
local spy = busted.spy

local functions = {}

stub(_G, "CreateFrame")
stub(_G, "GetExpansionLevel", function()
	return 10
end)
stub(_G, "GetInventoryItemLink")
_G.date = spy.new(function(format)
	return "2023-01-01 12:00:00"
end)
_G.debugprofilestop = spy.new(function()
	return 0
end)
_G.format = string.format
_G.handledError = function(err)
	print("\n")
	print(err)
	print("The above error was thrown during a test and caught by xpcall")
	print("This is usually indicative of an issue, or an improperly mocked test")
	print("\n")
	return false
end
---@diagnostic disable-next-line: undefined-field
_G.unpack = table.unpack

_G.RunNextFrame = spy.new(function(func)
	func()
end)

stub(_G, "IsInRaid", function()
	return false
end)
stub(_G, "IsInInstance", function()
	return false, ""
end)
_G.MEMBERS_PER_RAID_GROUP = 5
stub(_G, "GetNumGroupMembers", function()
	return 1
end)
stub(_G, "GetPlayerGuid", function()
	return "player"
end)
stub(_G, "GetLocale", function()
	return "enUS"
end)
stub(_G, "MuteSoundFile")
stub(_G, "UnmuteSoundFile")

stub(_G, "UnitGUID", function(unit)
	return "player"
end)
stub(_G, "UnitLevel", function()
	return 2
end)
stub(_G, "UnitName", function()
	return "Player"
end)
stub(_G, "UnitXP", function()
	return 10
end)
stub(_G, "UnitXPMax", function()
	return 50
end)
stub(_G, "UnitClass", function()
	return "Warrior", "WARRIOR", 1
end)
stub(_G, "GetMoney", function()
	return 123456
end)

return functions
