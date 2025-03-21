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
		defaults = {
			global = {},
		},
		options = {
			args = {},
		},
		migrations = {},
		db = {
			locale = {
				factionMap = {},
			},
			global = {
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
		SendMessage = spy.new(function() end),
		fn = function(_, func, ...)
			return func(...)
		end,
		Print = function(msg) end,
		ProfileFunction = function(_, func, name)
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
		IsRetail = spy.new(function()
			return true
		end),
		IsClassic = spy.new(function()
			return false
		end),
	}

	ns.LibStubReturn = {}
	_G.LibStub = function(lib, silence)
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
		elseif lib == "LibDataBroker-1.1" then
			ns.LibStubReturn[lib] = {
				NewDataObject = function()
					return {
						OnClick = spy.new(),
						OnTooltipShow = spy.new(),
					}
				end,
			}
		elseif lib == "LibDBIcon-1.0" then
			ns.LibStubReturn[lib] = {
				Register = spy.new(),
				Show = spy.new(),
				Hide = spy.new(),
			}
		elseif lib == "LibEasyMenu" then
			ns.LibStubReturn[lib] = {
				EasyMenu = spy.new(),
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

	_G.CreateFrame = function(type, name, parent, template) end

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
		SetCVar = function(var, val) end,
	}

	_G.EditModeManagerFrame = {
		IsInMode = function() end,
	}
	_G.EventRegistry = {
		RegisterCallback = function(self, event, cb) end,
		SecureInsertEvent = function() end,
		UnregisterEvents = function() end,
		TriggerEvent = function() end,
		HasRegistrantsForEvent = function()
			return false
		end,
		GetCallbackTable = function()
			return {}
		end,
		SetUndefinedEventsAllowed = function() end,
		GetCallbacksByEvent = function()
			return {}
		end,
		GetCallbackTables = function()
			return {}
		end,
		DoesFrameHaveEvent = function()
			return false
		end,
		UnregisterCallback = function() end,
		OnLoad = function() end,
		RegisterCallbackWithHandle = function() end,
		GenerateCallbackEvents = function() end,
	}

	_G.UIParent = {
		CreateFontString = function()
			return {
				Hide = function() end,
				SetFontObject = function() end,
				SetText = function() end,
				SetPoint = function() end,
			}
		end,
		firstTimeLoaded = 0,
		variablesLoaded = true,
		RotateTextures = function() end,
		GetClampRectInsets = function() end,
		EnableGamePadButton = function() end,
		IsClampedToScreen = function() end,
		IsResizable = function() end,
		GetHyperlinksEnabled = function() end,
		StartSizing = function() end,
		SetUserPlaced = function() end,
		SetIgnoreParentAlpha = function() end,
		GetDontSavePosition = function() end,
		HookScript = function() end,
		IsEventRegistered = function() end,
		GetFrameStrata = function() end,
		Show = function() end,
		StartMoving = function() end,
		GetRegions = function() end,
		GetEffectiveAlpha = function() end,
		SetMovable = function() end,
		GetRaisedFrameLevel = function() end,
		SetHitRectInsets = function() end,
		IsUserPlaced = function() end,
		GetFrameLevel = function() end,
		IsVisible = function() end,
		EnableDrawLayer = function() end,
		IsShown = function() end,
		SetFlattensRenderLayers = function() end,
		IsGamePadStickEnabled = function() end,
		SetResizeBounds = function() end,
		GetHitRectInsets = function() end,
		GetEffectiveScale = function() end,
		Hide = function() end,
		HasFixedFrameStrata = function() end,
		RegisterEvent = function() end,
		IsToplevel = function() end,
		GetEffectivelyFlattensRenderLayers = function() end,
		IsObjectLoaded = function() end,
		AbortDrag = function() end,
		UnregisterAllEvents = function() end,
		ExecuteAttribute = function() end,
		GetNumChildren = function() end,
		SetIgnoreParentScale = function() end,
		SetScale = function() end,
		IsIgnoringParentScale = function() end,
		SetClampedToScreen = function() end,
		GetScale = function() end,
		StopMovingOrSizing = function() end,
		SetIsFrameBuffer = function() end,
		SetShown = function() end,
		HasScript = function() end,
		InterceptStartDrag = function() end,
		UnregisterEvent = function() end,
		CreateTexture = function() end,
		SetAlpha = function() end,
		GetParent = function() end,
		SetToplevel = function() end,
		GetScript = function() end,
		IsGamePadButtonEnabled = function() end,
		DoesClipChildren = function() end,
		IsKeyboardEnabled = function() end,
		DesaturateHierarchy = function() end,
		SetResizable = function() end,
		RegisterUnitEvent = function() end,
		GetBoundsRect = function() end,
		SetID = function() end,
		EnableKeyboard = function() end,
		SetHyperlinksEnabled = function() end,
		Lower = function() end,
		GetAlpha = function() end,
		GetChildren = function() end,
		SetScript = function() end,
		SetClampRectInsets = function() end,
		SetFixedFrameLevel = function() end,
		CreateLine = function() end,
		GetResizeBounds = function() end,
		SetDrawLayerEnabled = function() end,
		GetAttribute = function() end,
		GetPropagateKeyboardInput = function() end,
		DisableDrawLayer = function() end,
		HasFixedFrameLevel = function() end,
		UnlockHighlight = function() end,
		IsMovable = function() end,
		Raise = function() end,
		GetNumRegions = function() end,
		IsIgnoringParentAlpha = function() end,
		EnableGamePadStick = function() end,
		SetFrameStrata = function() end,
		CanChangeAttribute = function() end,
		SetFrameLevel = function() end,
		SetPropagateKeyboardInput = function() end,
		RegisterAllEvents = function() end,
		SetAttributeNoHandler = function() end,
		SetAttribute = function() end,
		SetFixedFrameStrata = function() end,
		SetClipsChildren = function() end,
		SetDontSavePosition = function() end,
		RegisterForDrag = function() end,
		GetFlattensRenderLayers = function() end,
		LockHighlight = function() end,
		CreateMaskTexture = function() end,
		GetID = function() end,
		SetDrawLayer = function() end,
		GetDrawLayer = function() end,
		SetVertexColor = function() end,
		GetVertexColor = function() end,
		SetMouseMotionEnabled = function() end,
		SetParent = function() end,
		EnableMouse = function() end,
		GetBottom = function() end,
		GetRight = function() end,
		SetPassThroughButtons = function() end,
		IsProtected = function() end,
		GetRect = function() end,
		IsMouseEnabled = function() end,
		CanChangeProtectedState = function() end,
		GetHeight = function() end,
		GetWidth = function() end,
		IsAnchoringRestricted = function() end,
		SetCollapsesLayout = function() end,
		IsDragging = function() end,
		SetMouseClickEnabled = function() end,
		IsMouseMotionFocus = function() end,
		AdjustPointsOffset = function() end,
		IsMouseMotionEnabled = function() end,
		IsRectValid = function() end,
		GetCenter = function() end,
		EnableMouseWheel = function() end,
		CollapsesLayout = function() end,
		IsMouseClickEnabled = function() end,
		GetSourceLocation = function() end,
		IsMouseWheelEnabled = function() end,
		GetTop = function() end,
		GetLeft = function() end,
		GetScaledRect = function() end,
		IsMouseOver = function() end,
		EnableMouseMotion = function() end,
		GetSize = function() end,
		IsCollapsed = function() end,
		GetParentKey = function() end,
		GetDebugName = function() end,
		SetParentKey = function() end,
		ClearParentKey = function() end,
		GetObjectType = function() end,
		IsForbidden = function() end,
		IsObjectType = function() end,
		SetForbidden = function() end,
		GetName = function() end,
		SetWidth = function() end,
		SetSize = function() end,
		ClearAllPoints = function() end,
		GetNumPoints = function() end,
		SetAllPoints = function() end,
		GetPointByName = function() end,
		ClearPoint = function() end,
		ClearPointsOffset = function() end,
		SetPoint = function() end,
		SetHeight = function() end,
		GetPoint = function() end,
		GetAnimationGroups = function() end,
		CreateAnimationGroup = function() end,
		StopAnimating = function() end,
	}

	_G.date = function(format)
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
	---@diagnostic disable-next-line: undefined-field
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

	_G.MuteSoundFile = function(sound) end
	_G.UnmuteSoundFile = function(sound) end
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
	_G.ACCOUNT_WIDE_FONT_COLOR = {
		r = 0,
		g = 0,
		b = 1,
		WrapTextInColorCode = function(text)
			return text
		end,
		GetRGB = function(self)
			return self.r, self.g, self.b
		end,
		IsEqualTo = function(self, other)
			return self.r == other.r and self.g == other.g and self.b == other.b
		end,
		SetRGB = function(self, r, g, b)
			self.r, self.g, self.b = r, g, b
		end,
		GetRGBA = function(self)
			return self.r, self.g, self.b, 1
		end,
		GenerateHexColorMarkup = function(self)
			return string.format("|cff%02x%02x%02x", self.r * 255, self.g * 255, self.b * 255)
		end,
		GenerateHexColor = function(self)
			return string.format("%02x%02x%02x", self.r * 255, self.g * 255, self.b * 255)
		end,
		GetRGBAsBytes = function(self)
			return self.r * 255, self.g * 255, self.b * 255
		end,
		SetRGBA = function(self, r, g, b, a)
			self.r, self.g, self.b, self.a = r, g, b, a or 1
		end,
		GetRGBAAsBytes = function(self)
			return self.r * 255, self.g * 255, self.b * 255, (self.a or 1) * 255
		end,
	}
	_G.FACTION_GREEN_COLOR = {
		r = 0,
		g = 1,
		b = 0,
		WrapTextInColorCode = function(text)
			return text
		end,
		GetRGB = function(self)
			return self.r, self.g, self.b
		end,
		IsEqualTo = function(self, other)
			return self.r == other.r and self.g == other.g and self.b == other.b
		end,
		SetRGB = function(self, r, g, b)
			self.r, self.g, self.b = r, g, b
		end,
		GetRGBA = function(self)
			return self.r, self.g, self.b, 1
		end,
		GenerateHexColorMarkup = function(self)
			return string.format("|cff%02x%02x%02x", self.r * 255, self.g * 255, self.b * 255)
		end,
		GenerateHexColor = function(self)
			return string.format("%02x%02x%02x", self.r * 255, self.g * 255, self.b * 255)
		end,
		GetRGBAsBytes = function(self)
			return self.r * 255, self.g * 255, self.b * 255
		end,
		SetRGBA = function(self, r, g, b, a)
			self.r, self.g, self.b, self.a = r, g, b, a or 1
		end,
		GetRGBAAsBytes = function(self)
			return self.r * 255, self.g * 255, self.b * 255, (self.a or 1) * 255
		end,
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
		GetCurrentDelvesSeasonNumber = function()
			return 1
		end,
		GetFactionForCompanion = function(id)
			return 2640
		end,
	}
end

function common_stubs.stub_C_ClassColor()
	_G.C_ClassColor = {
		GetClassColor = function(class)
			return 0.78, 0.61, 0.43
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
	_G.UnitClass = function()
		return "Warrior", "WARRIOR", 1
	end
end

function common_stubs.stub_Money_Funcs()
	_G.GetMoney = function()
		return 123456
	end
end

return common_stubs
