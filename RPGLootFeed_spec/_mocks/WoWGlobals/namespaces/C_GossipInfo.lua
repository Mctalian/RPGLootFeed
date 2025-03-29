local busted = require("busted")
local stub = busted.stub

local gossipInfoMocks = {}

_G.C_GossipInfo = {}
gossipInfoMocks.GetFriendshipReputation = stub(_G.C_GossipInfo, "GetFriendshipReputation").returns({
	standing = 63,
	reactionThreshold = 60,
	nextThreshold = 100,
})
gossipInfoMocks.GetFriendshipReputationRanks = stub(_G.C_GossipInfo, "GetFriendshipReputationRanks").returns({
	currentLevel = 3,
	maxLevel = 60,
})

return gossipInfoMocks
