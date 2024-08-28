describe("Reputation module", function()
	before_each(function()
		-- Define the global G_RLF
		_G.unpack = function(t, i)
			i = i or 1
			if t[i] ~= nil then
				return t[i], _G.unpack(t, i + 1)
			end
		end
		_G.G_RLF = {
			db = {
				global = {},
			},
			LootDisplay = {
				ShowRep = function() end,
			},
			Print = function(_, msg) end,
		}
		_G.C_Reputation = {
			ExpandAllFactionHeaders = function() end,
			GetFactionDataByID = function()
				return
			end,
			GetFactionParagonInfo = function()
				return
			end,
			GetFactionDataByIndex = function(i)
				if i == 1 then
					return {
						isHeader = true,
					}
				elseif i == 2 then
					return {
						isHeader = true,
						isHeaderWithRep = true,
						factionID = 1,
					}
				else
				end
				return
			end,
			GetNumFactions = function()
				return 3
			end,
			IsFactionParagon = function()
				return false
			end,
			IsMajorFaction = function()
				return true
			end,
		}
		_G.C_MajorFactions = {
			GetMajorFactionData = function()
				return {
					renownLevel = 1,
					renownReputationEarned = 150,
					renownLevelThreshold = 2500,
				}
			end,
		}
		-- Load the list module before each test
		dofile("Features/Reputation.lua")
	end)

	it("correctly calculates the rep gain", function()
		_G.G_RLF.db.global.repFeed = true
		_G.G_RLF.Rep:FindDelta()
		_G.C_MajorFactions.GetMajorFactionData = function()
			return {
				renownLevel = 1,
				renownReputationEarned = 300,
				renownLevelThreshold = 2500,
			}
		end
		_G.G_RLF.Rep:FindDelta()
	end)
end)
