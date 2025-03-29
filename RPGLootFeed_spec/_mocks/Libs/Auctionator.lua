local busted = require("busted")
local stub = busted.stub

local auctionator = {}

_G.Auctionator = {
	API = {
		v1 = {},
	},
}

auctionator.API = {
	v1 = {},
}
auctionator.API.v1.RegisterForDBUpdate = stub(_G.Auctionator.API.v1, "RegisterForDBUpdate")
auctionator.API.v1.GetAuctionPriceByItemLink = stub(_G.Auctionator.API.v1, "GetAuctionPriceByItemLink")

return auctionator
