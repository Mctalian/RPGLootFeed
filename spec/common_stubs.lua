-- common_stubs.lua
local common_stubs = {}

function common_stubs.setup_G_RLF(spy)
	_G.unpack = table.unpack
	_G.handledError = function(err)
		print("\n")
		print(err)
		print("The above error was thrown during a test and caught by xpcall")
		print("This is usually indicative of an issue, or an improperly mocked test")
		print("\n")
		return false
	end

	_G.RunNextFrame = function(func)
		func()
	end

	local logger = {
		Debug = spy.new(),
		Info = spy.new(),
		Warn = spy.new(),
		Error = spy.new(),
	}
	local ns = {
		db = {
			global = {
				currencyFeed = true,
				factionMaps = {},
			},
		},
		LootDisplay = {
			ShowLoot = function() end,
		},
		list = function()
			return {}
		end,
		Queue = {
			new = function()
				return {}
			end,
		},
		RLF = {
			NewModule = function(_, name, libs)
				return {
					moduleName = name,
					getLogger = function(self)
						return logger
					end,
					Enable = function() end,
					Disable = function() end,
					fn = function(s, func, ...)
						if type(func) == "function" then
							return xpcall(func, _G.handledError, ...)
						end
					end,
				}
			end,
		},
		fn = function(_, func, ...)
			return func(...)
		end,
		Print = function(msg) end,
		RGBAToHexFormat = function(_, r, g, b, a)
			local f = math.floor
			return string.format("|c%02x%02x%02x%02x", f(a * 255), f(r * 255), f(g * 255), f(b * 255))
		end,
	}

	_G.GetLocale = function()
		return "enUS"
	end

	-- Spy or stub common methods if needed
	spy.on(ns.LootDisplay, "ShowLoot")

	return ns
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
		GetBasicCurrencyInfo = function(currencyType, quantity)
			return {
				name = "Best Coin",
				description = "An awesome currency",
				icon = 123456,
				quality = 2,
				displayAmount = quantity,
				actualAmount = quantity,
			}
		end,
	}
end

function common_stubs.stub_C_Reputation()
	_G.ACCOUNT_WIDE_FONT_COLOR = { r = 0, g = 0, b = 1 }
	_G.FACTION_GREEN_COLOR = { r = 0, g = 1, b = 0 }
	_G.FACTION_BAR_COLORS = {
		[1] = { r = 1, g = 0, b = 0 },
		[8] = { r = 0, g = 1, b = 0 },
	}
	_G.FACTION_STANDING_INCREASED = "Rep with %s inc by %d."
	_G.FACTION_STANDING_INCREASED_ACCOUNT_WIDE = "AccRep with %s inc by %d."
	_G.FACTION_STANDING_INCREASED_ACH_BONUS = "Rep with %s inc by %d (+.1f bonus)."
	_G.FACTION_STANDING_INCREASED_ACH_BONUS_ACCOUNT_WIDE = "AccRep with %s inc by %d (+.1f bonus)."
	_G.FACTION_STANDING_INCREASED_BONUS = "Rep with %s inc by %d (+.1f bonus)."
	_G.FACTION_STANDING_INCREASED_DOUBLE_BONUS = "Rep with %s inc by %d (+.1f bonus)."
	_G.FACTION_STANDING_DECREASED = "Rep with %s dec by %d."
	_G.FACTION_STANDING_DECREASED_ACCOUNT_WIDE = "AccRep with %s dec by %d."
	_G.C_Reputation = {
		ExpandAllFactionHeaders = function() end,
		GetNumFactions = function()
			return 2
		end,
		GetFactionDataByIndex = function(index)
			if index == 1 then
				return {
					name = "Faction A",
					factionID = 1,
					reaction = 1,
				}
			end
			if index == 2 then
				return {
					name = "Brann Bronzebeard",
					factionID = 2640,
					reaction = 8,
				}
			end
			return nil
		end,
		GetFactionDataByID = function(id)
			if id == 1 then
				return {
					name = "Faction A",
					factionID = 1,
					reaction = 1,
					currentStanding = 20,
					currentReactionThreshold = 3000,
				}
			end
			if id == 2640 then
				return {
					name = "Brann Bronzebeard",
					factionID = 2640,
					reaction = 8,
				}
			end
		end,
		IsMajorFaction = function()
			return false
		end,
		IsFactionParagon = function()
			return false
		end,
	}
end

function common_stubs.stub_C_DelvesUI()
	_G.C_DelvesUI = {
		GetCurrentDelvesSeasonNumber = function()
			return 1
		end,
		GetFactionForCompanion = function()
			return 2640
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

function common_stubs.stub_Money_Funcs()
	_G.GetMoney = function()
		return 123456
	end
end

return common_stubs
