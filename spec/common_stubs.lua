-- common_stubs.lua
local common_stubs = {}

local function embedLibs(addonOrModule, ...)
	for _, lib in ipairs({ ... }) do
		if lib == "AceBucket-3.0" then
			addonOrModule.RegisterBucketMessage = function(self, bucket, delay, handler) end
			addonOrModule.UnregisterBucket = function(self, bucket) end
		end
		if lib == "AceEvent-3.0" then
			addonOrModule.RegisterEvent = function(self, event, handler) end
			addonOrModule.UnregisterEvent = function(self, event) end
			addonOrModule.RegisterMessage = function(self, message, handler) end
			addonOrModule.SendMessage = function(self, message, ...) end
			addonOrModule.UnregisterMessage = function(self, message) end
		end
		if lib == "AceHook-3.0" then
			addonOrModule.Hook = function(self, object, method, handler, hookSecure) end
			addonOrModule.HookScript = function(self, frame, script, handler) end
			addonOrModule.IsHooked = function(self, obj, method)
				return false
			end
			addonOrModule.RawHook = function(self, object, method, handler, hookSecure) end
			addonOrModule.RawHookScript = function(self, frame, script, handler) end
			addonOrModule.SecureHook = function(self, object, method, handler) end
			addonOrModule.SecureHookScript = function(self, frame, script, handler) end
			addonOrModule.Unhook = function(self, object, method) end
			addonOrModule.UnhookAll = function(self) end
			addonOrModule.hooks = {}
		end
	end
end

