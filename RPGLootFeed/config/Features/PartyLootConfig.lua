---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

local PartyLootConfig = {}

---@class RLF_DBGlobal
---@field partyLoot RLF_ConfigPartyLoot
local globalDefaults = G_RLF.defaults.global

---@class RLF_ConfigPartyLoot
G_RLF.defaults.global.partyLoot = {
	enabled = false,
	separateFrame = false,
	itemQualityFilter = {
		[G_RLF.ItemQualEnum.Poor] = true,
		[G_RLF.ItemQualEnum.Common] = true,
		[G_RLF.ItemQualEnum.Uncommon] = true,
		[G_RLF.ItemQualEnum.Rare] = true,
		[G_RLF.ItemQualEnum.Epic] = true,
		[G_RLF.ItemQualEnum.Legendary] = true,
		[G_RLF.ItemQualEnum.Artifact] = true,
		[G_RLF.ItemQualEnum.Heirloom] = true,
	},
	hideServerNames = false,
	onlyEpicAndAboveInRaid = true,
	onlyEpicAndAboveInInstance = true,
	---@type RLF_ConfigPositioning
	positioning = {
		---@type string | ScriptRegion
		relativePoint = "UIParent",
		anchorPoint = "LEFT",
		xOffset = 0,
		yOffset = 375,
		frameStrata = "MEDIUM",
	},
	---@type RLF_ConfigSizing
	sizing = {
		feedWidth = 330,
		maxRows = 10,
		rowHeight = 22,
		padding = 2,
		iconSize = 18,
	},
	---@type number[]
	ignoreItemIds = {},
}

