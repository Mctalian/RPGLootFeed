---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

local lsm = G_RLF.lsm

local PartyLootConfig = {}

---Check if a string starts with another string
---@param str string
---@param start string
---@return boolean
local function startswith(str, start)
	return string.sub(str, 1, #start) == start
end

function PartyLootConfig:GetPositioningOptions(order)
	order = order or 9.1
	return {
		type = "group",
		inline = true,
		name = G_RLF.L["Party Loot Frame Positioning"],
		desc = G_RLF.L["PartyLootFrameDesc"],
		hidden = function()
			return not G_RLF.db.global.partyLoot.separateFrame
		end,
		order = order,
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
	}
end

function PartyLootConfig:GetSizingOptions(order)
	order = order or 9.2
	return {
		type = "group",
		inline = true,
		hidden = function()
			return not G_RLF.db.global.partyLoot.separateFrame
		end,
		name = G_RLF.L["Party Loot Frame Sizing"],
		desc = G_RLF.L["PartyLootFrameSizeDesc"],
		order = order,
		args = {
			copySizingFromMainFrame = {
				type = "execute",
				name = G_RLF.L["Copy Sizing from Main Frame"],
				desc = G_RLF.L["CopySizingFromMainFrameDesc"],
				func = function()
					local sizingDb = G_RLF.db.global.sizing
					for k, v in pairs(sizingDb) do
						G_RLF.db.global.partyLoot.sizing[k] = v
					end
					G_RLF.LootDisplay:UpdateSize(G_RLF.Frames.PARTY)
				end,
				order = 0.5,
				width = "full",
			},
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
					G_RLF.LootDisplay:UpdateSize(G_RLF.Frames.PARTY)
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
					G_RLF.LootDisplay:UpdateSize(G_RLF.Frames.PARTY)
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
					G_RLF.LootDisplay:UpdateSize(G_RLF.Frames.PARTY)
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
					G_RLF.LootDisplay:UpdateSize(G_RLF.Frames.PARTY)
				end,
				order = 5,
			},
		},
	}
end