function common_stubs.setup_G_RLF(spy)
	common_stubs.stub_WoWGlobals(spy)

	local logger = {
		Debug = spy.new(),
		Info = spy.new(),
		Warn = spy.new(),
		Error = spy.new(),
	}
	local ns = {
		addonVersion = "1.0.0",
		db = {
			global = {
				currencyFeed = true,
				factionMaps = {},
				itemHighlights = {
					mounts = true,
					legendary = true,
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
				xp = {
					experienceTextColor = { 1, 1, 1, 1 },
				},
			},
		},
		L = {
			Issues = "Issues",
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
			Init = spy.new(),
		},
		RLF = {
			NewModule = function(_, name, ...)
				local module = {
					moduleName = name,
					Enable = function() end,
					Disable = function() end,
					fn = function(s, func, ...)
						if type(func) == "function" then
							return xpcall(func, _G.handledError, ...)
						end
					end,
				}
				embedLibs(module, ...)
				return module
			end,
			GetModule = function(_, name)
				local module = {
					Enable = spy.new(),
					Disable = spy.new(),
				}
				if name == "Logger" then
					module.Trace = function()
						return "Trace"
					end
				end

				return module
			end,
		},
		SendMessage = spy.new(),
		fn = function(_, func, ...)
			return func(...)
		end,
		Print = function(msg) end,
		ProfileFunction = function(_, name, func)
			return func
		end,
		CreatePatternSegmentsForStringNumber = spy.new(function()
			return { 1, 2, 3 }
		end),
		ExtractDynamicsFromPattern = spy.new(function()
			return "Test", 3
		end),
		RGBAToHexFormat = function(_, r, g, b, a)
			local f = math.floor
			return string.format("|c%02x%02x%02x%02x", f(a * 255), f(r * 255), f(g * 255), f(b * 255))
		end,
		InitializeLootDisplayProperties = function(element)
			element.Show = spy.new()
		end,
		ItemInfo = {
			new = function()
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
			end,
		},
		FeatureModule = {
			ItemLoot = "ItemLoot",
			Currency = "Currency",
			Money = "Money",
			Reputation = "Reputation",
			Experience = "Experience",
			Profession = "Profession",
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
		LogDebug = spy.new(),
		LogInfo = spy.new(),
		LogWarn = spy.new(),
		LogError = spy.new(),
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
		},
		IsRetail = spy.new(function()
			return true
		end),
		IsClassic = spy.new(function()
			return false
		end),
	}

	ns.LibStubReturn = {}
	_G.LibStub = function(lib)
		ns.LibStubReturn[lib] = {}
		if lib == "AceAddon-3.0" then
			ns.LibStubReturn[lib] = {
				NewAddon = function(...)
					local addon = {}
					embedLibs(addon, ...)
					addon.SetDefaultModuleState = spy.new()
					addon.SetDefaultModulePrototype = spy.new()
					return addon
				end,
			}
		elseif lib == "AceConfig-3.0" then
			ns.LibStubReturn[lib] = {
				RegisterOptionsTable = spy.new(),
			}
		elseif lib == "AceConfigDialog-3.0" then
			ns.LibStubReturn[lib] = {
				AddToBlizOptions = spy.new(),
				Close = spy.new(),
				Open = spy.new(),
			}
		elseif lib == "AceConfigRegistry-3.0" then
			ns.LibStubReturn[lib] = {
				NotifyChange = spy.new(),
			}
		elseif lib == "AceDB-3.0" then
			ns.LibStubReturn[lib] = {
				New = function()
					return { global = {} }
				end,
			}
		elseif lib == "AceGUI-3.0" then
			ns.LibStubReturn[lib] = {
				Create = function()
					return {
						AddChild = spy.new(),
						DisableButton = spy.new(),
						DoLayout = spy.new(),
						EnableResize = spy.new(),
						IsShown = function()
							return true
						end,
						SetLayout = spy.new(),
						SetTitle = spy.new(),
						SetStatusText = spy.new(),
						SetCallback = spy.new(),
						SetText = spy.new(),
						SetValue = spy.new(),
						SetColor = spy.new(),
						SetDisabled = spy.new(),
						SetFullWidth = spy.new(),
						SetFullHeight = spy.new(),
						SetItemValue = spy.new(),
						SetRelativeWidth = spy.new(),
						SetRelativeHeight = spy.new(),
						SetList = spy.new(),
						SetMultiselect = spy.new(),
						SetNumLines = spy.new(),
						SetPoint = spy.new(),
						SetWidth = spy.new(),
						SetHeight = spy.new(),
						SetLabel = spy.new(),
						SetImage = spy.new(),
						SetImageSize = spy.new(),
						SetImageCoords = spy.new(),
						Show = spy.new(),
						Hide = spy.new(),
					}
				end,
			}
		elseif lib == "AceLocale-3.0" then
			ns.LibStubReturn[lib] = {
				GetLocale = function()
					return ns.L
				end,
			}
		elseif lib == "LibSharedMedia-3.0" then
			ns.LibStubReturn[lib] = {
				Register = spy.new(),
				MediaType = {
					FONT = "font",
				},
			}
		elseif lib == "Masque" then
			ns.LibStubReturn[lib] = {
				Group = function()
					return {
						ReSkin = spy.new(),
					}
				end,
			}
		elseif lib == "C_Everywhere" then
			ns.LibStubReturn[lib] = {
				CurrencyInfo = _G.C_CurrencyInfo,
				Item = _G.C_Item,
			}
		else
			error("Unmocked library: " .. lib)
		end
		return ns.LibStubReturn[lib]
	end

	return ns
end

function common_stubs.stub_WoWGlobals(spy)
	common_stubs.stub_Unit_Funcs()
	common_stubs.stub_Money_Funcs()

	_G.GetExpansionLevel = function()
		return 10
	end

	_G.Enum = {
		ItemArmorSubclass = {
			Plate = 4,
		},
		ItemClass = { Armor = 4, Miscellaneous = 15 },
		ItemMiscellaneousSubclass = { Mount = 5 },
		ItemQuality = { Legendary = 5 },
	}

	_G.Constants = {
		CurrencyConsts = {
			ACCOUNT_WIDE_HONOR_CURRENCY_ID = 1585,
		},
	}

	_G.C_CVar = {
		SetCVar = function() end,
	}

	_G.EditModeManagerFrame = {
		IsInMode = function() end,
	}
	_G.EventRegistry = {
		RegisterCallback = function() end,
	}

	_G.date = function()
		return "2023-01-01 12:00:00"
	end
	_G.debugprofilestop = function()
		return 0
	end
	_G.format = string.format
	_G.handledError = function(err)
		print("\n")
		print(err)
		print("The above error was thrown during a test and caught by xpcall")
		print("This is usually indicative of an issue, or an improperly mocked test")
		print("\n")
		return false
	end
	_G.unpack = table.unpack

	_G.RunNextFrame = function(func)
		func()
	end

	_G.IsInRaid = function()
		return false
	end

	_G.IsInInstance = function()
		return false, ""
	end

	_G.MEMBERS_PER_RAID_GROUP = 5
	_G.GetNumGroupMembers = function()
		return 1
	end

	_G.GetPlayerGuid = function()
		return "player"
	end

	_G.GetLocale = function()
		return "enUS"
	end
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

function common_stubs.stub_C_Item()
	_G.C_Item = {
		GetItemCount = function(itemID)
			return 1
		end,
		GetItemInfo = function(itemLink)
			return 18803, "Finkle's Lava Dredger", 2, 60, 1, "INV_AXE_33"
		end,
		GetItemIDForItemInfo = function(itemLink)
			return 18803
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
		IsMajorFaction = function()
			return false
		end,
		IsFactionParagon = function()
			return false
		end,
	}
	_G.C_GossipInfo = {
		GetFriendshipReputationRanks = function()
			return {
				currentLevel = 3,
				maxLevel = 60,
			}
		end,
		GetFriendshipReputation = function()
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
		GetCurrentDelvesSeasonNumber = function()
			return 1
		end,
		GetFactionForCompanion = function()
			return 2640
		end,
	}
end

function common_stubs.stub_Unit_Funcs()
	_G.UnitGUID = function(unit)
		return "player"
	end
	_G.UnitLevel = function()
		return 2
	end
	_G.UnitName = function()
		return "Player"
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
