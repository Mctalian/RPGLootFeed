-- common_stubs.lua
local busted = require("busted")
local mock = busted.mock
local stub = busted.stub
local spy = busted.spy
local common_stubs = {}

local embedLibs = require("RPGLootFeed_spec._mocks.Libs.embedLibUtil")

function common_stubs.setup_G_RLF()
	---@class test_G_RLF: G_RLF
	local ns = {
		addonVersion = "1.0.0",
		localeName = "RPGLootFeedLocale",
		defaults = {
			global = {},
		},
		options = {
			args = {},
		},
		DbMigrations = {},
		migrations = {},
		ShouldRunMigration = spy.new(function()
			return false
		end),
		DbAccessor = {},
		db = {
			locale = {
				factionMap = {},
			},
			global = {
				animations = {
					exit = {
						fadeOutDelay = 1,
						duration = 1,
					},
				},
				blizzOverrides = {
					enableAutoLoot = false,
				},
				currency = {
					enabled = true,
				},
				item = {
					itemHighlights = {
						mounts = true,
						legendary = true,
					},
					itemQualitySettings = {},
					sounds = {
						mounts = {
							enabled = false,
							sound = "",
						},
						legendary = {
							enabled = false,
							sound = "",
						},
						betterThanEquipped = {
							enabled = false,
							sound = "",
						},
					},
				},
				prof = {
					skillColor = { 1, 1, 1, 1 },
				},
				partyLoot = {
					itemQualityFilter = {
						[1] = true,
						[2] = true,
						[3] = true,
						[4] = true,
						[5] = true,
						[6] = true,
					},
				},
				money = {},
				xp = {
					experienceTextColor = { 1, 1, 1, 1 },
				},
				rep = {
					defaultRepColor = { 0.5, 0.5, 1 },
					secondaryTextAlpha = 0.7,
					enableRepLevel = true,
					repLevelColor = { 0.5, 0.5, 1, 1 },
					repLevelTextWrapChar = 5,
				},
			},
		},
		hiddenCurrencies = {},
		L = {
			Issues = "Issues",
		},
		ConfigHandlers = {
			PartyLootConfig = {
				GetPositioningOptions = spy.new(function() end),
				GetSizingOptions = spy.new(function() end),
				GetStylingOptions = spy.new(function() end),
			},
		},
		LootDisplay = {},
		list = function()
			return {}
		end,
		Queue = {
			new = function()
				return {}
			end,
		},
		AuctionIntegrations = {
			Init = spy.new(function() end),
		},
		RLF = {
			NewModule = spy.new(function(_, name, ...)
				local module = {
					moduleName = name,
					Enable = spy.new(function() end),
					Disable = spy.new(function() end),
					fn = function(s, func, ...)
						if type(func) == "function" then
							return xpcall(func, _G.handledError, ...)
						end
					end,
				}
				embedLibs(module, ...)
				return module
			end),
			GetModule = spy.new(function(_, name)
				local module = {
					Enable = spy.new(function() end),
					Disable = spy.new(function() end),
				}
				if name == "Logger" then
					module.Trace = spy.new(function()
						return "Trace"
					end)
				end

				return module
			end),
		},
		SendMessage = spy.new(function() end),
		NotifyChange = spy.new(function() end),
		OpenOptions = spy.new(function() end),
		fn = function(_, func, ...)
			return func(...)
		end,
		Print = spy.new(function() end),
		ProfileFunction = spy.new(function(_, func, name)
			return func
		end),
		CreatePatternSegmentsForStringNumber = spy.new(function()
			return { 1, 2, 3 }
		end),
		ExtractDynamicsFromPattern = spy.new(function()
			return "Test", 3
		end),
		RGBAToHexFormat = spy.new(function(_, r, g, b, a)
			local f = math.floor
			return string.format("|c%02x%02x%02x%02x", f(a * 255), f(r * 255), f(g * 255), f(b * 255))
		end),
		TruncateItemLink = spy.new(function() end),
		CalculateTextWidth = spy.new(function() end),
		TableToCommaSeparatedString = spy.new(function() end),
		FontFlagsToString = spy.new(function() end),
		retryHook = spy.new(function() end),
		WrapCharOptions = {},
		LootDisplayProperties = {},
		InitializeLootDisplayProperties = spy.new(function(element)
			element.Show = spy.new(function() end)
		end),
		ItemInfo = {
			new = spy.new(function()
				return {
					itemId = 18803,
					itemName = "Finkle's Lava Dredger",
					itemQuality = 2,
					IsMount = function()
						return true
					end,
					IsLegendary = function()
						return true
					end,
					IsEligibleEquipment = function()
						return true
					end,
				}
			end),
		},
		lsm = {
			HashTable = spy.new(function() end),
			MediaType = {
				FONT = "font",
			},
		},
		Masque = {},
		iconGroup = {},
		acd = {},
		DBIcon = {},
		tempFontString = {},
		mainFeatureOrder = {},
		FeatureModule = {
			ItemLoot = "ItemLoot",
			Currency = "Currency",
			Money = "Money",
			Reputation = "Reputation",
			Experience = "Experience",
			Profession = "Profession",
			PartyLoot = "PartyLoot",
		},
		LogEventSource = {
			ADDON = "TestAddon",
			WOWEVENT = "WOWEVENT",
		},
		LogLevel = {
			debug = "DEBUG",
			info = "INFO",
			warn = "WARN",
			error = "ERROR",
		},
		EnterAnimationType = {
			NONE = "none",
			FADE = "fade",
			SLIDE = "slide",
		},
		ExitAnimationType = {
			NONE = "none",
			FADE = "fade",
		},
		SlideDirection = {
			LEFT = "left",
			RIGHT = "right",
			UP = "up",
			DOWN = "down",
		},
		LogDebug = spy.new(function() end),
		LogInfo = spy.new(function() end),
		LogWarn = spy.new(function() end),
		LogError = spy.new(function() end),
		Expansion = {
			CLASSIC = 0,
			TBC = 1,
			WOTLK = 2,
			CATA = 3,
			MOP = 4,
			WOD = 5,
			LEGION = 6,
			BFA = 7,
			SL = 8,
			DF = 9,
			TWW = 10,
		},
		DisableBossBanner = {
			ENABLED = 0,
			FULLY_DISABLE = 1,
			DISABLE_LOOT = 2,
			DISABLE_MY_LOOT = 3,
			DISABLE_GROUP_LOOT = 4,
		},
		ItemQualEnum = {
			Poor = 0,
			Common = 1,
			Uncommon = 2,
			Rare = 3,
			Epic = 4,
			Legendary = 5,
			Artifact = 6,
			Heirloom = 7,
		},
		PricesEnum = {
			None = "none",
			Vendor = "vendor",
			AH = "ah",
		},
		WrapCharEnum = {
			DEFAULT = 0,
			SPACE = 1,
			PARENTHESIS = 2,
			BRACKET = 3,
			BRACE = 4,
			ANGLE = 5,
			BAR = 6,
		},
		FontFlags = {
			NONE = "NONE",
			OUTLINE = "OUTLINE",
			THICKOUTLINE = "THICKOUTLINE",
			MONOCHROME = "MONOCHROME",
		},
		GameSounds = {
			LOOT_SMALL_COIN = 567428,
		},
		DefaultIcons = {
			MONEY = "133785",
			REPUTATION = "236681",
			XP = "894556",
			PROFESSION = "133740",
		},
		Frames = {
			MAIN = "RLF_MAIN",
			PARTY = "RLF_PARTY",
		},
		TertiaryStats = {
			None = 0,
			Speed = 1,
			Leech = 2,
			Avoid = 3,
			Indestructible = 4,
		},
		armorClassMapping = {},
		equipSlotMap = {},
		tertiaryToString = {},
		IsRetail = spy.new(function()
			return true
		end),
		IsClassic = spy.new(function()
			return false
		end),
		IsCataClassic = spy.new(function()
			return false
		end),
		ClassicToRetail = {},
		dump = spy.new(function() end),
	}

	return ns
