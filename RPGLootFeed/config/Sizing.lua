---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

local Sizing = {}

---@class RLF_DBGlobal
local globalDefaults = G_RLF.defaults.global

---@class RLF_ConfigSizing
globalDefaults.sizing = {
	feedWidth = 330,
	maxRows = 10,
	rowHeight = 22,
	padding = 2,
	iconSize = 18,
}

G_RLF.options.args.sizing = {
	type = "group",
	handler = Sizing,
	name = G_RLF.L["Sizing"],
	desc = G_RLF.L["SizingDesc"],
	order = 6,
	args = {
		feedWidth = {
			type = "range",
			name = G_RLF.L["Feed Width"],
			desc = G_RLF.L["FeedWidthDesc"],
			min = 10,
			max = 1000,
			get = function()
				return G_RLF.db.global.sizing.feedWidth
			end,
			set = function(_, value)
				G_RLF.db.global.sizing.feedWidth = value
				G_RLF.LootDisplay:UpdateRowStyles()
			end,
			order = 1,
		},
		maxRows = {
			type = "range",
			name = G_RLF.L["Maximum Rows to Display"],
			desc = G_RLF.L["MaxRowsDesc"],
			min = 1,
			softMin = 3,
			max = 20,
			step = 1,
			bigStep = 5,
			get = function()
				return G_RLF.db.global.sizing.maxRows
			end,
			set = function(_, value)
				G_RLF.db.global.sizing.maxRows = value
				G_RLF.LootDisplay:UpdateRowStyles()
			end,
			order = 2,
		},
		rowHeight = {
			type = "range",
			name = G_RLF.L["Loot Item Height"],
			desc = G_RLF.L["RowHeightDesc"],
			min = 5,
			max = 100,
			get = function()
				return G_RLF.db.global.sizing.rowHeight
			end,
			set = function(_, value)
				G_RLF.db.global.sizing.rowHeight = value
				G_RLF.LootDisplay:UpdateRowStyles()
			end,
			order = 3,
		},
		iconSize = {
			type = "range",
			name = G_RLF.L["Loot Item Icon Size"],
			desc = G_RLF.L["IconSizeDesc"],
			min = 5,
			max = 100,
			get = function()
				return G_RLF.db.global.sizing.iconSize
			end,
			set = function(_, value)
				G_RLF.db.global.sizing.iconSize = value
				G_RLF.LootDisplay:UpdateRowStyles()
			end,
			order = 4,
		},
		rowPadding = {
			type = "range",
			name = G_RLF.L["Loot Item Padding"],
			desc = G_RLF.L["RowPaddingDesc"],
			min = 0,
			max = 10,
			get = function()
				return G_RLF.db.global.sizing.padding
			end,
			set = function(_, value)
				G_RLF.db.global.sizing.padding = value
				G_RLF.LootDisplay:UpdateRowStyles()
			end,
			order = 5,
		},
		partyLootFrame = G_RLF.ConfigHandlers.PartyLootConfig:GetSizingOptions(6),
	},
}
