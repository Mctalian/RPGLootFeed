local busted = require("busted")
local stub = busted.stub

local currencyInfoMocks = {}

_G.C_CurrencyInfo = {}
currencyInfoMocks.GetCurrencyInfo = stub(_G.C_CurrencyInfo, "GetCurrencyInfo").returns({
	currencyID = 123,
	description = "An awesome currency",
	iconFileID = 123456,
})
currencyInfoMocks.GetCurrencyLink = stub(_G.C_CurrencyInfo, "GetCurrencyLink", function(currencyType)
	return "|c12345678|Hcurrency:" .. currencyType .. "|r"
end)
currencyInfoMocks.GetBasicCurrencyInfo = stub(
	_G.C_CurrencyInfo,
	"GetBasicCurrencyInfo",
	function(currencyType, quantity)
		return {
			name = "Best Coin",
			description = "An awesome currency",
			icon = 123456,
			quality = 2,
			displayAmount = quantity,
			actualAmount = quantity,
		}
	end
)

return currencyInfoMocks
