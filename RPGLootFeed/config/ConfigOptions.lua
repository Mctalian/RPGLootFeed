---@type string, G_RLF
local addonName, G_RLF = ...

local ConfigOptions = {}

G_RLF.WrapCharOptions = {
	[G_RLF.WrapCharEnum.SPACE] = G_RLF.L["Spaces"],
	[G_RLF.WrapCharEnum.PARENTHESIS] = G_RLF.L["Parentheses"],
	[G_RLF.WrapCharEnum.BRACKET] = G_RLF.L["Square Brackets"],
	[G_RLF.WrapCharEnum.BRACE] = G_RLF.L["Curly Braces"],
	[G_RLF.WrapCharEnum.ANGLE] = G_RLF.L["Angle Brackets"],
	[G_RLF.WrapCharEnum.BAR] = G_RLF.L["Bars"],
}

G_RLF.defaults = {
	profile = {},
	locale = {
		factionMap = {},
	},
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
	TestMode = TestMode or G_RLF.RLF:GetModule("TestMode")
	TestMode:ToggleTestMode()
end

function ConfigOptions:ClearRows()
	G_RLF.LootDisplay:HideLoot()
end

function ConfigOptions:ToggleLootHistory()
	---@type RLF_LootDisplayFrame
	local frame = LootDisplayFrame
	frame:ToggleHistoryFrame()
end
