local busted = require("busted")
local stub = busted.stub

local transmogCollectionMocks = {}

_G.C_TransmogCollection = {}
transmogCollectionMocks.PlayerHasTransmogByItemInfo =
	stub(_G.C_TransmogCollection, "PlayerHasTransmogByItemInfo").returns(true)
transmogCollectionMocks.PlayerHasTransmog = stub(_G.C_TransmogCollection, "PlayerHasTransmog").returns(true)
transmogCollectionMocks.GetItemInfo = stub(_G.C_TransmogCollection, "GetItemInfo").returns(12345, 1)
transmogCollectionMocks.GetAppearanceSourceInfo =
	stub(_G.C_TransmogCollection, "GetAppearanceSourceInfo").returns(0, 1, false, 1, false, "link", "tmogLink", 1, 1)

return transmogCollectionMocks
