local busted = require("busted")
local stub = busted.stub

local majorFactionMocks = {}

_G.C_MajorFactions = {}
majorFactionMocks.GetMajorFactionData = stub(_G.C_MajorFactions, "GetMajorFactionData")
majorFactionMocks.GetMajorFactionRenownInfo = stub(_G.C_MajorFactions, "GetMajorFactionRenownInfo")

return majorFactionMocks
