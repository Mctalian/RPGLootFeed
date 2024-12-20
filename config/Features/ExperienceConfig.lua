local addonName, G_RLF = ...

local ExperienceConfig = {}

G_RLF.defaults.global.xp = {
	experienceTextColor = { 1, 0, 1, 0.8 },
	showCurrentLevel = true,
	currentLevelColor = { 0.749, 0.737, 0.012, 1 },
}

G_RLF.options.args.features.args.experienceConfig = {
	type = "group",
	handler = ExperienceConfig,
	name = G_RLF.L["Experience Config"],
	order = 2.3,
	args = {
		enableXp = {
			type = "toggle",
			name = G_RLF.L["Enable Experience in Feed"],
			desc = G_RLF.L["EnableXPDesc"],
			width = "double",
			get = function()
				return G_RLF.db.global.xpFeed
			end,
			set = function(_, value)
				G_RLF.db.global.xpFeed = value
			end,
			order = 1,
		},
		xpOptions = {
			type = "group",
			name = G_RLF.L["Experience Options"],
			inline = true,
			order = 2,
			disabled = function()
				return not G_RLF.db.global.xpFeed
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
			},
		},
	},
}
