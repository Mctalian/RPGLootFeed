local busted = require("busted")
local stub = busted.stub

local delvesUIMocks = {}
_G.C_DelvesUI = {}
delvesUIMocks.GetCurrentDelvesSeasonNumber = stub(_G.C_DelvesUI, "GetCurrentDelvesSeasonNumber").returns(1)
delvesUIMocks.GetFactionForCompanion = stub(_G.C_DelvesUI, "GetFactionForCompanion").returns(2640)

return delvesUIMocks
