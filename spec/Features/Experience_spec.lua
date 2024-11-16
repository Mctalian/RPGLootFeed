local common_stubs = require("spec/common_stubs")

describe("Experience module", function()
	local _ = match._
	local XpModule, ns

	before_each(function()
		ns = ns or common_stubs.setup_G_RLF(spy)
		common_stubs.stub_Unit_Funcs()

		-- Load the LootDisplayProperties module to populate `ns`
		assert(loadfile("Features/LootDisplayProperties.lua"))("TestAddon", ns)

		-- Ensure `ns` has been populated correctly by LootDisplayProperties
		assert.is_not_nil(ns.InitializeLootDisplayProperties)
		assert.is_not_nil(ns.LootDisplayProperties)

		-- Load the list module before each test
		XpModule = assert(loadfile("Features/Experience.lua"))("TestAddon", ns)
	end)

	it("does not show xp if the unit target is not player", function()
		ns.db.global.xpFeed = true

		XpModule:PLAYER_XP_UPDATE("PLAYER_XP_UPDATE", "target")

		assert.stub(ns.SendMessage).was_not_called()
	end)

	it("does not show xp if the calculated delta is 0", function()
		ns.db.global.xpFeed = true

		XpModule:PLAYER_ENTERING_WORLD()

		XpModule:PLAYER_XP_UPDATE("PLAYER_XP_UPDATE", "player")

		assert.stub(ns.SendMessage).was_not_called()
	end)

	it("show xp if the player levels up", function()
		ns.db.global.xpFeed = true

		XpModule:PLAYER_ENTERING_WORLD()

		-- Leveled up from 2 to 3
		-- old max XP was 50
		-- xp value is still 10
		-- (50 max for last level - 10 old xp value) + 10 new xp value = 50 xp earned
		_G.UnitLevel = function()
			return 3
		end
		_G.UnitXPMax = function()
			return 100
		end

		local newElement = spy.on(XpModule.Element, "new")

		XpModule:PLAYER_XP_UPDATE("PLAYER_XP_UPDATE", "player")

		assert.spy(newElement).was.called_with(_, 50)
		assert.stub(ns.SendMessage).was.called()
	end)
end)
