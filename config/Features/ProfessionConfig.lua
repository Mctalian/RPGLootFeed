local addonName, G_RLF = ...

local ProfessionConfig = {}

G_RLF.defaults.global.prof = {
	enabled = true,
	showSkillChange = true,
	skillColor = { 0.333, 0.333, 1.0, 1.0 },
	skillTextWrapChar = G_RLF.WrapCharEnum.BRACKET,
}

G_RLF.options.args.features.args.professionConfig = {
	type = "group",
	handler = ProfessionConfig,
	name = G_RLF.L["Profession Config"],
	order = G_RLF.mainFeatureOrder.Skills,
	args = {
		enableProfession = {
			type = "toggle",
			name = G_RLF.L["Enable Professions in Feed"],
			desc = G_RLF.L["EnableProfDesc"],
			width = "double",
			get = function()
				return G_RLF.db.global.prof.enabled
			end,
			set = function(_, value)
				G_RLF.db.global.prof.enabled = value
				if value then
					G_RLF.RLF:EnableModule("Profession")
				else
					G_RLF.RLF:DisableModule("Profession")
				end
			end,
			order = 1,
		},
		professionOptions = {
			type = "group",
			inline = true,
			name = G_RLF.L["Profession Options"],
			disabled = function()
				return not G_RLF.db.global.prof.enabled
			end,
			order = 1.1,
			args = {
				skillChangeOptions = {
					type = "group",
					inline = true,
					name = G_RLF.L["Skill Change Options"],
					order = 1,
					args = {
						showSkillChange = {
							type = "toggle",
							name = G_RLF.L["Show Skill Change"],
							desc = G_RLF.L["ShowSkillChangeDesc"],
							width = "double",
							get = function()
								return G_RLF.db.global.prof.showSkillChange
							end,
							set = function(_, value)
								G_RLF.db.global.prof.showSkillChange = value
							end,
							order = 1,
						},
						skillColor = {
							type = "color",
							name = G_RLF.L["Skill Text Color"],
							desc = G_RLF.L["SkillColorDesc"],
							disabled = function()
								return not G_RLF.db.global.prof.showSkillChange
							end,
							width = "double",
							get = function()
								return unpack(G_RLF.db.global.prof.skillColor)
							end,
							set = function(_, r, g, b, a)
								G_RLF.db.global.prof.skillColor = { r, g, b, a }
							end,
							order = 2,
						},
						skillTextWrapChar = {
							type = "select",
							name = G_RLF.L["Skill Text Wrap Character"],
							desc = G_RLF.L["SkillTextWrapCharDesc"],
							disabled = function()
								return not G_RLF.db.global.prof.showSkillChange
							end,
							get = function()
								return G_RLF.db.global.prof.skillTextWrapChar
							end,
							set = function(_, value)
								G_RLF.db.global.prof.skillTextWrapChar = value
							end,
							values = G_RLF.WrapCharOptions,
							style = "dropdown",
							order = 3,
						},
					},
				},
			},
		},
	},
}