end

function common_stubs.stub_C_CurrencyInfo()
	_G.C_CurrencyInfo = {}
	stub(_G.C_CurrencyInfo, "GetCurrencyInfo").returns({
		currencyID = 123,
		description = "An awesome currency",
		iconFileID = 123456,
	})
	stub(_G.C_CurrencyInfo, "GetCurrencyLink", function(currencyType)
		return "|c12345678|Hcurrency:" .. currencyType .. "|r"
	end)
	stub(_G.C_CurrencyInfo, "GetBasicCurrencyInfo", function(currencyType, quantity)
		return {
			name = "Best Coin",
			description = "An awesome currency",
			icon = 123456,
			quality = 2,
			displayAmount = quantity,
			actualAmount = quantity,
		}
	end)
end

function common_stubs.stub_C_Item()
	_G.C_Item = {}
	stub(_G.C_Item, "GetItemCount", function(itemID)
		return 1
	end)
	stub(_G.C_Item, "GetItemInfo", function(itemLink)
		return 18803, "Finkle's Lava Dredger", 2, 60, 1, "INV_AXE_33"
	end)
	stub(_G.C_Item, "GetItemIDForItemInfo", function(itemLink)
		return 18803
	end)
	stub(_G.C_Item, "GetItemStats", function(itemLink)
		return {
			["ITEM_MOD_STRENGTH_SHORT"] = 10,
			["ITEM_MOD_AGILITY_SHORT"] = 5,
			["ITEM_MOD_INTELLECT_SHORT"] = 8,
			["ITEM_MOD_STAMINA_SHORT"] = 12,
		}
	end)
	stub(_G.C_Item, "GetItemStatDelta", function(fromLink, toLink)
		return {
			["ITEM_MOD_STRENGTH_SHORT"] = 10,
			["ITEM_MOD_AGILITY_SHORT"] = 5,
			["ITEM_MOD_INTELLECT_SHORT"] = 8,
			["ITEM_MOD_STAMINA_SHORT"] = 12,
		}
	end)