G_RLF.options.args.features.args.partyLootConfig = {
	type = "group",
	handler = PartyLootConfig,
	name = G_RLF.L["Party Loot Config"],
	order = G_RLF.mainFeatureOrder.PartyLoot,
	args = {
		enablePartyLoot = {
			type = "toggle",
			name = G_RLF.L["Enable Party Loot in Feed"],
			desc = G_RLF.L["EnablePartyLootDesc"],
			width = "double",
			get = function()
				return G_RLF.db.global.partyLoot.enabled
			end,
			set = function(_, value)
				G_RLF.db.global.partyLoot.enabled = value
			end,
			order = 1,
		},
		partyLootOptions = {
			type = "group",
			inline = true,
			name = G_RLF.L["Party Loot Options"],
			disabled = function()
				return not G_RLF.db.global.partyLoot.enabled
			end,
			order = 2,
			args = {
				separateFrame = {
					type = "toggle",
					name = G_RLF.L["Separate Frame"],
					desc = G_RLF.L["SeparateFrameDesc"],
					width = "double",
					get = function()
						return G_RLF.db.global.partyLoot.separateFrame
					end,
					set = function(_, value)
						G_RLF.db.global.partyLoot.separateFrame = value
					end,
					order = 1,
				},
				positioning = {
					type = "group",
					name = G_RLF.L["Positioning"],
					hidden = function()
						return not G_RLF.db.global.partyLoot.separateFrame
					end,
					order = 1.1,
					args = {
						relativePoint = {
							type = "select",
							name = G_RLF.L["Anchor Relative To"],
							desc = G_RLF.L["RelativeToDesc"],
							values = {
								["UIParent"] = G_RLF.L["UIParent"],
								["PlayerFrame"] = G_RLF.L["PlayerFrame"],
								["Minimap"] = G_RLF.L["Minimap"],
								["MainMenuBarBackpackButton"] = G_RLF.L["BagBar"],
							},
							get = function()
								return G_RLF.db.global.partyLoot.positioning.relativePoint
							end,
							set = function(_, value)
								G_RLF.db.global.partyLoot.positioning.relativePoint = value
								G_RLF.LootDisplay:UpdatePosition(G_RLF.Frames.PARTY)
							end,
							order = 1,
						},
						anchorPoint = {
							type = "select",
							name = G_RLF.L["Anchor Point"],
							desc = G_RLF.L["AnchorPointDesc"],
							values = {
								["TOPLEFT"] = G_RLF.L["Top Left"],
								["TOPRIGHT"] = G_RLF.L["Top Right"],
								["BOTTOMLEFT"] = G_RLF.L["Bottom Left"],
								["BOTTOMRIGHT"] = G_RLF.L["Bottom Right"],
								["TOP"] = G_RLF.L["Top"],
								["BOTTOM"] = G_RLF.L["Bottom"],
								["LEFT"] = G_RLF.L["Left"],
								["RIGHT"] = G_RLF.L["Right"],
								["CENTER"] = G_RLF.L["Center"],
							},
							get = function()
								return G_RLF.db.global.partyLoot.positioning.anchorPoint
							end,
							set = function(_, value)
								G_RLF.db.global.partyLoot.positioning.anchorPoint = value
								G_RLF.LootDisplay:UpdatePosition(G_RLF.Frames.PARTY)
							end,
							order = 2,
						},
						xOffset = {
							type = "range",
							name = G_RLF.L["X Offset"],
							desc = G_RLF.L["XOffsetDesc"],
							min = -1000,
							max = 1000,
							step = 1,
							get = function()
								return G_RLF.db.global.partyLoot.positioning.xOffset
							end,
							set = function(_, value)
								G_RLF.db.global.partyLoot.positioning.xOffset = value
								G_RLF.LootDisplay:UpdatePosition(G_RLF.Frames.PARTY)
							end,
							order = 3,
						},
						yOffset = {
							type = "range",
							name = G_RLF.L["Y Offset"],
							desc = G_RLF.L["YOffsetDesc"],
							min = -1000,
							max = 1000,
							step = 1,
							get = function()
								return G_RLF.db.global.partyLoot.positioning.yOffset
							end,
							set = function(_, value)
								G_RLF.db.global.partyLoot.positioning.yOffset = value
								G_RLF.LootDisplay:UpdatePosition(G_RLF.Frames.PARTY)
							end,
							order = 4,
						},
						frameStrata = {
							type = "select",
							name = G_RLF.L["Frame Strata"],
							desc = G_RLF.L["FrameStrataDesc"],
							values = {
								["BACKGROUND"] = G_RLF.L["Background"],
								["LOW"] = G_RLF.L["Low"],
								["MEDIUM"] = G_RLF.L["Medium"],
								["HIGH"] = G_RLF.L["High"],
								["DIALOG"] = G_RLF.L["Dialog"],
								["TOOLTIP"] = G_RLF.L["Tooltip"],
							},
							sorting = {
								"BACKGROUND",
								"LOW",
								"MEDIUM",
								"HIGH",
								"DIALOG",
								"TOOLTIP",
							},
							get = function()
								return G_RLF.db.global.partyLoot.positioning.frameStrata
							end,
							set = function(_, value)
								G_RLF.db.global.partyLoot.positioning.frameStrata = value
								G_RLF.LootDisplay:UpdateStrata(G_RLF.Frames.PARTY)
							end,
							order = 5,
						},
					},
				},
				sizing = {
					type = "group",
					hidden = function()
						return not G_RLF.db.global.partyLoot.separateFrame
					end,
					name = G_RLF.L["Sizing"],
					order = 1.2,
					args = {
						feedWidth = {
							type = "range",
							name = G_RLF.L["Feed Width"],
							desc = G_RLF.L["FeedWidthDesc"],
							min = 100,
							max = 1000,
							step = 1,
							get = function()
								return G_RLF.db.global.partyLoot.sizing.feedWidth
							end,
							set = function(_, value)
								G_RLF.db.global.partyLoot.sizing.feedWidth = value
								G_RLF.LootDisplay:UpdateRowStyles(G_RLF.Frames.PARTY)
							end,
							order = 1,
						},
						maxRows = {
							type = "range",
							name = G_RLF.L["Maximum Rows to Display"],
							desc = G_RLF.L["MaxRowsDesc"],
							min = 1,
							max = 100,
							step = 1,
							get = function()
								return G_RLF.db.global.partyLoot.sizing.maxRows
							end,
							set = function(_, value)
								G_RLF.db.global.partyLoot.sizing.maxRows = value
								G_RLF.LootDisplay:UpdateRowStyles(G_RLF.Frames.PARTY)
							end,
							order = 2,
						},
						rowHeight = {
							type = "range",
							name = G_RLF.L["Loot Item Height"],
							desc = G_RLF.L["RowHeightDesc"],
							min = 5,
							max = 100,
							step = 1,
							get = function()
								return G_RLF.db.global.partyLoot.sizing.rowHeight
							end,
							set = function(_, value)
								G_RLF.db.global.partyLoot.sizing.rowHeight = value
								G_RLF.LootDisplay:UpdateRowStyles(G_RLF.Frames.PARTY)
							end,
							order = 3,
						},
						iconSize = {
							type = "range",
							name = G_RLF.L["Loot Item Icon Size"],
							desc = G_RLF.L["IconSizeDesc"],
							min = 5,
							max = 100,
							step = 1,
							get = function()
								return G_RLF.db.global.partyLoot.sizing.iconSize
							end,
							set = function(_, value)
								G_RLF.db.global.partyLoot.sizing.iconSize = value
								G_RLF.LootDisplay:UpdateRowStyles(G_RLF.Frames.PARTY)
							end,
							order = 4,
						},
						padding = {
							type = "range",
							name = G_RLF.L["Loot Item Padding"],
							desc = G_RLF.L["RowPaddingDesc"],
							min = 0,
							max = 10,
							step = 1,
							get = function()
								return G_RLF.db.global.partyLoot.sizing.padding
							end,
							set = function(_, value)
								G_RLF.db.global.partyLoot.sizing.padding = value
								G_RLF.LootDisplay:UpdateRowStyles(G_RLF.Frames.PARTY)
							end,
							order = 5,
						},
					},
				},
				hideServerNames = {
					type = "toggle",
					name = G_RLF.L["Hide Server Names"],
					desc = G_RLF.L["HideServerNamesDesc"],
					width = "double",
					get = function()
						return G_RLF.db.global.partyLoot.hideServerNames
					end,
					set = function(_, value)
						G_RLF.db.global.partyLoot.hideServerNames = value
					end,
					order = 1.5,
				},
				itemQualityFilter = {
					type = "multiselect",
					name = G_RLF.L["Party Item Quality Filter"],
					desc = G_RLF.L["PartyItemQualityFilterDesc"],
					values = {
						[G_RLF.ItemQualEnum.Poor] = G_RLF.L["Poor"],
						[G_RLF.ItemQualEnum.Common] = G_RLF.L["Common"],
						[G_RLF.ItemQualEnum.Uncommon] = G_RLF.L["Uncommon"],
						[G_RLF.ItemQualEnum.Rare] = G_RLF.L["Rare"],
						[G_RLF.ItemQualEnum.Epic] = G_RLF.L["Epic"],
						[G_RLF.ItemQualEnum.Legendary] = G_RLF.L["Legendary"],
						[G_RLF.ItemQualEnum.Artifact] = G_RLF.L["Artifact"],
						[G_RLF.ItemQualEnum.Heirloom] = G_RLF.L["Heirloom"],
					},
					get = function(_, key)
						return G_RLF.db.global.partyLoot.itemQualityFilter[key]
					end,
					set = function(_, key, value)
						G_RLF.db.global.partyLoot.itemQualityFilter[key] = value
					end,
					order = 2,
				},
				onlyEpicAndAboveInRaid = {
					type = "toggle",
					name = G_RLF.L["Only Epic and Above in Raid"],
					desc = G_RLF.L["OnlyEpicAndAboveInRaidDesc"],
					width = "double",
					get = function()
						return G_RLF.db.global.partyLoot.onlyEpicAndAboveInRaid
					end,
					set = function(_, value)
						G_RLF.db.global.partyLoot.onlyEpicAndAboveInRaid = value
						local partyLoot = G_RLF.RLF:GetModule("PartyLoot") --[[@as RLF_PartyLoot]]
						partyLoot:SetPartyLootFilters()
					end,
					order = 3,
				},
				onlyEpicAndAboveInInstance = {
					type = "toggle",
					name = G_RLF.L["Only Epic and Above in Instance"],
					desc = G_RLF.L["OnlyEpicAndAboveInInstanceDesc"],
					width = "double",
					get = function()
						return G_RLF.db.global.partyLoot.onlyEpicAndAboveInInstance
					end,
					set = function(_, value)
						G_RLF.db.global.partyLoot.onlyEpicAndAboveInInstance = value
						local partyLoot = G_RLF.RLF:GetModule("PartyLoot") --[[@as RLF_PartyLoot]]
						partyLoot:SetPartyLootFilters()
					end,
					order = 4,
				},
				ignoreItemIds = {
					type = "input",
					name = G_RLF.L["Ignore Item IDs"],
					desc = G_RLF.L["IgnoreItemIDsDesc"],
					multiline = true,
					width = "double",
					get = function()
						return table.concat(G_RLF.db.global.partyLoot.ignoreItemIds, ", ")
					end,
					set = function(_, value)
						local ids = {}
						for id in value:gmatch("%d+") do
							table.insert(ids, tonumber(id))
						end
						G_RLF.db.global.partyLoot.ignoreItemIds = ids
					end,
					order = 5,
				},
			},
		},
	},
}
