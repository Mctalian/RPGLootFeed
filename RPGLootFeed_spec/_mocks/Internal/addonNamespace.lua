local busted = require("busted")
local stub = busted.stub
local embedLibs = require("RPGLootFeed_spec._mocks.Libs.embedLibUtil")
local addonNamespaceMocks = {}

--- @enum addonNamespaceMocks.LoadSections
addonNamespaceMocks.LoadSections = {
	None = 0,
	Core = 1,
	Locale = 2,
	UtilsAddonMethods = 3,
	UtilsAlphaHelpers = 4,
	UtilsList = 5,
	UtilsEnums = 6,
	UtilsGameVersionHelpers = 7,
	UtilsItemInfo = 8,
	UtilsLogger = 9,
	UtilsMaps = 10,
	UtilsQueue = 11,
	Config = 12,
	BlizzOverrides = 13,
	Features = 14,
	LootDisplay = 15,
	GameTesting = 16,
	All = 100,
}

--- Setup the namespace table based on the load order
--- @param loadSection addonNamespaceMocks.LoadSections The section of the addon that is being loaded
function addonNamespaceMocks:unitLoadedAfter(loadSection)
	---@class test_G_RLF: G_RLF
	local ns = {}
	if loadSection >= addonNamespaceMocks.LoadSections.Core then
		ns.addonVersion = "1.0.0"
		ns.localeName = "RPGLootFeedLocale"
		ns.lsm = {
			MediaType = {
				FONT = "font",
			},
		}
		addonNamespaceMocks.lsm = {}
		addonNamespaceMocks.lsm.HashTable = stub(ns.lsm, "HashTable")
		local iconGroupMock = {}
		addonNamespaceMocks.iconGroup = {}
		addonNamespaceMocks.iconGroup.AddButton = stub(iconGroupMock, "AddButton")
		addonNamespaceMocks.iconGroup.ReSkin = stub(iconGroupMock, "ReSkin")
		ns.Masque = {}
		addonNamespaceMocks.Masque = {}
		addonNamespaceMocks.Masque.Group = stub(ns.Masque, "Group").returns(iconGroupMock)
		ns.acd = {}
		ns.DBIcon = {}
		ns.db = {
			---@type RLF_DBGlobal
			global = {
				lastVersionLoaded = "v1.0.0",
				logger = {},
				migrationVersion = 0,
				animations = {
					exit = {},
				},
				blizzOverrides = {},
				currency = {},
				item = {
					itemQualitySettings = {},
				},
				prof = {
					skillColor = { 1, 1, 1, 1 },
				},
				partyLoot = {
					enabled = true,
					separateFrame = false,
					itemQualityFilter = {},
					hideServerNames = false,
					onlyEpicAndAboveInInstance = false,
					onlyEpicAndAboveInParty = false,
					onlyEpicAndAboveInRaid = false,
					positioning = {},
					sizing = {},
					styling = {},
					ignoreItemIds = {},
				},
				money = {},
				xp = {
					experienceTextColor = { 1, 1, 1, 1 },
				},
				rep = {
					defaultRepColor = { 1, 1, 1, 1 },
				},
				styling = {},
				lootHistory = {},
				minimap = {},
				tooltips = {},
				sizing = {},
				positioning = {},
			},
			locale = {
				factionMap = {},
			},
			profile = {},
		}
		ns.RLF = {}
		embedLibs(ns.RLF, "AceAddon-3.0")
		ns.RLF:NewAddon("RPGLootFeed", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")
	end
	if loadSection >= addonNamespaceMocks.LoadSections.Locale then
		ns.L = {
			Welcome = "Welcome",
			Issues = "Issues",
		}
	end
	if loadSection >= addonNamespaceMocks.LoadSections.UtilsAddonMethods then
		addonNamespaceMocks.fn = stub(ns, "fn", function(s, func, ...)
			if type(func) == "function" then
				return xpcall(func, _G.handledError, ...)
			end
		end)
		addonNamespaceMocks.NotifyChange = stub(ns, "NotifyChange")
		addonNamespaceMocks.Print = stub(ns, "Print")
		addonNamespaceMocks.IsRetail = stub(ns, "IsRetail").returns(true)
		addonNamespaceMocks.IsClassic = stub(ns, "IsClassic").returns(false)
		addonNamespaceMocks.IsCataClassic = stub(ns, "IsCataClassic").returns(false)
		addonNamespaceMocks.SendMessage = stub(ns, "SendMessage")
		addonNamespaceMocks.RGBAToHexFormat = stub(ns, "RGBAToHexFormat")
		addonNamespaceMocks.LogDebug = stub(ns, "LogDebug")
		addonNamespaceMocks.LogInfo = stub(ns, "LogInfo")
		addonNamespaceMocks.LogWarn = stub(ns, "LogWarn")
		addonNamespaceMocks.LogError = stub(ns, "LogError")
		addonNamespaceMocks.CreatePatternSegmentsForStringNumber = stub(ns, "CreatePatternSegmentsForStringNumber")
		addonNamespaceMocks.ExtractDynamicsFromPattern = stub(ns, "ExtractDynamicsFromPattern")
		addonNamespaceMocks.OpenOptions = stub(ns, "OpenOptions")
		addonNamespaceMocks.TableToCommaSeparatedString = stub(ns, "TableToCommaSeparatedString")
		addonNamespaceMocks.FontFlagsToString = stub(ns, "FontFlagsToString")
	end
	if loadSection >= addonNamespaceMocks.LoadSections.UtilsAlphaHelpers then
		addonNamespaceMocks.dump = stub(ns, "dump")
		addonNamespaceMocks.ProfileFunction = stub(ns, "ProfileFunction")
	end
	if loadSection >= addonNamespaceMocks.LoadSections.UtilsList then
		---@class test_list: list
		ns.list = {}
		addonNamespaceMocks.list = {}
		addonNamespaceMocks.list.push = stub(ns.list, "push")
		addonNamespaceMocks.list.unshift = stub(ns.list, "unshift")
		addonNamespaceMocks.list.pop = stub(ns.list, "pop")
		addonNamespaceMocks.list.shift = stub(ns.list, "shift")
		addonNamespaceMocks.list.remove = stub(ns.list, "remove")
		addonNamespaceMocks.list.iterate = stub(ns.list, "iterate")
	end
	if loadSection >= addonNamespaceMocks.LoadSections.UtilsEnums then
		require("RPGLootFeed_spec._mocks.WoWGlobals.Functions")
		require("RPGLootFeed_spec._mocks.WoWGlobals.Enum")
		assert(loadfile("RPGLootFeed/utils/Enums.lua"))("TestAddon", ns)
	end
	if loadSection >= addonNamespaceMocks.LoadSections.UtilsGameVersionHelpers then
		ns.ClassicToRetail = {}
		addonNamespaceMocks.ClassicToRetail = {}
		addonNamespaceMocks.ClassicToRetail.ConvertFactionInfoByID = stub(ns.ClassicToRetail, "ConvertFactionInfoByID")
		addonNamespaceMocks.ClassicToRetail.ConvertFactionInfoByIndex =
			stub(ns.ClassicToRetail, "ConvertFactionInfoByIndex")
	end
	if loadSection >= addonNamespaceMocks.LoadSections.UtilsItemInfo then
		ns.ItemInfo = {}
		addonNamespaceMocks.ItemInfo = {}
		addonNamespaceMocks.ItemInfo.new = stub(ns.ItemInfo, "new")
		addonNamespaceMocks.ItemInfo.IsMount = stub(ns.ItemInfo, "IsMount")
		addonNamespaceMocks.ItemInfo.IsLegendary = stub(ns.ItemInfo, "IsLegendary")
		addonNamespaceMocks.ItemInfo.IsEligibleEquipment = stub(ns.ItemInfo, "IsEligibleEquipment")
	end
	if loadSection >= addonNamespaceMocks.LoadSections.UtilsLogger then
	end
	if loadSection >= addonNamespaceMocks.LoadSections.UtilsMaps then
		assert(loadfile("RPGLootFeed/utils/Maps.lua"))("TestAddon", ns)
	end
	if loadSection >= addonNamespaceMocks.LoadSections.UtilsQueue then
		ns.Queue = {}
		addonNamespaceMocks.Queue = {}
		addonNamespaceMocks.Queue.new = stub(ns.Queue, "new")
		addonNamespaceMocks.Queue.enqueue = stub(ns.Queue, "enqueue")
		addonNamespaceMocks.Queue.dequeue = stub(ns.Queue, "dequeue")
		addonNamespaceMocks.Queue.isEmpty = stub(ns.Queue, "isEmpty")
		addonNamespaceMocks.Queue.peek = stub(ns.Queue, "peek")
		addonNamespaceMocks.Queue.size = stub(ns.Queue, "size")
	end
	if loadSection >= addonNamespaceMocks.LoadSections.Config then
		ns.ConfigHandlers = {
			PartyLootConfig = {},
		}
		addonNamespaceMocks.ConfigHandlers = {}
		addonNamespaceMocks.ConfigHandlers.PartyLootConfig = {}
		addonNamespaceMocks.ConfigHandlers.PartyLootConfig.GetPositioningOptions =
			stub(ns.ConfigHandlers.PartyLootConfig, "GetPositioningOptions")
		addonNamespaceMocks.ConfigHandlers.PartyLootConfig.GetSizingOptions =
			stub(ns.ConfigHandlers.PartyLootConfig, "GetSizingOptions")
		addonNamespaceMocks.ConfigHandlers.PartyLootConfig.GetStylingOptions =
			stub(ns.ConfigHandlers.PartyLootConfig, "GetStylingOptions")
		ns.defaults = {
			global = {
				lastVersionLoaded = "v1.0.0",
				logger = {},
				migrationVersion = 0,
			},
			locale = {
				factionMap = {},
			},
			profile = {},
		}
		ns.options = {
			args = {},
		}
		ns.mainFeatureOrder = {
			ItemLoot = 1,
			PartyLoot = 2,
			Currency = 3,
			Money = 4,
			XP = 5,
			Rep = 6,
			Skills = 7,
		}
		ns.DbMigrations = {}
		addonNamespaceMocks.DbMigrations = {}
		addonNamespaceMocks.DbMigrations.Migrate = stub(ns.DbMigrations, "Migrate")
		ns.migrations = {}
		ns.DbAccessor = {}
		addonNamespaceMocks.DbAccessor = {}
		addonNamespaceMocks.DbAccessor.Sizing = stub(ns.DbAccessor, "Sizing")
		addonNamespaceMocks.DbAccessor.Positioning = stub(ns.DbAccessor, "Positioning")
		addonNamespaceMocks.DbAccessor.Styling = stub(ns.DbAccessor, "Styling")
		addonNamespaceMocks.ShouldRunMigration = stub(ns, "ShouldRunMigration").returns(false)
	end
	if loadSection >= addonNamespaceMocks.LoadSections.BlizzOverrides then
		addonNamespaceMocks.retryHook = stub(ns, "retryHook")
	end
	if loadSection >= addonNamespaceMocks.LoadSections.Features then
		addonNamespaceMocks.InitializeLootDisplayProperties = stub(ns, "InitializeLootDisplayProperties")
		ns.AuctionIntegrations = {}
		addonNamespaceMocks.AuctionIntegrations = {}
		addonNamespaceMocks.AuctionIntegrations.Init = stub(ns.AuctionIntegrations, "Init")
		addonNamespaceMocks.AuctionIntegrations.GetAHPrice = stub(ns.AuctionIntegrations, "GetAHPrice")
		assert(loadfile("RPGLootFeed/Features/Currency/HiddenCurrencies.lua"))("TestAddon", ns)
	end
	if loadSection >= addonNamespaceMocks.LoadSections.LootDisplay then
		assert(loadfile("RPGLootFeed/LootDisplay/LootDisplayFrame/LootDisplayFrame.lua"))("TestAddon", ns)
		assert(loadfile("RPGLootFeed/LootDisplay/LootDisplayFrame/LootDisplayRow/LootDisplayRow.lua"))("TestAddon", ns)
		ns.tempFontString = nil
		ns.LootDisplay = {}
		embedLibs(ns.LootDisplay, "AceBucket-3.0", "AceEvent-3.0", "AceHook-3.0")
		addonNamespaceMocks.LootDisplay = {}
		addonNamespaceMocks.LootDisplay.OnPlayerCombatChange = stub(ns.LootDisplay, "OnPlayerCombatChange")
		addonNamespaceMocks.LootDisplay.CreatePartyFrame = stub(ns.LootDisplay, "CreatePartyFrame")
		addonNamespaceMocks.LootDisplay.DestroyPartyFrame = stub(ns.LootDisplay, "DestroyPartyFrame")
		addonNamespaceMocks.LootDisplay.SetBoundingBoxVisibility = stub(ns.LootDisplay, "SetBoundingBoxVisibility")
		addonNamespaceMocks.LootDisplay.ToggleBoundingBox = stub(ns.LootDisplay, "ToggleBoundingBox")
		addonNamespaceMocks.LootDisplay.UpdatePosition = stub(ns.LootDisplay, "UpdatePosition")
		addonNamespaceMocks.LootDisplay.UpdateRowPositions = stub(ns.LootDisplay, "UpdateRowPositions")
		addonNamespaceMocks.LootDisplay.UpdateStrata = stub(ns.LootDisplay, "UpdateStrata")
		addonNamespaceMocks.LootDisplay.UpdateRowStyles = stub(ns.LootDisplay, "UpdateRowStyles")
		addonNamespaceMocks.LootDisplay.UpdateEnterAnimation = stub(ns.LootDisplay, "UpdateEnterAnimation")
		addonNamespaceMocks.LootDisplay.UpdateFadeDelay = stub(ns.LootDisplay, "UpdateFadeDelay")
		addonNamespaceMocks.LootDisplay.BAG_UPDATE_DELAY = stub(ns.LootDisplay, "BAG_UPDATE_DELAY")
		addonNamespaceMocks.LootDisplay.OnLootReady = stub(ns.LootDisplay, "OnLootReady")
		addonNamespaceMocks.LootDisplay.OnPartyLootReady = stub(ns.LootDisplay, "OnPartyLootReady")
		addonNamespaceMocks.LootDisplay.OnRowReturn = stub(ns.LootDisplay, "OnRowReturn")
		addonNamespaceMocks.LootDisplay.OnPartyRowReturn = stub(ns.LootDisplay, "OnPartyRowReturn")
		addonNamespaceMocks.LootDisplay.HideLoot = stub(ns.LootDisplay, "HideLoot")
		addonNamespaceMocks.CalculateTextWidth = stub(ns, "CalculateTextWidth").returns(80)
		addonNamespaceMocks.TruncateItemLink = stub(ns, "TruncateItemLink")
	end
	-- No namespace changes in GameTesting
	-- if loadSection >= addonNamespaceMocks.LoadSections.GameTesting then
	-- end

	return ns
end

return addonNamespaceMocks