end

function common_stubs.stub_C_Reputation()
	---@diagnostic disable-next-line: missing-fields
	_G.ACCOUNT_WIDE_FONT_COLOR = {
		r = 0,
		g = 0,
		b = 1,
	}
	stub(_G.ACCOUNT_WIDE_FONT_COLOR, "WrapTextInColorCode", function(text)
		return text
	end)
	stub(_G.ACCOUNT_WIDE_FONT_COLOR, "GetRGB", function(self)
		return self.r, self.g, self.b
	end)
	stub(_G.ACCOUNT_WIDE_FONT_COLOR, "IsEqualTo", function(self, other)
		return self.r == other.r and self.g == other.g and self.b == other.b
	end)
	stub(_G.ACCOUNT_WIDE_FONT_COLOR, "SetRGB", function(self, r, g, b)
		self.r, self.g, self.b = r, g, b
	end)
	stub(_G.ACCOUNT_WIDE_FONT_COLOR, "GetRGBA", function(self)
		return self.r, self.g, self.b, 1
	end)
	stub(_G.ACCOUNT_WIDE_FONT_COLOR, "GenerateHexColorMarkup", function(self)
		return string.format("|cff%02x%02x%02x", self.r * 255, self.g * 255, self.b * 255)
	end)
	stub(_G.ACCOUNT_WIDE_FONT_COLOR, "GenerateHexColor", function(self)
		return string.format("%02x%02x%02x", self.r * 255, self.g * 255, self.b * 255)
	end)
	stub(_G.ACCOUNT_WIDE_FONT_COLOR, "GetRGBAsBytes", function(self)
		return self.r * 255, self.g * 255, self.b * 255
	end)
	stub(_G.ACCOUNT_WIDE_FONT_COLOR, "SetRGBA", function(self, r, g, b, a)
		self.r, self.g, self.b, self.a = r, g, b, a or 1
	end)
	stub(_G.ACCOUNT_WIDE_FONT_COLOR, "GetRGBAAsBytes", function(self)
		return self.r * 255, self.g * 255, self.b * 255, (self.a or 1) * 255
	end)

	_G.FACTION_GREEN_COLOR = {
		r = 0,
		g = 1,
		b = 0,
		WrapTextInColorCode = spy.new(function(text)
			return text
		end),
		GetRGB = spy.new(function(self)
			return self.r, self.g, self.b
		end),
		IsEqualTo = spy.new(function(self, other)
			return self.r == other.r and self.g == other.g and self.b == other.b
		end),
		SetRGB = spy.new(function(self, r, g, b)
			self.r, self.g, self.b = r, g, b
		end),
		GetRGBA = spy.new(function(self)
			return self.r, self.g, self.b, 1
		end),
		GenerateHexColorMarkup = spy.new(function(self)
			return string.format("|cff%02x%02x%02x", self.r * 255, self.g * 255, self.b * 255)
		end),
		GenerateHexColor = spy.new(function(self)
			return string.format("%02x%02x%02x", self.r * 255, self.g * 255, self.b * 255)
		end),
		GetRGBAsBytes = spy.new(function(self)
			return self.r * 255, self.g * 255, self.b * 255
		end),
		SetRGBA = spy.new(function(self, r, g, b, a)
			self.r, self.g, self.b, self.a = r, g, b, a or 1
		end),
		GetRGBAAsBytes = spy.new(function(self)
			return self.r * 255, self.g * 255, self.b * 255, (self.a or 1) * 255
		end),
	}
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
		ExpandAllFactionHeaders = spy.new(function() end),
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
					currentReactionThreshold = 0,
					nextReactionThreshold = 3000,
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
		IsMajorFaction = function(id)
			return false
		end,
		IsFactionParagon = function(id)
			return false
		end,
	}
	_G.C_GossipInfo = {
		GetFriendshipReputationRanks = function(id)
			return {
				currentLevel = 3,
				maxLevel = 60,
			}
		end,
		GetFriendshipReputation = function(id)
			return {
				standing = 63,
				reactionThreshold = 60,
				nextThreshold = 100,
			}
		end,
	}
end

function common_stubs.stub_C_DelvesUI()
	_G.C_DelvesUI = {
		GetCurrentDelvesSeasonNumber = spy.new(function()
			return 1
		end),
		GetFactionForCompanion = spy.new(function(id)
			return 2640
		end),
	}
end

function common_stubs.stub_C_ClassColor()
	_G.C_ClassColor = {
		GetClassColor = spy.new(function(class)
			return 0.78, 0.61, 0.43
		end),
	}
end

return common_stubs
