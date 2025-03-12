---@type string, G_RLF
local addonName, G_RLF = ...

local ExperienceConfig = {}

G_RLF.defaults.global.xp = {
	enabled = true,
	experienceTextColor = { 1, 0, 1, 0.8 },
	showCurrentLevel = true,
	currentLevelColor = { 0.749, 0.737, 0.012, 1 },
	currentLevelTextWrapChar = G_RLF.WrapCharEnum.ANGLE,
}

G_RLF.options.args.features.args.experienceConfig = {
	type = "group",
	handler = ExperienceConfig,
	name = G_RLF.L["Experience Config"],
	order = G_RLF.mainFeatureOrder.XP,
	args = {
		enableXp = {
			type = "toggle",
			name = G_RLF.L["Enable Experience in Feed"],
			desc = G_RLF.L["EnableXPDesc"],
			width = "double",
			get = function()
				return G_RLF.db.global.xp.enabled
			end,
			set = function(_, value)
				G_RLF.db.global.xp.enabled = value
			end,
			order = 1,
		},
		xpOptions = {
			type = "group",
			name = G_RLF.L["Experience Options"],
			inline = true,
			order = 2,
			disabled = function()
				return not G_RLF.db.global.xp.enabled
			end,
			args = {
				experienceTextColor = {
					type = "color",
					name = G_RLF.L["Experience Text Color"],
					desc = G_RLF.L["ExperienceTextColorDesc"],
					width = "double",
					get = function()
						return unpack(G_RLF.db.global.xp.experienceTextColor)
					end,
					set = function(_, r, g, b, a)
						G_RLF.db.global.xp.experienceTextColor = { r, g, b, a }
					end,
					order = 1,
				},
				currentLevelOptions = {
					type = "group",
					inline = true,
					name = G_RLF.L["Current Level Options"],
					order = 2,
					args = {
						showCurrentLevel = {
							type = "toggle",
							name = G_RLF.L["Show Current Level"],
							desc = G_RLF.L["ShowCurrentLevelDesc"],
							width = "double",
							get = function()
								return G_RLF.db.global.xp.showCurrentLevel
							end,
							set = function(_, value)
								G_RLF.db.global.xp.showCurrentLevel = value
							end,
							order = 2,
						},
						currentLevelColor = {
							type = "color",
							name = G_RLF.L["Current Level Color"],
							desc = G_RLF.L["CurrentLevelColorDesc"],
							disabled = function()
								return not G_RLF.db.global.xp.showCurrentLevel
							end,
							width = "double",
							get = function()
								return unpack(G_RLF.db.global.xp.currentLevelColor)
							end,
							set = function(_, r, g, b, a)
								G_RLF.db.global.xp.currentLevelColor = { r, g, b, a }
							end,
							order = 3,
						},
						currentLevelTextWrapChar = {
							type = "select",
							name = G_RLF.L["Current Level Text Wrap Character"],
							desc = G_RLF.L["CurrentLevelTextWrapCharDesc"],
							disabled = function()
								return not G_RLF.db.global.xp.showCurrentLevel
							end,
							get = function()
								return G_RLF.db.global.xp.currentLevelTextWrapChar
							end,
							set = function(_, value)
								G_RLF.db.global.xp.currentLevelTextWrapChar = value
							end,
							values = G_RLF.WrapCharOptions,
							style = "dropdown",
							order = 4,
						},
					},
				},
			},
		},
	},
}
