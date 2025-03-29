---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

G_RLF.ConfigHandlers = {}

local ConfigOptions = {}

---@class RLF_DB
G_RLF.defaults = {
	---@class RLF_DBProfile
	profile = {},
	---@class RLF_DBLocale
	locale = {
		factionMap = {},
	},
	---@class RLF_DBGlobal
	global = {
		lastVersionLoaded = "v1.0.0",
		logger = {},
		migrationVersion = 0,
	},
}

G_RLF.options = {
	name = addonName,
	handler = ConfigOptions,
	type = "group",
	args = {
		testMode = {
			type = "execute",
			name = G_RLF.L["Toggle Test Mode"],
			func = "ToggleTestMode",
			order = 1,
		},
		clearRows = {
			type = "execute",
			name = G_RLF.L["Clear rows"],
			func = "ClearRows",
			order = 2,
		},
		lootHistory = {
			type = "execute",
			name = G_RLF.L["Toggle Loot History"],
			func = "ToggleLootHistory",
			order = 3,
		},
	},
}

function ConfigOptions:ToggleBoundingBox()
	G_RLF.LootDisplay:ToggleBoundingBox()
end

local TestMode
function ConfigOptions:ToggleTestMode()
	TestMode = TestMode or G_RLF.RLF:GetModule("TestMode") --[[@as RLF_TestMode]]
	TestMode:ToggleTestMode()
end

function ConfigOptions:ClearRows()
	G_RLF.LootDisplay:HideLoot()
end

function ConfigOptions:ToggleLootHistory()
	---@type RLF_LootDisplayFrame
	local frame = G_RLF.RLF_MainLootFrame
	frame:ToggleHistoryFrame()
	local partyFrame = G_RLF.RLF_PartyLootFrame
	if partyFrame then
		partyFrame:ToggleHistoryFrame()
	end
end
