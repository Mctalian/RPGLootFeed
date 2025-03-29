local busted = require("busted")
local stub = busted.stub
local classColorMocks = {}
_G.C_ClassColor = {}
classColorMocks.GetClassColor = stub(_G.C_ClassColor, "GetClassColor").returns(0.78, 0.61, 0.43)

return classColorMocks
