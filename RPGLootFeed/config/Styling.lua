---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

---@class Styling
local Styling = {}

local lsm = G_RLF.lsm

---Check if a string starts with another string
---@param str string
---@param start string
---@return boolean
local function startswith(str, start)
	return string.sub(str, 1, #start) == start
end

---@class RLF_DBGlobal
G_RLF.defaults.global = G_RLF.defaults.global or {}

---@class RLF_ConfigStyling
G_RLF.defaults.global.styling = {
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
	useFontObjects = false,
	font = "GameFontNormalSmall",
	fontFace = "Friz Quadrata TT",
	fontSize = 10,
	secondaryFontSize = 8,
	enableTopLeftIconText = true,
	topLeftIconFontSize = 6,
	topLeftIconTextColor = { 1, 1, 1, 1 },
	topLeftIconTextUseQualityColor = true,
	fontFlags = {
		[G_RLF.FontFlags.NONE] = true,
		[G_RLF.FontFlags.OUTLINE] = false,
		[G_RLF.FontFlags.THICKOUTLINE] = false,
		[G_RLF.FontFlags.MONOCHROME] = false,
	},
	fontShadowColor = { 0, 0, 0, 1 },
	fontShadowOffsetX = 1,
	fontShadowOffsetY = -1,
}

G_RLF.options.args.styles = {
	type = "group",
	handler = Styling,
	name = G_RLF.L["Styling"],
	desc = G_RLF.L["StylingDesc"],
	order = G_RLF.level1OptionsOrder.styling,
	args = {
		leftAlign = {
			type = "toggle",
			name = G_RLF.L["Left Align"],
			desc = G_RLF.L["LeftAlignDesc"],
			width = "double",
			get = function(info, value)
				return G_RLF.db.global.styling.leftAlign
			end,
			set = function(info, value)
				G_RLF.db.global.styling.leftAlign = value
				G_RLF.LootDisplay:UpdateRowStyles()
				G_RLF.LootDisplay:ReInitQueueLabel()
			end,
			order = 1,
		},
		growUp = {
			type = "toggle",
			name = G_RLF.L["Grow Up"],
			desc = G_RLF.L["GrowUpDesc"],
			width = "double",
			get = function(info, value)
				return G_RLF.db.global.styling.growUp
			end,
			set = function(info, value)
				G_RLF.db.global.styling.growUp = value
				G_RLF.LootDisplay:UpdateRowPositions()
				G_RLF.LootDisplay:ReInitQueueLabel()
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
					values = {
						-- May add this in at some point if requested
						-- [G_RLF.RowBackground.NONE] = G_RLF.L["None"]
						[G_RLF.RowBackground.GRADIENT] = G_RLF.L["Gradient"],
						[G_RLF.RowBackground.TEXTURED] = G_RLF.L["Textured"],
					},
					get = function(info, value)
						return G_RLF.db.global.styling.rowBackgroundType
					end,
					set = function(info, value)
						G_RLF.db.global.styling.rowBackgroundType = value
						G_RLF.LootDisplay:UpdateRowStyles()
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
						return G_RLF.db.global.styling.rowBackgroundType ~= G_RLF.RowBackground.GRADIENT
					end,
					get = function(info, value)
						local r, g, b, a = unpack(G_RLF.db.global.styling.rowBackgroundGradientStart)
						return r, g, b, a
					end,
					set = function(info, r, g, b, a)
						G_RLF.db.global.styling.rowBackgroundGradientStart = { r, g, b, a }
						G_RLF.LootDisplay:UpdateRowStyles()
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
						return G_RLF.db.global.styling.rowBackgroundType ~= G_RLF.RowBackground.GRADIENT
					end,
					get = function(info, value)
						local r, g, b, a = unpack(G_RLF.db.global.styling.rowBackgroundGradientEnd)
						return r, g, b, a
					end,
					set = function(info, r, g, b, a)
						G_RLF.db.global.styling.rowBackgroundGradientEnd = { r, g, b, a }
						G_RLF.LootDisplay:UpdateRowStyles()
					end,
					order = 2.2,
				},
				backgroundTexture = {
					type = "select",
					dialogControl = "LSM30_Background",
					name = G_RLF.L["Background Texture"],
					desc = G_RLF.L["BackgroundTextureDesc"],
					hidden = function()
						return G_RLF.db.global.styling.rowBackgroundType ~= G_RLF.RowBackground.TEXTURED
					end,
					width = "double",
					values = function()
						return G_RLF.lsm:HashTable(G_RLF.lsm.MediaType.BACKGROUND)
					end,
					get = function(info, value)
						return G_RLF.db.global.styling.rowBackgroundTexture
					end,
					set = function(info, value)
						G_RLF.db.global.styling.rowBackgroundTexture = value
						G_RLF.LootDisplay:UpdateRowStyles()
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
						return G_RLF.db.global.styling.rowBackgroundType ~= G_RLF.RowBackground.TEXTURED
					end,
					get = function(info, value)
						local r, g, b, a = unpack(G_RLF.db.global.styling.rowBackgroundTextureColor)
						return r, g, b, a
					end,
					set = function(info, r, g, b, a)
						G_RLF.db.global.styling.rowBackgroundTextureColor = { r, g, b, a }
						G_RLF.LootDisplay:UpdateRowStyles()
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
						return G_RLF.db.global.styling.backdropInsets.top
					end,
					set = function(info, value)
						G_RLF.db.global.styling.backdropInsets.top = value
						G_RLF.LootDisplay:UpdateRowStyles()
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
						return G_RLF.db.global.styling.backdropInsets.right
					end,
					set = function(info, value)
						G_RLF.db.global.styling.backdropInsets.right = value
						G_RLF.LootDisplay:UpdateRowStyles()
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
						return G_RLF.db.global.styling.backdropInsets.bottom
					end,
					set = function(info, value)
						G_RLF.db.global.styling.backdropInsets.bottom = value
						G_RLF.LootDisplay:UpdateRowStyles()
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
						return G_RLF.db.global.styling.backdropInsets.left
					end,
					set = function(info, value)
						G_RLF.db.global.styling.backdropInsets.left = value
						G_RLF.LootDisplay:UpdateRowStyles()
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
						return G_RLF.db.global.styling.enableRowBorder
					end,
					set = function(info, value)
						G_RLF.db.global.styling.enableRowBorder = value
						G_RLF.LootDisplay:UpdateRowStyles()
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
						return G_RLF.db.global.styling.rowBorderTexture
					end,
					set = function(info, value)
						G_RLF.db.global.styling.rowBorderTexture = value
						G_RLF.LootDisplay:UpdateRowStyles()
					end,
					disabled = function(info, value)
						return G_RLF.db.global.styling.enableRowBorder == false
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
						return G_RLF.db.global.styling.enableRowBorder == false
					end,
					get = function(info, value)
						return G_RLF.db.global.styling.rowBorderSize
					end,
					set = function(info, value)
						G_RLF.db.global.styling.rowBorderSize = value
						G_RLF.LootDisplay:UpdateRowStyles()
					end,
					order = 3,
				},
				rowBorderColor = {
					type = "color",
					name = G_RLF.L["Row Border Color"],
					desc = G_RLF.L["RowBorderColorDesc"],
					hasAlpha = true,
					disabled = function(info, value)
						return G_RLF.db.global.styling.enableRowBorder == false
							or G_RLF.db.global.styling.rowBorderClassColors
					end,
					get = function(info, value)
						local r, g, b, a = unpack(G_RLF.db.global.styling.rowBorderColor)
						return r, g, b, a
					end,
					set = function(info, r, g, b, a)
						G_RLF.db.global.styling.rowBorderColor = { r, g, b, a }
						G_RLF.LootDisplay:UpdateRowStyles()
					end,
					order = 4,
				},
				rowBorderClassColors = {
					type = "toggle",
					name = G_RLF.L["Use Class Colors for Borders"],
					desc = G_RLF.L["UseClassColorsForBordersDesc"],
					width = 1.5,
					set = function(info, value)
						G_RLF.db.global.styling.rowBorderClassColors = value
						G_RLF.LootDisplay:UpdateRowStyles()
					end,
					get = function(info, value)
						return G_RLF.db.global.styling.rowBorderClassColors
					end,
					disabled = function(info, value)
						return G_RLF.db.global.styling.enableRowBorder == false
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
				return G_RLF.db.global.styling.enabledSecondaryRowText
			end,
			set = function(info, value)
				G_RLF.db.global.styling.enabledSecondaryRowText = value
				G_RLF.LootDisplay:UpdateRowStyles()
			end,
			order = 5,
		},
		topLeftIconTextOptions = {
			name = G_RLF.L["Top Left Icon Text Options"],
			type = "group",
			inline = true,
			order = 6,
			args = {
				enableTopLeftIconText = {
					type = "toggle",
					name = G_RLF.L["Enable Top Left Icon Text"],
					desc = G_RLF.L["EnableTopLeftIconTextDesc"],
					get = function(info, value)
						return G_RLF.db.global.styling.enableTopLeftIconText
					end,
					set = function(info, value)
						G_RLF.db.global.styling.enableTopLeftIconText = value
						G_RLF.LootDisplay:UpdateRowStyles()
					end,
					order = 0.1,
				},
				topLeftIconFontSize = {
					type = "range",
					name = G_RLF.L["Top Left Icon Font Size"],
					desc = G_RLF.L["TopLeftIconFontSizeDesc"],
					softMin = 6,
					softMax = 24,
					min = 1,
					max = 72,
					bigStep = 1,
					disabled = function()
						return not G_RLF.db.global.styling.enableTopLeftIconText
					end,
					get = function(info, value)
						return G_RLF.db.global.styling.topLeftIconFontSize
					end,
					set = function(info, value)
						G_RLF.db.global.styling.topLeftIconFontSize = value
						G_RLF.LootDisplay:UpdateRowStyles()
					end,
					order = 1,
				},
				topLeftIconTextUseQualityColor = {
					type = "toggle",
					name = G_RLF.L["Use Quality Color"],
					desc = G_RLF.L["UseQualityColorDesc"],
					disabled = function()
						return not G_RLF.db.global.styling.enableTopLeftIconText
					end,
					get = function(info, value)
						return G_RLF.db.global.styling.topLeftIconTextUseQualityColor
					end,
					set = function(info, value)
						G_RLF.db.global.styling.topLeftIconTextUseQualityColor = value
						G_RLF.LootDisplay:UpdateRowStyles()
					end,
					order = 2,
				},
				topLeftIconTextColor = {
					type = "color",
					name = G_RLF.L["Top Left Icon Text Color"],
					desc = G_RLF.L["TopLeftIconTextColorDesc"],
					hasAlpha = true,
					disabled = function()
						return G_RLF.db.global.styling.topLeftIconTextUseQualityColor
							or not G_RLF.db.global.styling.enableTopLeftIconText
					end,
					get = function(info, value)
						local r, g, b, a = unpack(G_RLF.db.global.styling.topLeftIconTextColor)
						return r, g, b, a
					end,
					set = function(info, r, g, b, a)
						G_RLF.db.global.styling.topLeftIconTextColor = { r, g, b, a }
						G_RLF.LootDisplay:UpdateRowStyles()
					end,
					order = 3,
				},
			},
		},
		useFontObjects = {
			type = "toggle",
			name = G_RLF.L["Use Font Objects"],
			desc = G_RLF.L["UseFontObjectsDesc"],
			width = "double",
			get = function(info, value)
				return G_RLF.db.global.styling.useFontObjects
			end,
			set = function(info, value)
				G_RLF.db.global.styling.useFontObjects = value
				G_RLF.LootDisplay:ReInitQueueLabel()
			end,
			order = 7,
		},
		font = {
			type = "select",
			name = G_RLF.L["Font"],
			desc = G_RLF.L["FontDesc"],
			disabled = function(info, value)
				return G_RLF.db.global.styling.useFontObjects == false
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
				return G_RLF.db.global.styling.font
			end,
			set = function(info, value)
				G_RLF.db.global.styling.font = value
				G_RLF.LootDisplay:UpdateRowStyles()
				G_RLF.LootDisplay:ReInitQueueLabel()
			end,
			order = 8,
		},
		customFonts = {
			type = "group",
			name = G_RLF.L["Custom Fonts"],
			desc = G_RLF.L["CustomFontsDesc"],
			disabled = function(info, value)
				return G_RLF.db.global.styling.useFontObjects == true
			end,
			inline = true,
			order = 9,
			args = {
				font = {
					type = "select",
					dialogControl = "LSM30_Font",
					name = G_RLF.L["Font Face"],
					desc = G_RLF.L["FontFaceDesc"],
					width = "double",
					values = lsm:HashTable(lsm.MediaType.FONT),
					get = function(info, value)
						return G_RLF.db.global.styling.fontFace
					end,
					set = function(info, value)
						G_RLF.db.global.styling.fontFace = value
						G_RLF.LootDisplay:UpdateRowStyles()
						G_RLF.LootDisplay:ReInitQueueLabel()
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
						return G_RLF.db.global.styling.fontSize
					end,
					set = function(info, value)
						G_RLF.db.global.styling.fontSize = value
						G_RLF.LootDisplay:UpdateRowStyles()
						G_RLF.LootDisplay:ReInitQueueLabel()
					end,
					order = 2,
				},
				secondaryFontSize = {
					type = "range",
					name = G_RLF.L["Secondary Font Size"],
					desc = G_RLF.L["SecondaryFontSizeDesc"],
					disabled = function()
						return not G_RLF.db.global.styling.enabledSecondaryRowText
							or (G_RLF.db.global.styling.useFontObjects == true)
					end,
					softMin = 6,
					softMax = 24,
					min = 1,
					max = 72,
					bigStep = 1,
					get = function()
						return G_RLF.db.global.styling.secondaryFontSize
					end,
					set = function(info, value)
						G_RLF.db.global.styling.secondaryFontSize = value
						G_RLF.LootDisplay:UpdateRowStyles()
						G_RLF.LootDisplay:ReInitQueueLabel()
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
						return G_RLF.db.global.styling.fontFlags[key]
					end,
					set = function(info, key, value)
						G_RLF.db.global.styling.fontFlags[key] = value
						G_RLF.LootDisplay:UpdateRowStyles()
						G_RLF.LootDisplay:ReInitQueueLabel()
					end,
					order = 4,
				},
				shadowColor = {
					type = "color",
					name = G_RLF.L["Shadow Color"],
					desc = G_RLF.L["ShadowColorDesc"],
					hasAlpha = true,
					get = function(info, value)
						local r, g, b, a = unpack(G_RLF.db.global.styling.fontShadowColor)
						return r, g, b, a
					end,
					set = function(info, r, g, b, a)
						G_RLF.db.global.styling.fontShadowColor = { r, g, b, a }
						G_RLF.LootDisplay:UpdateRowStyles()
						G_RLF.LootDisplay:ReInitQueueLabel()
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
						return G_RLF.db.global.styling.fontShadowOffsetX
					end,
					set = function(info, value)
						G_RLF.db.global.styling.fontShadowOffsetX = value
						G_RLF.LootDisplay:UpdateRowStyles()
						G_RLF.LootDisplay:ReInitQueueLabel()
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
						return G_RLF.db.global.styling.fontShadowOffsetY
					end,
					set = function(info, value)
						G_RLF.db.global.styling.fontShadowOffsetY = value
						G_RLF.LootDisplay:UpdateRowStyles()
						G_RLF.LootDisplay:ReInitQueueLabel()
					end,
					order = 7,
				},
			},
		},
		partyLootFrame = G_RLF.ConfigHandlers.PartyLootConfig:GetStylingOptions(10),
	},
}
