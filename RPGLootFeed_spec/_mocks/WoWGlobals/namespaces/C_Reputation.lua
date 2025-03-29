local busted = require("busted")
local stub = busted.stub

local reputationMocks = {}

_G.C_Reputation = {}
reputationMocks.ExpandAllFactionHeaders = stub(_G.C_Reputation, "ExpandAllFactionHeaders")
reputationMocks.GetNumFactions = stub(_G.C_Reputation, "GetNumFactions").returns(2)
reputationMocks.GetFactionDataByIndex = stub(_G.C_Reputation, "GetFactionDataByIndex", function(index)
	if index == 1 then
		return {
			name = "Faction A",
			factionID = 1,
			reaction = 1,
		}
	end
	if index == 2 then
		return {
			name = "Brann Bronzebeard",
			factionID = 2640,
			reaction = 8,
		}
	end
	return nil
end)
reputationMocks.GetFactionDataByID = stub(_G.C_Reputation, "GetFactionDataByID", function(id)
	if id == 1 then
		return {
			name = "Faction A",
			factionID = 1,
			reaction = 1,
			currentStanding = 20,
			currentReactionThreshold = 0,
			nextReactionThreshold = 3000,
		}
	end
	if id == 2640 then
		return {
			name = "Brann Bronzebeard",
			factionID = 2640,
			reaction = 8,
		}
	end
end)
reputationMocks.IsMajorFaction = stub(_G.C_Reputation, "IsMajorFaction").returns(false)
reputationMocks.IsFactionParagon = stub(_G.C_Reputation, "IsFactionParagon").returns(false)

return reputationMocks
