local busted = require("busted")
local stub = busted.stub

local cvar = {}

_G.C_CVar = {}
stub(_G.C_CVar, "SetCVar")

return cvar
