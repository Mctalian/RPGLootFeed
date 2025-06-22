local busted = require("busted")
local stub = busted.stub

local perksActivitiesMocks = {}

_G.C_PerksActivities = {}
perksActivitiesMocks.GetPerksActivityInfo = stub(_G.C_PerksActivities, "GetPerksActivityInfo")
perksActivitiesMocks.GetPerksActivitiesInfo = stub(_G.C_PerksActivities, "GetPerksActivitiesInfo")

return perksActivitiesMocks
