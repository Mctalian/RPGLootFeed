-- common_stubs.lua
local common_stubs = {}

function common_stubs.setup_G_RLF(spy)
	_G.G_RLF = {
		db = {
			global = {
				currencyFeed = true,
			},
		},
		LootDisplay = {
			ShowLoot = function() end,
		},
		RLF = {
			NewModule = function()
				return {}
			end,
		},
		fn = function(_, func, ...)
			return func(...)
		end,
		Print = function(msg) end,
	}

	-- Spy or stub common methods if needed
	spy.on(_G.G_RLF.LootDisplay, "ShowLoot")
	spy.on(_G.G_RLF.LootDisplay, "ShowXP")
end

function common_stubs.stub_C_CurrencyInfo()
	_G.C_CurrencyInfo = {
		GetCurrencyInfo = function(currencyType)
			return {
				currencyID = currencyType,
				description = "An awesome currency",
				iconFileID = 123456,
			}
		end,
		GetCurrencyLink = function(currencyType)
			return "|c12345678|Hcurrency:" .. currencyType .. "|r"
		end,
	}
end

function common_stubs.stub_Unit_Funcs()
	_G.UnitLevel = function()
		return 2
	end
	_G.UnitXP = function()
		return 10
	end
	_G.UnitXPMax = function()
		return 50
	end
end

return common_stubs
