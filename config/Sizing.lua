local addonName, G_RLF = ...

local Sizing = {}

G_RLF.defaults.global.feedWidth = 330
G_RLF.defaults.global.maxRows = 10
G_RLF.defaults.global.rowHeight = 22
G_RLF.defaults.global.padding = 2
G_RLF.defaults.global.iconSize = 18

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
	G_RLF.db.global.feedWidth = value
	G_RLF.LootDisplay:UpdateRowStyles()
end

function Sizing:GetFeedWidth(info)
	return G_RLF.db.global.feedWidth
end

function Sizing:SetMaxRows(info, value)
	G_RLF.db.global.maxRows = value
	G_RLF.LootDisplay:UpdateRowStyles()
end

function Sizing:GetMaxRows(info)
	return G_RLF.db.global.maxRows
end

function Sizing:SetRowHeight(info, value)
	G_RLF.db.global.rowHeight = value
	G_RLF.LootDisplay:UpdateRowStyles()
end

function Sizing:GetRowHeight(info, value)
	return G_RLF.db.global.rowHeight
end

function Sizing:SetIconSize(info, value)
	G_RLF.db.global.iconSize = value
	G_RLF.LootDisplay:UpdateRowStyles()
end

function Sizing:GetIconSize(info, value)
	return G_RLF.db.global.iconSize
end

function Sizing:SetRowPadding(info, value)
	G_RLF.db.global.padding = value
	G_RLF.LootDisplay:UpdateRowStyles()
end

function Sizing:GetRowPadding(info, value)
	return G_RLF.db.global.padding
end
