local addonName, G_RLF = ...

local Styling = {}

local lsm = G_RLF.lsm

G_RLF.defaults.global.enabledSecondaryRowText = false
G_RLF.defaults.global.leftAlign = true
G_RLF.defaults.global.growUp = true
G_RLF.defaults.global.rowBackgroundGradientStart = { 0.1, 0.1, 0.1, 0.8 } -- Default to dark grey with 80% opacity
G_RLF.defaults.global.rowBackgroundGradientEnd = { 0.1, 0.1, 0.1, 0 } -- Default to dark grey with 0% opacity
G_RLF.defaults.global.disableRowHighlight = false
G_RLF.defaults.global.useFontObjects = true
G_RLF.defaults.global.font = "GameFontNormalSmall"
G_RLF.defaults.global.fontFace = "Friz Quadrata TT"
G_RLF.defaults.global.fontSize = 10
G_RLF.defaults.global.secondaryFontSize = 8
G_RLF.defaults.global.fontFlags = ""

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
		rowHighlight = {
			type = "toggle",
			name = G_RLF.L["Disable Row Highlight"],
			desc = G_RLF.L["DisableRowHighlightDesc"],
			width = "double",
			get = "GetRowHighlight",
			set = "SetRowHighlight",
			order = 5,
		},
		enableSecondaryRowText = {
			type = "toggle",
			name = G_RLF.L["Enable Secondary Row Text"],
			desc = G_RLF.L["EnableSecondaryRowTextDesc"],
			width = "double",
			get = "GetSecondaryRowText",
			set = "SetSecondaryRowText",
			order = 5.1,
		},
		useFontObjects = {
			type = "toggle",
			name = G_RLF.L["Use Font Objects"],
			desc = G_RLF.L["UseFontObjectsDesc"],
			width = "double",
			get = "GetUseFontObjects",
			set = "SetUseFontObjects",
			order = 6,
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
			order = 7,
		},
		customFonts = {
			type = "group",
			name = G_RLF.L["Custom Fonts"],
			desc = G_RLF.L["CustomFontsDesc"],
			disabled = "DisableCustomFonts",
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
	local r, g, b, a = unpack(G_RLF.db.global.rowBackgroundGradientStart)
	return r, g, b, a
end

function Styling:SetGradientStartColor(info, r, g, b, a)
	G_RLF.db.global.rowBackgroundGradientStart = { r, g, b, a }
	G_RLF.LootDisplay:UpdateRowStyles()
end

function Styling:GetGradientEndColor(info, value)
	local r, g, b, a = unpack(G_RLF.db.global.rowBackgroundGradientEnd)
	return r, g, b, a
end

function Styling:SetGradientEndColor(info, r, g, b, a)
	G_RLF.db.global.rowBackgroundGradientEnd = { r, g, b, a }
	G_RLF.LootDisplay:UpdateRowStyles()
end

function Styling:SetLeftAlign(info, value)
	G_RLF.db.global.leftAlign = value
	G_RLF.LootDisplay:UpdateRowStyles()
end

function Styling:GetLeftAlign(info, value)
	return G_RLF.db.global.leftAlign
end

function Styling:GetGrowUp(info, value)
	return G_RLF.db.global.growUp
end

function Styling:SetGrowUp(info, value)
	G_RLF.db.global.growUp = value
	G_RLF.LootDisplay:UpdateRowPositions()
end

function Styling:GetRowHighlight(info, value)
	return G_RLF.db.global.disableRowHighlight
end

function Styling:SetRowHighlight(info, value)
	G_RLF.db.global.disableRowHighlight = value
end

function Styling:GetSecondaryRowText(info, value)
	return G_RLF.db.global.enabledSecondaryRowText
end

function Styling:SetSecondaryRowText(info, value)
	G_RLF.db.global.enabledSecondaryRowText = value
	G_RLF.LootDisplay:UpdateRowStyles()
end

function Styling:GetUseFontObjects(info, value)
	return G_RLF.db.global.useFontObjects
end

function Styling:SetUseFontObjects(info, value)
	G_RLF.db.global.useFontObjects = value
end

function Styling:DisableFontObjects(info, value)
	return G_RLF.db.global.useFontObjects == false
end

function Styling:DisableCustomFonts(info, value)
	return G_RLF.db.global.useFontObjects == true
end

function Styling:GetRowFontFace(info, value)
	return G_RLF.db.global.fontFace
end

function Styling:SetRowFontFace(info, value)
	G_RLF.db.global.fontFace = value
	G_RLF.LootDisplay:UpdateRowStyles()
end

function Styling:GetRowFontSize(info, value)
	return G_RLF.db.global.fontSize
end

function Styling:SetRowFontSize(info, value)
	G_RLF.db.global.fontSize = value
	G_RLF.LootDisplay:UpdateRowStyles()
end

function Styling:SecondaryTextDisabled()
	return not G_RLF.db.global.enabledSecondaryRowText
end

function Styling:GetSecondaryRowFontSize()
	return G_RLF.db.global.secondaryFontSize
end

function Styling:SetSecondaryRowFontSize(info, value)
	G_RLF.db.global.secondaryFontSize = value
	G_RLF.LootDisplay:UpdateRowStyles()
end

function Styling:SetRowFont(info, value)
	G_RLF.db.global.font = value
	G_RLF.LootDisplay:UpdateRowStyles()
end

function Styling:GetRowFont(info, value)
	return G_RLF.db.global.font
end