function PartyLootConfig:GetStylingOptions(order)
	order = order or 9.3
	return {
		type = "group",
		inline = true,
		hidden = function()
			return not G_RLF.db.global.partyLoot.separateFrame
		end,
		name = G_RLF.L["Party Loot Frame Styling"],
		desc = G_RLF.L["PartyLootFrameStyleDesc"],
		order = order,
		args = {
			copyStylingFromMainFrame = {
				type = "execute",
				name = G_RLF.L["Copy Styling from Main Frame"],
				desc = G_RLF.L["CopyStylingFromMainFrameDesc"],
				func = function()
					local stylingDb = G_RLF.DbAccessor:Styling(G_RLF.Frames.MAIN)
					for k, v in pairs(stylingDb) do
						G_RLF.db.global.partyLoot.styling[k] = v
					end
					G_RLF.LootDisplay:UpdateRowStyles(G_RLF.Frames.PARTY)
					G_RLF.LootDisplay:ReInitQueueLabel(G_RLF.Frames.PARTY)
				end,
				order = 0.5,
				width = "full",
			},
			leftAlign = {
				type = "toggle",
				name = G_RLF.L["Left Align"],
				desc = G_RLF.L["LeftAlignDesc"],
				width = "double",
				get = function(info, value)
					return G_RLF.db.global.partyLoot.styling.leftAlign
				end,
				set = function(info, value)
					G_RLF.db.global.partyLoot.styling.leftAlign = value
					G_RLF.LootDisplay:UpdateRowStyles(G_RLF.Frames.PARTY)
					G_RLF.LootDisplay:ReInitQueueLabel(G_RLF.Frames.PARTY)
				end,
				order = 1,
			},
			growUp = {
				type = "toggle",
				name = G_RLF.L["Grow Up"],
				desc = G_RLF.L["GrowUpDesc"],
				width = "double",
				get = function(info, value)
					return G_RLF.db.global.partyLoot.styling.growUp
				end,
				set = function(info, value)
					G_RLF.db.global.partyLoot.styling.growUp = value
					G_RLF.LootDisplay:UpdateRowPositions(G_RLF.Frames.PARTY)
					G_RLF.LootDisplay:ReInitQueueLabel(G_RLF.Frames.PARTY)
				end,
				order = 2,
			},
			background = {
				type = "group",
				name = G_RLF.L["Background"],
				inline = true,
				order = 3,
				args = {
					backgroundType = {
						type = "select",
						name = G_RLF.L["Background Type"],
						desc = G_RLF.L["BackgroundTypeDesc"],
						width = "double",
						values = {
							-- May add this in at some point if requested
							-- [G_RLF.RowBackground.NONE] = G_RLF.L["None"]
							[G_RLF.RowBackground.GRADIENT] = G_RLF.L["Gradient"],
							[G_RLF.RowBackground.TEXTURED] = G_RLF.L["Textured"],
						},
						get = function(info, value)
							return G_RLF.db.global.partyLoot.styling.rowBackgroundType
						end,
						set = function(info, value)
							G_RLF.db.global.partyLoot.styling.rowBackgroundType = value
							G_RLF.LootDisplay:UpdateRowStyles(G_RLF.Frames.PARTY)
						end,
						order = 1,
					},
					gradientStart = {
						type = "color",
						name = G_RLF.L["Background Gradient Start"],
						desc = G_RLF.L["GradientStartDesc"],
						hasAlpha = true,
						width = "double",
						hidden = function()
							return G_RLF.db.global.partyLoot.styling.rowBackgroundType ~= G_RLF.RowBackground.GRADIENT
						end,
						get = function(info, value)
							local r, g, b, a = unpack(G_RLF.db.global.partyLoot.styling.rowBackgroundGradientStart)
							return r, g, b, a
						end,
						set = function(info, r, g, b, a)
							G_RLF.db.global.partyLoot.styling.rowBackgroundGradientStart = { r, g, b, a }
							G_RLF.LootDisplay:UpdateRowStyles(G_RLF.Frames.PARTY)
						end,
						order = 2.1,
					},
					gradientEnd = {
						type = "color",
						name = G_RLF.L["Background Gradient End"],
						desc = G_RLF.L["GradientEndDesc"],
						hasAlpha = true,
						width = "double",
						hidden = function()
							return G_RLF.db.global.partyLoot.styling.rowBackgroundType ~= G_RLF.RowBackground.GRADIENT
						end,
						get = function(info, value)
							local r, g, b, a = unpack(G_RLF.db.global.partyLoot.styling.rowBackgroundGradientEnd)
							return r, g, b, a
						end,
						set = function(info, r, g, b, a)
							G_RLF.db.global.partyLoot.styling.rowBackgroundGradientEnd = { r, g, b, a }
							G_RLF.LootDisplay:UpdateRowStyles(G_RLF.Frames.PARTY)
						end,
						order = 2.2,
					},
					backgroundTexture = {
						type = "select",
						dialogControl = "LSM30_Background",
						name = G_RLF.L["Background Texture"],
						desc = G_RLF.L["BackgroundTextureDesc"],
						hidden = function()
							return G_RLF.db.global.partyLoot.styling.rowBackgroundType ~= G_RLF.RowBackground.TEXTURED
						end,
						width = "double",
						values = function()
							return G_RLF.lsm:HashTable(G_RLF.lsm.MediaType.BACKGROUND)
						end,
						get = function(info, value)
							return G_RLF.db.global.partyLoot.styling.rowBackgroundTexture
						end,
						set = function(info, value)
							G_RLF.db.global.partyLoot.styling.rowBackgroundTexture = value
							G_RLF.LootDisplay:UpdateRowStyles(G_RLF.Frames.PARTY)
						end,
						order = 2.1,
					},
					backgroundTextureColor = {
						type = "color",
						name = G_RLF.L["Background Texture Color"],
						desc = G_RLF.L["BackgroundTextureColorDesc"],
						hasAlpha = true,
						width = "double",
						hidden = function()
							return G_RLF.db.global.partyLoot.styling.rowBackgroundType ~= G_RLF.RowBackground.TEXTURED
						end,
						get = function(info, value)
							local r, g, b, a = unpack(G_RLF.db.global.partyLoot.styling.rowBackgroundTextureColor)
							return r, g, b, a
						end,
						set = function(info, r, g, b, a)
							G_RLF.db.global.partyLoot.styling.rowBackgroundTextureColor = { r, g, b, a }
							G_RLF.LootDisplay:UpdateRowStyles(G_RLF.Frames.PARTY)
						end,
						order = 2.2,
					},
					insetDesc = {
						type = "description",
						name = string.format("\n%s", G_RLF.L["BackdropInsetsDesc"]),
						order = 3,
					},
					insetTop = {
						type = "range",
						name = G_RLF.L["Top Inset"],
						desc = G_RLF.L["TopInsetDesc"],
						min = 0,
						max = 20,
						bigStep = 1,
						get = function(info, value)
							return G_RLF.db.global.partyLoot.styling.backdropInsets.top
						end,
						set = function(info, value)
							G_RLF.db.global.partyLoot.styling.backdropInsets.top = value
							G_RLF.LootDisplay:UpdateRowStyles(G_RLF.Frames.PARTY)
						end,
						order = 4,
					},
					insetRight = {
						type = "range",
						name = G_RLF.L["Right Inset"],
						desc = G_RLF.L["RightInsetDesc"],
						min = 0,
						max = 20,
						bigStep = 1,
						get = function(info, value)
							return G_RLF.db.global.partyLoot.styling.backdropInsets.right
						end,
						set = function(info, value)
							G_RLF.db.global.partyLoot.styling.backdropInsets.right = value
							G_RLF.LootDisplay:UpdateRowStyles(G_RLF.Frames.PARTY)
						end,
						order = 5,
					},
					insetBottom = {
						type = "range",
						name = G_RLF.L["Bottom Inset"],
						desc = G_RLF.L["BottomInsetDesc"],
						min = 0,
						max = 20,
						bigStep = 1,
						get = function(info, value)
							return G_RLF.db.global.partyLoot.styling.backdropInsets.bottom
						end,
						set = function(info, value)
							G_RLF.db.global.partyLoot.styling.backdropInsets.bottom = value
							G_RLF.LootDisplay:UpdateRowStyles(G_RLF.Frames.PARTY)
						end,
						order = 6,
					},
					insetLeft = {
						type = "range",
						name = G_RLF.L["Left Inset"],
						desc = G_RLF.L["LeftInsetDesc"],
						min = 0,
						max = 20,
						bigStep = 1,
						get = function(info, value)
							return G_RLF.db.global.partyLoot.styling.backdropInsets.left
						end,
						set = function(info, value)
							G_RLF.db.global.partyLoot.styling.backdropInsets.left = value
							G_RLF.LootDisplay:UpdateRowStyles(G_RLF.Frames.PARTY)
						end,
						order = 7,
					},
				},
			},
			rowBorders = {
				type = "group",
				name = G_RLF.L["Row Borders"],
				desc = G_RLF.L["RowBordersDesc"],
				inline = true,
				order = 4,
				args = {
					rowBordersEnabled = {
						type = "toggle",
						name = G_RLF.L["Enable Row Borders"],
						desc = G_RLF.L["EnableRowBordersDesc"],
						width = "double",
						get = function(info, value)
							return G_RLF.db.global.partyLoot.styling.enableRowBorder
						end,
						set = function(info, value)
							G_RLF.db.global.partyLoot.styling.enableRowBorder = value
							G_RLF.LootDisplay:UpdateRowStyles(G_RLF.Frames.PARTY)
						end,
						order = 1,
					},
					rowBorderTexture = {
						type = "select",
						dialogControl = "LSM30_Border",
						name = G_RLF.L["Border Texture"],
						desc = G_RLF.L["BorderTextureDesc"],
						width = "double",
						values = function()
							return G_RLF.lsm:HashTable(G_RLF.lsm.MediaType.BORDER)
						end,
						get = function(info, value)
							return G_RLF.db.global.partyLoot.styling.rowBorderTexture
						end,
						set = function(info, value)
							G_RLF.db.global.partyLoot.styling.rowBorderTexture = value
							G_RLF.LootDisplay:UpdateRowStyles(G_RLF.Frames.PARTY)
						end,
						disabled = function(info, value)
							return G_RLF.db.global.partyLoot.styling.enableRowBorder == false
						end,
						order = 2,
					},
					rowBorderThickness = {
						type = "range",
						name = G_RLF.L["Row Border Thickness"],
						desc = G_RLF.L["RowBorderThicknessDesc"],
						min = 0.1,
						softMin = 1,
						max = 24,
						bigStep = 1,
						width = "double",
						disabled = function(info, value)
							return G_RLF.db.global.partyLoot.styling.enableRowBorder == false
						end,
						get = function(info, value)
							return G_RLF.db.global.partyLoot.styling.rowBorderSize
						end,
						set = function(info, value)
							G_RLF.db.global.partyLoot.styling.rowBorderSize = value
							G_RLF.LootDisplay:UpdateRowStyles(G_RLF.Frames.PARTY)
						end,
						order = 3,
					},
					rowBorderColor = {
						type = "color",
						name = G_RLF.L["Row Border Color"],
						desc = G_RLF.L["RowBorderColorDesc"],
						hasAlpha = true,
						disabled = function(info, value)
							return G_RLF.db.global.partyLoot.styling.enableRowBorder == false
								or G_RLF.db.global.partyLoot.styling.rowBorderClassColors
						end,
						get = function(info, value)
							local r, g, b, a = unpack(G_RLF.db.global.partyLoot.styling.rowBorderColor)
							return r, g, b, a
						end,
						set = function(info, r, g, b, a)
							G_RLF.db.global.partyLoot.styling.rowBorderColor = { r, g, b, a }
							G_RLF.LootDisplay:UpdateRowStyles(G_RLF.Frames.PARTY)
						end,
						order = 4,
					},
					rowBorderClassColors = {
						type = "toggle",
						name = G_RLF.L["Use Class Colors for Borders"],
						desc = G_RLF.L["UseClassColorsForBordersDesc"],
						width = "double",
						set = function(info, value)
							G_RLF.db.global.partyLoot.styling.rowBorderClassColors = value
							G_RLF.LootDisplay:UpdateRowStyles(G_RLF.Frames.PARTY)
						end,
						get = function(info, value)
							return G_RLF.db.global.partyLoot.styling.rowBorderClassColors
						end,
						disabled = function(info, value)
							return G_RLF.db.global.partyLoot.styling.enableRowBorder == false
						end,
						order = 5,
					},
				},
			},
			enableSecondaryRowText = {
				type = "toggle",
				name = G_RLF.L["Enable Secondary Row Text"],
				desc = G_RLF.L["EnableSecondaryRowTextDesc"],
				width = "double",
				get = function(info, value)
					return G_RLF.db.global.partyLoot.styling.enabledSecondaryRowText
				end,
				set = function(info, value)
					G_RLF.db.global.partyLoot.styling.enabledSecondaryRowText = value
					G_RLF.LootDisplay:UpdateRowStyles(G_RLF.Frames.PARTY)
				end,
				order = 5,
			},
			useFontObjects = {
				type = "toggle",
				name = G_RLF.L["Use Font Objects"],
				desc = G_RLF.L["UseFontObjectsDesc"],
				width = "double",
				get = function(info, value)
					return G_RLF.db.global.partyLoot.styling.useFontObjects
				end,
				set = function(info, value)
					G_RLF.db.global.partyLoot.styling.useFontObjects = value
					G_RLF.LootDisplay:ReInitQueueLabel(G_RLF.Frames.PARTY)
				end,
				order = 6,
			},
			font = {
				type = "select",
				name = G_RLF.L["Font"],
				desc = G_RLF.L["FontDesc"],
				disabled = function(info, value)
					return G_RLF.db.global.partyLoot.styling.useFontObjects == false
				end,
				width = "double",
				values = function()
					local fonts = _G.GetFonts()
					local allFonts = {}
					for k, v in pairs(fonts) do
						if type(v) == "string" then
							if startswith(v, "table") then
							-- Skip
							else
								allFonts[v] = v
							end
						end
					end
					return allFonts
				end,
				get = function(info, value)
					return G_RLF.db.global.partyLoot.styling.font
				end,
				set = function(info, value)
					G_RLF.db.global.partyLoot.styling.font = value
					G_RLF.LootDisplay:UpdateRowStyles(G_RLF.Frames.PARTY)
					G_RLF.LootDisplay:ReInitQueueLabel(G_RLF.Frames.PARTY)
				end,
				order = 7,
			},
			customFonts = {
				type = "group",
				name = G_RLF.L["Custom Fonts"],
				desc = G_RLF.L["CustomFontsDesc"],
				disabled = function(info, value)
					return G_RLF.db.global.partyLoot.styling.useFontObjects == true
				end,
				inline = true,
				order = 8,
				args = {
					font = {
						type = "select",
						dialogControl = "LSM30_Font",
						name = G_RLF.L["Font Face"],
						desc = G_RLF.L["FontFaceDesc"],
						width = "double",
						values = lsm:HashTable(lsm.MediaType.FONT),
						get = function(info, value)
							return G_RLF.db.global.partyLoot.styling.fontFace
						end,
						set = function(info, value)
							G_RLF.db.global.partyLoot.styling.fontFace = value
							G_RLF.LootDisplay:UpdateRowStyles(G_RLF.Frames.PARTY)
							G_RLF.LootDisplay:ReInitQueueLabel(G_RLF.Frames.PARTY)
						end,
						order = 1,
					},
					fontSize = {
						type = "range",
						name = G_RLF.L["Font Size"],
						desc = G_RLF.L["FontSizeDesc"],
						softMin = 6,
						softMax = 24,
						min = 1,
						max = 72,
						bigStep = 1,
						get = function(info, value)
							return G_RLF.db.global.partyLoot.styling.fontSize
						end,
						set = function(info, value)
							G_RLF.db.global.partyLoot.styling.fontSize = value
							G_RLF.LootDisplay:UpdateRowStyles(G_RLF.Frames.PARTY)
							G_RLF.LootDisplay:ReInitQueueLabel(G_RLF.Frames.PARTY)
						end,
						order = 2,
					},
					secondaryFontSize = {
						type = "range",
						name = G_RLF.L["Secondary Font Size"],
						desc = G_RLF.L["SecondaryFontSizeDesc"],
						disabled = function()
							return not G_RLF.db.global.partyLoot.styling.enabledSecondaryRowText
						end,
						softMin = 6,
						softMax = 24,
						min = 1,
						max = 72,
						bigStep = 1,
						get = function()
							return G_RLF.db.global.partyLoot.styling.secondaryFontSize
						end,
						set = function(info, value)
							G_RLF.db.global.partyLoot.styling.secondaryFontSize = value
							G_RLF.LootDisplay:UpdateRowStyles(G_RLF.Frames.PARTY)
						end,
						order = 3,
					},
					fontFlags = {
						type = "multiselect",
						name = G_RLF.L["Font Flags"],
						desc = G_RLF.L["FontFlagsDesc"],
						width = "double",
						values = {
							[G_RLF.FontFlags.NONE] = G_RLF.L["None"],
							[G_RLF.FontFlags.OUTLINE] = G_RLF.L["Outline"],
							[G_RLF.FontFlags.THICKOUTLINE] = G_RLF.L["Thick Outline"],
							[G_RLF.FontFlags.MONOCHROME] = G_RLF.L["Monochrome"],
						},
						get = function(info, key)
							return G_RLF.db.global.partyLoot.styling.fontFlags[key]
						end,
						set = function(info, key, value)
							G_RLF.db.global.partyLoot.styling.fontFlags[key] = value
							G_RLF.LootDisplay:UpdateRowStyles(G_RLF.Frames.PARTY)
							G_RLF.LootDisplay:ReInitQueueLabel(G_RLF.Frames.PARTY)
						end,
						order = 4,
					},
					shadowColor = {
						type = "color",
						name = G_RLF.L["Shadow Color"],
						desc = G_RLF.L["ShadowColorDesc"],
						hasAlpha = true,
						get = function(info, value)
							local r, g, b, a = unpack(G_RLF.db.global.partyLoot.styling.fontShadowColor)
							return r, g, b, a
						end,
						set = function(info, r, g, b, a)
							G_RLF.db.global.partyLoot.styling.fontShadowColor = { r, g, b, a }
							G_RLF.LootDisplay:UpdateRowStyles(G_RLF.Frames.PARTY)
							G_RLF.LootDisplay:ReInitQueueLabel(G_RLF.Frames.PARTY)
						end,
						order = 5,
						width = "double",
					},
					shadowHelp = {
						type = "description",
						name = G_RLF.L["ShadowOffsetHelp"],
						order = 5.1,
						width = "full",
					},
					shadowOffsetX = {
						type = "range",
						name = G_RLF.L["Shadow Offset X"],
						desc = G_RLF.L["ShadowOffsetXDesc"],
						min = -10,
						max = 10,
						step = 1,
						get = function(info, value)
							return G_RLF.db.global.partyLoot.styling.fontShadowOffsetX
						end,
						set = function(info, value)
							G_RLF.db.global.partyLoot.styling.fontShadowOffsetX = value
							G_RLF.LootDisplay:UpdateRowStyles(G_RLF.Frames.PARTY)
							G_RLF.LootDisplay:ReInitQueueLabel(G_RLF.Frames.PARTY)
						end,
						order = 6,
					},
					shadowOffsetY = {
						type = "range",
						name = G_RLF.L["Shadow Offset Y"],
						desc = G_RLF.L["ShadowOffsetYDesc"],
						min = -10,
						max = 10,
						step = 1,
						get = function(info, value)
							return G_RLF.db.global.partyLoot.styling.fontShadowOffsetY
						end,
						set = function(info, value)
							G_RLF.db.global.partyLoot.styling.fontShadowOffsetY = value
							G_RLF.LootDisplay:UpdateRowStyles(G_RLF.Frames.PARTY)
							G_RLF.LootDisplay:ReInitQueueLabel(G_RLF.Frames.PARTY)
						end,
						order = 7,
					},
				},
			},
		},
	}
