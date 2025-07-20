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
	enableTransmogEffect = true,
	enableBlizzardTransmogSound = true,
	enableIcon = true,
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
		transmogOptions = {
			type = "group",
			name = G_RLF.L["Transmog Options"],
			inline = true,
			disabled = function()
				return not G_RLF.db.global.transmog.enabled
			end,
			order = 2,
			args = {
				showIcon = {
					type = "toggle",
					name = G_RLF.L["Show Transmog Icon"],
					desc = G_RLF.L["ShowTransmogIconDesc"],
					width = "double",
					disabled = function()
						return G_RLF.db.global.misc.hideAllIcons
					end,
					get = function(info, value)
						return G_RLF.db.global.transmog.enableIcon
					end,
					set = function(info, value)
						G_RLF.db.global.transmog.enableIcon = value
					end,
					order = 0.5,
				},
				enableTransmogEffect = {
					type = "toggle",
					name = G_RLF.L["Enable Transmog Effect"],
					desc = G_RLF.L["EnableTransmogEffectDesc"],
					width = "double",
					get = function(info, value)
						return G_RLF.db.global.transmog.enableTransmogEffect
					end,
					set = function(info, value)
						G_RLF.db.global.transmog.enableTransmogEffect = value
					end,
					order = 1,
					disabled = function()
						return not G_RLF:IsRetail()
					end,
				},
				enableBlizzardTransmogSound = {
					type = "toggle",
					name = G_RLF.L["Enable Blizzard Transmog Sound"],
					desc = G_RLF.L["EnableBlizzardTransmogSoundDesc"],
					width = "double",
					get = function(info, value)
						return G_RLF.db.global.transmog.enableBlizzardTransmogSound
					end,
					set = function(info, value)
						G_RLF.db.global.transmog.enableBlizzardTransmogSound = value
					end,
					order = 2,
					disabled = function()
						return not G_RLF:IsRetail()
					end,
				},
				testTransmogSound = {
					type = "execute",
					name = G_RLF.L["Test Transmog Sound"],
					desc = G_RLF.L["TestTransmogSoundDesc"],
					width = "double",
					disabled = function()
						return not G_RLF:IsRetail() or not G_RLF.db.global.transmog.enableBlizzardTransmogSound
					end,
					func = function()
						PlaySound(SOUNDKIT.UI_COSMETIC_ITEM_TOAST_SHOW)
					end,
				},
			},
		},
	},
}
