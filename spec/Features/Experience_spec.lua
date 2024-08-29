describe("Experience module", function()
	local mockLootDisplay
	local _ = match._
	local XpModule

	before_each(function()
		-- Define the global G_RLF
		_G.G_RLF = {
			db = {
				global = {},
			},
			LootDisplay = {
				ShowXP = function() end,
			},
			RLF = {
				NewModule = function()
					return {}
				end,
			},
		}
		_G.UnitLevel = function()
			return 2
		end
		_G.UnitXP = function()
			return 10
		end
		_G.UnitXPMax = function()
			return 50
		end

		mockLootDisplay = mock(_G.G_RLF.LootDisplay, true)
		-- Load the list module before each test
		XpModule = dofile("Features/Experience.lua")
	end)

	it("does not show xp if the unit target is not player", function()
		_G.G_RLF.db.global.xpFeed = true

		XpModule:PLAYER_XP_UPDATE(_, "target")

		assert.stub(mockLootDisplay.ShowXP).was.not_called()
	end)

	it("does not show xp if the calculated delta is 0", function()
		_G.G_RLF.db.global.xpFeed = true

		XpModule:PLAYER_ENTERING_WORLD()

		XpModule:PLAYER_XP_UPDATE(_, "player")

		assert.stub(mockLootDisplay.ShowXP).was.not_called()
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

		assert.stub(mockLootDisplay.ShowXP).was.called_with(_, 50)
	end)
end)
