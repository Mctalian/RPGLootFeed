local addonName, G_RLF = ...

local Styling = {}

local lsm = G_RLF.lsm

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
			get = "GetLeftAlign",
			set = "SetLeftAlign",
			order = 1,
		},
		growUp = {
			type = "toggle",
			name = G_RLF.L["Grow Up"],
			desc = G_RLF.L["GrowUpDesc"],
			width = "double",
			get = "GetGrowUp",
			set = "SetGrowUp",
			order = 2,
		},
		gradientStart = {
			type = "color",
			name = G_RLF.L["Background Gradient Start"],
			desc = G_RLF.L["GradientStartDesc"],
			hasAlpha = true,
			get = "GetGradientStartColor",
			set = "SetGradientStartColor",
			order = 3,
		},
		gradientEnd = {
			type = "color",
			name = G_RLF.L["Background Gradient End"],
			desc = G_RLF.L["GradientEndDesc"],
			hasAlpha = true,
			get = "GetGradientEndColor",
			set = "SetGradientEndColor",
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
					get = "GetRowBorders",
					set = "SetRowBorders",
					order = 1,
				},
				rowBorderThickness = {
					type = "range",
					name = G_RLF.L["Row Border Thickness"],
					desc = G_RLF.L["RowBorderThicknessDesc"],
					min = 1,
					max = 10,
					step = 1,
					disabled = "DisableRowBorders",
					get = "GetRowBorderThickness",
					set = "SetRowBorderThickness",
					order = 2,
				},
				rowBorderColor = {
					type = "color",
					name = G_RLF.L["Row Border Color"],
					desc = G_RLF.L["RowBorderColorDesc"],
					hasAlpha = true,
					disabled = "DisableRowColor",
					get = "GetRowBorderColor",
					set = "SetRowBorderColor",
					order = 3,
				},
				rowBorderClassColors = {
					type = "toggle",
					name = G_RLF.L["Use Class Colors for Borders"],
					desc = G_RLF.L["UseClassColorsForBordersDesc"],
					set = "SetRowBorderClassColors",
					get = "GetRowBorderClassColors",
					disabled = "DisableRowBorders",
					order = 4,
				},
			},
		},
		enableSecondaryRowText = {
			type = "toggle",
			name = G_RLF.L["Enable Secondary Row Text"],
			desc = G_RLF.L["EnableSecondaryRowTextDesc"],
			width = "double",
			get = "GetSecondaryRowText",
			set = "SetSecondaryRowText",
			order = 6,
		},
		useFontObjects = {
			type = "toggle",
			name = G_RLF.L["Use Font Objects"],
			desc = G_RLF.L["UseFontObjectsDesc"],
			width = "double",
			get = "GetUseFontObjects",
			set = "SetUseFontObjects",
			order = 7,
		},
		font = {
			type = "select",
			name = G_RLF.L["Font"],
			desc = G_RLF.L["FontDesc"],
			disabled = "DisableFontObjects",
			width = "double",
			values = "GetFonts",
			get = "GetRowFont",
			set = "SetRowFont",
			order = 8,
		},
		customFonts = {
			type = "group",
			name = G_RLF.L["Custom Fonts"],
			desc = G_RLF.L["CustomFontsDesc"],
			disabled = "DisableCustomFonts",
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
					get = "GetRowFontFace",
					set = "SetRowFontFace",
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
					get = "GetRowFontSize",
					set = "SetRowFontSize",
					order = 2,
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
				},
				secondaryFontSize = {
					type = "range",
					name = G_RLF.L["Secondary Font Size"],
					desc = G_RLF.L["SecondaryFontSizeDesc"],
					disabled = "SecondaryTextDisabled",
					softMin = 6,
					softMax = 24,
					min = 1,
					max = 72,
					bigStep = 1,
					get = "GetSecondaryRowFontSize",
					set = "SetSecondaryRowFontSize",
					order = 3,
				},
			},
		},
	},
}

