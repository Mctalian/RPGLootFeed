---@type string, table
local addonName, G_RLF = ...

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

G_RLF.defaults.global.styling = {
	enabledSecondaryRowText = false,
	leftAlign = true,
	growUp = true,
	rowBackgroundGradientStart = { 0.1, 0.1, 0.1, 0.8 },
	rowBackgroundGradientEnd = { 0.1, 0.1, 0.1, 0 },
	enableRowBorder = false,
	rowBorderSize = 1,
	rowBorderColor = { 0, 0, 0, 1 },
	rowBorderClassColors = false,
	useFontObjects = true,
	font = "GameFontNormalSmall",
	fontFace = "Friz Quadrata TT",
	fontSize = 10,
	secondaryFontSize = 8,
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
	order = 7,
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
			end,
			order = 2,
		},
		gradientStart = {
			type = "color",
			name = G_RLF.L["Background Gradient Start"],
			desc = G_RLF.L["GradientStartDesc"],
			hasAlpha = true,
			get = function(info, value)
				local r, g, b, a = unpack(G_RLF.db.global.styling.rowBackgroundGradientStart)
				return r, g, b, a
			end,
			set = function(info, r, g, b, a)
				G_RLF.db.global.styling.rowBackgroundGradientStart = { r, g, b, a }
				G_RLF.LootDisplay:UpdateRowStyles()
			end,
			order = 3,
		},
		gradientEnd = {
			type = "color",
			name = G_RLF.L["Background Gradient End"],
			desc = G_RLF.L["GradientEndDesc"],
			hasAlpha = true,
			get = function(info, value)
				local r, g, b, a = unpack(G_RLF.db.global.styling.rowBackgroundGradientEnd)
				return r, g, b, a
			end,
			set = function(info, r, g, b, a)
				G_RLF.db.global.styling.rowBackgroundGradientEnd = { r, g, b, a }
				G_RLF.LootDisplay:UpdateRowStyles()
			end,
			order = 4,
		},
		rowBorders = {
			type = "group",
			name = G_RLF.L["Row Borders"],
			desc = G_RLF.L["RowBordersDesc"],
			inline = true,
			order = 5,
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
				rowBorderThickness = {
					type = "range",
					name = G_RLF.L["Row Border Thickness"],
					desc = G_RLF.L["RowBorderThicknessDesc"],
					min = 1,
					max = 10,
					step = 1,
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
					order = 2,
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
					order = 3,
				},
				rowBorderClassColors = {
					type = "toggle",
					name = G_RLF.L["Use Class Colors for Borders"],
					desc = G_RLF.L["UseClassColorsForBordersDesc"],
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
					order = 4,
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
			order = 6,
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
					end,
					order = 2,
				},
				secondaryFontSize = {
					type = "range",
					name = G_RLF.L["Secondary Font Size"],
					desc = G_RLF.L["SecondaryFontSizeDesc"],
					disabled = function()
						return not G_RLF.db.global.styling.enabledSecondaryRowText
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
					end,
					order = 7,
				},
			},
		},
	},
}
