local common_stubs = require("spec/common_stubs")

describe("Experience module", function()
	local _ = match._
	local XpModule

	before_each(function()
		common_stubs.setup_G_RLF(spy)
		common_stubs.stub_Unit_Funcs()
		-- Load the list module before each test
		XpModule = require("Features/Experience")
	end)

	it("does not show xp if the unit target is not player", function()
		_G.G_RLF.db.global.xpFeed = true

		XpModule:PLAYER_XP_UPDATE("PLAYER_XP_UPDATE", "target")

		assert.stub(_G.G_RLF.LootDisplay.ShowLoot).was_not_called()
	end)

	it("does not show xp if the calculated delta is 0", function()
		_G.G_RLF.db.global.xpFeed = true

		XpModule:PLAYER_ENTERING_WORLD()

		XpModule:PLAYER_XP_UPDATE("PLAYER_XP_UPDATE", "player")

		assert.stub(_G.G_RLF.LootDisplay.ShowLoot).was_not_called()
	end)

	it("does not show xp if the calculated delta is 0", function()
		_G.G_RLF.db.global.xpFeed = true

		XpModule:PLAYER_ENTERING_WORLD()

		_G.UnitLevel = function()
			return 3
		end
		_G.UnitXPMax = function()
			return 100
		end

		XpModule:PLAYER_XP_UPDATE("PLAYER_XP_UPDATE", "player")

		assert.stub(_G.G_RLF.LootDisplay.ShowLoot).was.called()
		assert.stub(_G.G_RLF.LootDisplay.ShowLoot).was.called_with(_, "Experience", 50)
	end)
end)
