---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

local TravelPointsConfig = {}

---@class RLF_DBGlobal
G_RLF.defaults.global = G_RLF.defaults.global or {}

---@class RLF_ConfigTravelPoints
G_RLF.defaults.global.travelPoints = {
	enabled = true,
	textColor = { 1, 0.988, 0.498, 1 },
	enableIcon = true,
}

G_RLF.options.args.features.args.travelPoints = {
	type = "group",
	handler = TravelPointsConfig,
	name = G_RLF.L["Travel Points Config"],
	order = G_RLF.mainFeatureOrder.TravelPoints,
	disabled = function()
		return not G_RLF:IsRetail()
	end,
	args = {
		enable = {
			type = "toggle",
			name = G_RLF.L["Enable Travel Points in Feed"],
			desc = G_RLF.L["EnableTravelPointsDesc"],
			width = "double",
			disabled = function()
				return not G_RLF:IsRetail()
			end,
			get = function()
				return G_RLF.db.global.travelPoints.enabled
			end,
			set = function(_, value)
				G_RLF.db.global.travelPoints.enabled = value
			end,
			order = 1,
		},
		travelPointOptions = {
			type = "group",
			name = G_RLF.L["Travel Point Options"],
			inline = true,
			order = 2,
			disabled = function()
				return not G_RLF.db.global.travelPoints.enabled
			end,
			args = {
				showIcon = {
					type = "toggle",
					name = G_RLF.L["Show Travel Point Icon"],
					desc = G_RLF.L["ShowTravelPointIconDesc"],
					width = "double",
					disabled = function()
						return G_RLF.db.global.misc.hideAllIcons
					end,
					get = function()
						return G_RLF.db.global.travelPoints.enableIcon
					end,
					set = function(_, value)
						G_RLF.db.global.travelPoints.enableIcon = value
					end,
					order = 0.5,
				},
				textColor = {
					type = "color",
					name = G_RLF.L["Travel Points Text Color"],
					desc = G_RLF.L["TravelPointsTextColorDesc"],
					hasAlpha = true,
					width = "double",
					get = function()
						return unpack(G_RLF.db.global.travelPoints.textColor)
					end,
					set = function(_, r, g, b, a)
						G_RLF.db.global.travelPoints.textColor = { r, g, b, a }
					end,
					order = 1,
				},
			},
		},
	},
}
