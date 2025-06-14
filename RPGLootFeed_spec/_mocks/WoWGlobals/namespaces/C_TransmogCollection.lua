local busted = require("busted")
local stub = busted.stub

local transmogCollectionMocks = {}

_G.C_TransmogCollection = {}
transmogCollectionMocks.PlayerHasTransmogByItemInfo =
	stub(_G.C_TransmogCollection, "PlayerHasTransmogByItemInfo").returns(true)

return transmogCollectionMocks
