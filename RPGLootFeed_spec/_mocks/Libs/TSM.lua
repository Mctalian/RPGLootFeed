local busted = require("busted")
local stub = busted.stub

local tsm = {}

_G.TSM_API = {}
tsm.ToItemString = stub(_G.TSM_API, "ToItemString")
tsm.GetCustomPriceValue = stub(_G.TSM_API, "GetCustomPriceValue")

return tsm
