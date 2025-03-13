---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

local Sizing = {}

G_RLF.defaults.global.sizing = {
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
			get = "GetFeedWidth",
			set = "SetFeedWidth",
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
			get = "GetMaxRows",
			set = "SetMaxRows",
			order = 2,
		},
		rowHeight = {
			type = "range",
			name = G_RLF.L["Loot Item Height"],
			desc = G_RLF.L["RowHeightDesc"],
			min = 5,
			max = 100,
			get = "GetRowHeight",
			set = "SetRowHeight",
			order = 3,
		},
		iconSize = {
			type = "range",
			name = G_RLF.L["Loot Item Icon Size"],
			desc = G_RLF.L["IconSizeDesc"],
			min = 5,
			max = 100,
			get = "GetIconSize",
			set = "SetIconSize",
			order = 4,
		},
		rowPadding = {
			type = "range",
			name = G_RLF.L["Loot Item Padding"],
			desc = G_RLF.L["RowPaddingDesc"],
			min = 0,
			max = 10,
			get = "GetRowPadding",
			set = "SetRowPadding",
			order = 5,
		},
	},
}

function Sizing:SetFeedWidth(info, value)
	G_RLF.db.global.sizing.feedWidthedWidth = value
	G_RLF.LootDisplay:UpdateRowStyles()
end

function Sizing:GetFeedWidth(info)
	return G_RLF.db.global.sizing.feedWidthedWidth
end

function Sizing:SetMaxRows(info, value)
	G_RLF.db.global.sizing.maxRows = value
	G_RLF.LootDisplay:UpdateRowStyles()
end

function Sizing:GetMaxRows(info)
	return G_RLF.db.global.sizing.maxRows
end

function Sizing:SetRowHeight(info, value)
	G_RLF.db.global.sizing.rowHeight = value
	G_RLF.LootDisplay:UpdateRowStyles()
end

function Sizing:GetRowHeight(info, value)
	return G_RLF.db.global.sizing.rowHeight
end

function Sizing:SetIconSize(info, value)
	G_RLF.db.global.sizing.iconSize = value
	G_RLF.LootDisplay:UpdateRowStyles()
end

function Sizing:GetIconSize(info, value)
	return G_RLF.db.global.sizing.iconSize
end

function Sizing:SetRowPadding(info, value)
	G_RLF.db.global.sizing.padding = value
	G_RLF.LootDisplay:UpdateRowStyles()
end

function Sizing:GetRowPadding(info, value)
	return G_RLF.db.global.sizing.padding
end
