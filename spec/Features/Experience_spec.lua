local common_stubs = require("spec/common_stubs")

describe("Experience module", function()
	local _ = match._
	local XpModule

	before_each(function()
		common_stubs.setup_G_RLF(spy)
		common_stubs.stub_Unit_Funcs()
		-- Load the list module before each test
		XpModule = dofile("Features/Experience.lua")
	end)

	it("does not show xp if the unit target is not player", function()
		_G.G_RLF.db.global.xpFeed = true

		XpModule:PLAYER_XP_UPDATE(_, "target")

		assert.stub(_G.G_RLF.LootDisplay.ShowXP).was_not_called()
	end)

	it("does not show xp if the calculated delta is 0", function()
		_G.G_RLF.db.global.xpFeed = true

		XpModule:PLAYER_ENTERING_WORLD()

		XpModule:PLAYER_XP_UPDATE(_, "player")

		assert.stub(_G.G_RLF.LootDisplay.ShowXP).was_not_called()
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

		XpModule:PLAYER_XP_UPDATE(_, "player")

		assert.stub(_G.G_RLF.LootDisplay.ShowXP).was_called_with(_, 50)
	end)
end)
