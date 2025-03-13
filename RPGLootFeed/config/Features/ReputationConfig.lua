---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

local ReputationConfig = {}

G_RLF.defaults.global.rep = {
	enabled = true,
	defaultRepColor = { 0.5, 0.5, 1 },
	secondaryTextAlpha = 0.7,
	enableRepLevel = true,
	repLevelColor = { 0.5, 0.5, 1, 1 },
	repLevelTextWrapChar = G_RLF.WrapCharEnum.ANGLE,
}

G_RLF.options.args.features.args.repConfig = {
	type = "group",
	handler = ReputationConfig,
	name = G_RLF.L["Reputation Config"],
	order = G_RLF.mainFeatureOrder.Rep,
	args = {
		enableRep = {
			type = "toggle",
			name = G_RLF.L["Enable Reputation in Feed"],
			desc = G_RLF.L["EnableRepDesc"],
			width = "double",
			get = function()
				return G_RLF.db.global.rep.enabled
			end,
			set = function(_, value)
				G_RLF.db.global.rep.enabled = value
				if value then
					G_RLF.RLF:EnableModule("Reputation")
				else
					G_RLF.RLF:DisableModule("Reputation")
				end
			end,
			order = 1,
		},
		repOptions = {
			type = "group",
			inline = true,
			name = G_RLF.L["Reputation Options"],
			disabled = function()
				return not G_RLF.db.global.rep.enabled
			end,
			order = 1.1,
			args = {
				defaultRepColor = {
					type = "color",
					name = G_RLF.L["Default Rep Text Color"],
					desc = G_RLF.L["RepColorDesc"],
					get = function()
						return unpack(G_RLF.db.global.rep.defaultRepColor)
					end,
					set = function(_, r, g, b)
						G_RLF.db.global.rep.defaultRepColor = { r, g, b }
					end,
					order = 1,
				},
				secondaryTextAlpha = {
					type = "range",
					name = G_RLF.L["Secondary Text Alpha"],
					desc = G_RLF.L["SecondaryTextAlphaDesc"],
					min = 0,
					max = 1,
					step = 0.1,
					get = function()
						return G_RLF.db.global.rep.secondaryTextAlpha
					end,
					set = function(_, value)
						G_RLF.db.global.rep.secondaryTextAlpha = value
					end,
					order = 2,
				},
				repLevelOptions = {
					type = "group",
					inline = true,
					name = G_RLF.L["Reputation Level Options"],
					order = 3,
					args = {
						enableRepLevel = {
							type = "toggle",
							name = G_RLF.L["Enable Reputation Level"],
							desc = G_RLF.L["EnableRepLevelDesc"],
							width = "double",
							get = function()
								return G_RLF.db.global.rep.enableRepLevel
							end,
							set = function(_, value)
								G_RLF.db.global.rep.enableRepLevel = value
							end,
							order = 1,
						},
						repLevelColor = {
							type = "color",
							name = G_RLF.L["Reputation Level Color"],
							desc = G_RLF.L["RepLevelColorDesc"],
							disabled = function()
								return not G_RLF.db.global.rep.enableRepLevel
							end,
							width = "double",
							hasAlpha = true,
							get = function()
								return unpack(G_RLF.db.global.rep.repLevelColor)
							end,
							set = function(_, r, g, b, a)
								G_RLF.db.global.rep.repLevelColor = { r, g, b, a }
							end,
							order = 2,
						},
						repLevelWrapChar = {
							type = "select",
							name = G_RLF.L["Reputation Level Wrap Character"],
							desc = G_RLF.L["RepLevelWrapCharDesc"],
							disabled = function()
								return not G_RLF.db.global.rep.enableRepLevel
							end,
							values = G_RLF.WrapCharOptions,
							get = function()
								return G_RLF.db.global.rep.repLevelTextWrapChar
							end,
							set = function(_, value)
								G_RLF.db.global.rep.repLevelTextWrapChar = value
							end,
							order = 3,
						},
					},
				},
			},
		},
	},
}
