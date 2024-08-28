local Styling = {}

G_RLF.defaults.global.leftAlign = true
G_RLF.defaults.global.rowBackgroundGradientStart = { 0.1, 0.1, 0.1, 0.8 } -- Default to dark grey with 80% opacity
G_RLF.defaults.global.rowBackgroundGradientEnd = { 0.1, 0.1, 0.1, 0 } -- Default to dark grey with 0% opacity
G_RLF.defaults.global.font = "GameFontNormalSmall"

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
		gradientStart = {
			type = "color",
			name = G_RLF.L["Background Gradient Start"],
			desc = G_RLF.L["GradientStartDesc"],
			hasAlpha = true,
			get = "GetGradientStartColor",
			set = "SetGradientStartColor",
			order = 2,
		},
		gradientEnd = {
			type = "color",
			name = G_RLF.L["Background Gradient End"],
			desc = G_RLF.L["GradientEndDesc"],
			hasAlpha = true,
			get = "GetGradientEndColor",
			set = "SetGradientEndColor",
			order = 3,
		},
		font = {
			type = "select",
			name = G_RLF.L["Font"],
			desc = G_RLF.L["FontDesc"],
			width = "double",
			values = "GetFonts",
			get = "GetRowFont",
			set = "SetRowFont",
			order = 4,
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
end

function Styling:GetGradientEndColor(info, value)
	local r, g, b, a = unpack(G_RLF.db.global.rowBackgroundGradientEnd)
	return r, g, b, a
end

function Styling:SetGradientEndColor(info, r, g, b, a)
	G_RLF.db.global.rowBackgroundGradientEnd = { r, g, b, a }
end

function Styling:SetLeftAlign(info, value)
	G_RLF.db.global.leftAlign = value
	G_RLF.LootDisplay:UpdateRowStyles()
end

function Styling:GetLeftAlign(info, value)
	return G_RLF.db.global.leftAlign
end

function Styling:SetRowFont(info, value)
	G_RLF.db.global.font = value
	G_RLF.LootDisplay:UpdateRowStyles()
end

function Styling:GetRowFont(info, value)
	return G_RLF.db.global.font
end