function string:startswith(start)
	return self:sub(1, #start) == start
end

function Styling:GetFonts()
	local fonts = _G.GetFonts()
	local allFonts = {}
	for k, v in pairs(fonts) do
		if type(v) == "string" then
			if v:startswith("table") then
			-- Skip
			else
				allFonts[v] = v
			end
		end
	end
	return allFonts
end

function Styling:GetGradientStartColor(info, value)
	local r, g, b, a = unpack(G_RLF.db.global.styling.rowBackgroundGradientStart)
	return r, g, b, a
end

function Styling:SetGradientStartColor(info, r, g, b, a)
	G_RLF.db.global.styling.rowBackgroundGradientStart = { r, g, b, a }
	G_RLF.LootDisplay:UpdateRowStyles()
end

function Styling:GetGradientEndColor(info, value)
	local r, g, b, a = unpack(G_RLF.db.global.styling.rowBackgroundGradientEnd)
	return r, g, b, a
end

function Styling:SetGradientEndColor(info, r, g, b, a)
	G_RLF.db.global.styling.rowBackgroundGradientEnd = { r, g, b, a }
	G_RLF.LootDisplay:UpdateRowStyles()
end

function Styling:SetLeftAlign(info, value)
	G_RLF.db.global.styling.leftAlign = value
	G_RLF.LootDisplay:UpdateRowStyles()
end

function Styling:GetLeftAlign(info, value)
	return G_RLF.db.global.styling.leftAlign
end

function Styling:GetGrowUp(info, value)
	return G_RLF.db.global.styling.growUp
end

function Styling:SetGrowUp(info, value)
	G_RLF.db.global.styling.growUp = value
	G_RLF.LootDisplay:UpdateRowPositions()
end

function Styling:GetSecondaryRowText(info, value)
	return G_RLF.db.global.styling.enabledSecondaryRowText
end

function Styling:SetSecondaryRowText(info, value)
	G_RLF.db.global.styling.enabledSecondaryRowText = value
	G_RLF.LootDisplay:UpdateRowStyles()
end

function Styling:GetUseFontObjects(info, value)
	return G_RLF.db.global.styling.useFontObjects
end

function Styling:SetUseFontObjects(info, value)
	G_RLF.db.global.styling.useFontObjects = value
end

function Styling:DisableFontObjects(info, value)
	return G_RLF.db.global.styling.useFontObjects == false
end

function Styling:DisableCustomFonts(info, value)
	return G_RLF.db.global.styling.useFontObjects == true
end

function Styling:GetRowFontFace(info, value)
	return G_RLF.db.global.styling.fontFace
end

function Styling:SetRowFontFace(info, value)
	G_RLF.db.global.styling.fontFace = value
	G_RLF.LootDisplay:UpdateRowStyles()
end

function Styling:GetRowFontSize(info, value)
	return G_RLF.db.global.styling.fontSize
end

function Styling:SetRowFontSize(info, value)
	G_RLF.db.global.styling.fontSize = value
	G_RLF.LootDisplay:UpdateRowStyles()
end

function Styling:SecondaryTextDisabled()
	return not G_RLF.db.global.styling.enabledSecondaryRowText
end

function Styling:GetSecondaryRowFontSize()
	return G_RLF.db.global.styling.secondaryFontSize
end

function Styling:SetSecondaryRowFontSize(info, value)
	G_RLF.db.global.styling.secondaryFontSize = value
	G_RLF.LootDisplay:UpdateRowStyles()
end

function Styling:SetRowFont(info, value)
	G_RLF.db.global.styling.font = value
	G_RLF.LootDisplay:UpdateRowStyles()
end

function Styling:GetRowFont(info, value)
	return G_RLF.db.global.styling.font
end

function Styling:GetRowBorders(info, value)
	return G_RLF.db.global.styling.enableRowBorder
end

function Styling:SetRowBorders(info, value)
	G_RLF.db.global.styling.enableRowBorder = value
	G_RLF.LootDisplay:UpdateRowStyles()
end

function Styling:GetRowBorderThickness(info, value)
	return G_RLF.db.global.styling.rowBorderSize
end

function Styling:SetRowBorderThickness(info, value)
	G_RLF.db.global.styling.rowBorderSize = value
	G_RLF.LootDisplay:UpdateRowStyles()
end

function Styling:GetRowBorderColor(info, value)
	local r, g, b, a = unpack(G_RLF.db.global.styling.rowBorderColor)
	return r, g, b, a
end

function Styling:SetRowBorderColor(info, r, g, b, a)
	G_RLF.db.global.styling.rowBorderColor = { r, g, b, a }
	G_RLF.LootDisplay:UpdateRowStyles()
end

function Styling:DisableRowBorders(info, value)
	return G_RLF.db.global.styling.enableRowBorder == false
end

function Styling:DisableRowColor(info, value)
	return G_RLF.db.global.styling.enableRowBorder == false or G_RLF.db.global.styling.rowBorderClassColors
end

function Styling:GetRowBorderClassColors(info, value)
	return G_RLF.db.global.styling.rowBorderClassColors
end

function Styling:SetRowBorderClassColors(info, value)
	G_RLF.db.global.styling.rowBorderClassColors = value
	G_RLF.LootDisplay:UpdateRowStyles()
end