end

G_RLF.ConfigHandlers.PartyLootConfig = PartyLootConfig

---@class RLF_DBGlobal
---@field partyLoot RLF_ConfigPartyLoot
G_RLF.defaults.global = G_RLF.defaults.global or {}

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
	---@type RLF_ConfigStyling
	styling = {
		enabledSecondaryRowText = false,
		leftAlign = true,
		growUp = true,
		rowBackgroundType = G_RLF.RowBackground.GRADIENT,
		rowBackgroundTexture = "Solid",
		rowBackgroundTextureColor = { 0, 0, 0, 1 },
		rowBackgroundGradientStart = { 0.1, 0.1, 0.1, 0.8 },
		rowBackgroundGradientEnd = { 0.1, 0.1, 0.1, 0 },
		backdropInsets = {
			left = 0,
			right = 0,
			top = 0,
			bottom = 0,
		},
		enableRowBorder = false,
		rowBorderSize = 1,
		rowBorderColor = { 0, 0, 0, 1 },
		rowBorderClassColors = false,
		rowBorderTexture = "None",
		useFontObjects = true,
		font = "GameFontNormalSmall",
		fontFace = "Friz Quadrata TT",
		fontSize = 10,
		secondaryFontSize = 8,
		enableTopLeftIconText = false,
		topLeftIconFontSize = 8,
		topLeftIconTextColor = { 1, 1, 1, 1 },
		topLeftIconTextUseQualityColor = false,
		fontFlags = {
			[G_RLF.FontFlags.NONE] = true,
			[G_RLF.FontFlags.OUTLINE] = false,
			[G_RLF.FontFlags.THICKOUTLINE] = false,
			[G_RLF.FontFlags.MONOCHROME] = false,
		},
		fontShadowColor = { 0, 0, 0, 1 },
		fontShadowOffsetX = 1,
		fontShadowOffsetY = -1,
	},
	---@type number[]
	ignoreItemIds = {},
	enableIcon = true,
	enablePartyAvatar = true,
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
				showIcon = {
					type = "toggle",
					name = G_RLF.L["Show Item Icon"],
					desc = G_RLF.L["ShowItemIconDesc"],
					width = "double",
					disabled = function()
						return G_RLF.db.global.misc.hideAllIcons
					end,
					get = function()
						return G_RLF.db.global.partyLoot.enableIcon
					end,
					set = function(_, value)
						G_RLF.db.global.partyLoot.enableIcon = value
					end,
					order = 0.5,
				},
				showPartyAvatar = {
					type = "toggle",
					name = G_RLF.L["Show Party Avatar"],
					desc = G_RLF.L["ShowPartyAvatarDesc"],
					width = "double",
					get = function()
						return G_RLF.db.global.partyLoot.enablePartyAvatar
					end,
					set = function(_, value)
						G_RLF.db.global.partyLoot.enablePartyAvatar = value
					end,
					order = 1,
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
						local partyLoot = G_RLF.RLF:GetModule(G_RLF.FeatureModule.PartyLoot) --[[@as RLF_PartyLoot]]
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
						local partyLoot = G_RLF.RLF:GetModule(G_RLF.FeatureModule.PartyLoot) --[[@as RLF_PartyLoot]]
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
						if value then
							G_RLF.LootDisplay:CreatePartyFrame()
						else
							G_RLF.LootDisplay:DestroyPartyFrame()
						end
					end,
					order = 9,
				},
				positioning = PartyLootConfig:GetPositioningOptions(),
				sizing = PartyLootConfig:GetSizingOptions(),
				styling = PartyLootConfig:GetStylingOptions(),
			},
		},
	},
}
