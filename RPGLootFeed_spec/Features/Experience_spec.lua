local nsMocks = require("RPGLootFeed_spec._mocks.Internal.addonNamespace")
local assert = require("luassert")
local match = require("luassert.match")
local busted = require("busted")
local spy = busted.spy
local before_each = busted.before_each
local describe = busted.describe
local it = busted.it
local stub = busted.stub

describe("Experience module", function()
	local _ = match._
	local XpModule, ns, fnMocks

	before_each(function()
		require("RPGLootFeed_spec._mocks.WoWGlobals.Enum")
		fnMocks = require("RPGLootFeed_spec._mocks.WoWGlobals.Functions")
		ns = nsMocks:unitLoadedAfter(nsMocks.LoadSections.All)

		-- Load the LootDisplayProperties module to populate `ns`
		assert(loadfile("RPGLootFeed/Features/_Internals/LootDisplayProperties.lua"))("TestAddon", ns)

		-- Ensure `ns` has been populated correctly by LootDisplayProperties
		assert.is_not_nil(ns.InitializeLootDisplayProperties)

		-- Load the list module before each test
		XpModule = assert(loadfile("RPGLootFeed/Features/Experience.lua"))("TestAddon", ns)
	end)

	it("does not show xp if the unit target is not player", function()
		ns.db.global.xp.enabled = true

		XpModule:PLAYER_XP_UPDATE("PLAYER_XP_UPDATE", "target")

		assert.stub(ns.SendMessage).was.not_called()
	end)

	it("does not show xp if the calculated delta is 0", function()
		ns.db.global.xp.enabled = true

		XpModule:PLAYER_ENTERING_WORLD()

		XpModule:PLAYER_XP_UPDATE("PLAYER_XP_UPDATE", "player")

		assert.stub(ns.SendMessage).was.not_called()
	end)

	it("show xp if the player levels up", function()
		ns.db.global.xp.enabled = true

		XpModule:PLAYER_ENTERING_WORLD()

		-- Leveled up from 2 to 3
		-- old max XP was 50
		-- xp value is still 10
		-- (50 max for last level - 10 old xp value) + 10 new xp value = 50 xp earned
		---@diagnostic disable-next-line: undefined-field
		local stubUnitLevel = fnMocks.UnitLevel.returns(3)
		---@diagnostic disable-next-line: undefined-field
		local stubUnitXPMax = fnMocks.UnitXPMax.returns(100)

		local newElement = spy.on(XpModule.Element, "new")

		XpModule:PLAYER_XP_UPDATE("PLAYER_XP_UPDATE", "player")

		assert.spy(newElement).was.called_with(_, 50)
		assert.stub(ns.SendMessage).was.called(1)
		stubUnitLevel:revert()
		stubUnitXPMax:revert()
	end)
end)
