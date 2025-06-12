---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

local TransmogConfig = {}

local lsm = G_RLF.lsm

---@class RLF_DBGlobal
G_RLF.defaults.global = G_RLF.defaults.global or {}

---@class RLF_ConfigTransmog
G_RLF.defaults.global.transmog = {
	enabled = true,
}

G_RLF.options.args.features.args.transmogConfig = {
	type = "group",
	handler = TransmogConfig,
	name = G_RLF.L["Transmog Config"],
	order = G_RLF.mainFeatureOrder.Transmog,
	args = {
		enabled = {
			type = "toggle",
			name = G_RLF.L["Enable Transmog in Feed"],
			desc = G_RLF.L["EnableTransmogDesc"],
			width = "double",
			get = function(info, value)
				return G_RLF.db.global.transmog.enabled
			end,
			set = function(info, value)
				G_RLF.db.global.transmog.enabled = value
				if value then
					G_RLF.RLF:EnableModule(G_RLF.FeatureModule.Transmog)
				else
					G_RLF.RLF:DisableModule(G_RLF.FeatureModule.Transmog)
				end
			end,
			order = 1,
		},
	},
}
