local addonName, G_RLF = ...

local Animations = {}

G_RLF.defaults.global.animations = {
	enter = {
		type = G_RLF.EnterAnimationType.FADE,
		duration = 0.3,
		slide = {
			direction = G_RLF.SlideDirection.LEFT,
		},
	},
	exit = {
		type = G_RLF.EnterAnimationType.FADE,
		duration = 1,
		fadeOutDelay = 5,
	},
}

G_RLF.options.args.timing = {
	type = "group",
	handler = Animations,
	name = G_RLF.L["Animations"],
	desc = G_RLF.L["AnimationsDesc"],
	order = 8,
	args = {
		enterAnimations = {
			type = "group",
			name = G_RLF.L["Row Enter Animation"],
			desc = G_RLF.L["RowEnterAnimationDesc"],
			inline = true,
			order = 1,
			args = {
				enterAnimationType = {
					type = "select",
					name = G_RLF.L["Enter Animation Type"],
					desc = G_RLF.L["EnterAnimationTypeDesc"],
					values = {
						[G_RLF.EnterAnimationType.NONE] = G_RLF.L["None"],
						[G_RLF.EnterAnimationType.FADE] = G_RLF.L["Fade"],
						[G_RLF.EnterAnimationType.SLIDE] = G_RLF.L["Slide"],
					},
					get = function()
						return G_RLF.db.global.animations.enter.type
					end,
					set = function(info, value)
						G_RLF.db.global.animations.enter.type = value
						G_RLF.LootDisplay:UpdateEnterAnimation()
					end,
					order = 1,
				},
				enterAnimationDuration = {
					type = "range",
					name = G_RLF.L["Enter Animation Duration"],
					desc = G_RLF.L["EnterAnimationDurationDesc"],
					min = 0.1,
					max = 1,
					step = 0.1,
					get = function()
						return G_RLF.db.global.animations.enter.duration
					end,
					set = function(info, value)
						G_RLF.db.global.animations.enter.duration = value
						G_RLF.LootDisplay:UpdateEnterAnimation()
					end,
					order = 2,
				},
				enterSlideDirection = {
					type = "select",
					name = G_RLF.L["Slide Direction"],
					desc = G_RLF.L["SlideDirectionDesc"],
					hidden = function()
						return G_RLF.db.global.animations.enter.type ~= G_RLF.EnterAnimationType.SLIDE
					end,
					values = {
						[G_RLF.SlideDirection.LEFT] = G_RLF.L["Left"],
						[G_RLF.SlideDirection.RIGHT] = G_RLF.L["Right"],
						[G_RLF.SlideDirection.UP] = G_RLF.L["Up"],
						[G_RLF.SlideDirection.DOWN] = G_RLF.L["Down"],
					},
					get = function()
						return G_RLF.db.global.animations.enter.slide.direction
					end,
					set = function(info, value)
						G_RLF.db.global.animations.enter.slide.direction = value
						G_RLF.LootDisplay:UpdateEnterAnimation()
					end,
					order = 3,
				},
			},
		},
		exitAnimations = {
			type = "group",
			name = G_RLF.L["Row Exit Animation"],
			desc = G_RLF.L["RowExitAnimationDesc"],
			inline = true,
			order = 2,
			args = {
				fadeOutDelay = {
					type = "range",
					name = G_RLF.L["Fade Out Delay"],
					desc = G_RLF.L["FadeOutDelayDesc"],
					min = 1,
					max = 30,
					get = function()
						return G_RLF.db.global.animations.exit.fadeOutDelay
					end,
					set = function(info, value)
						G_RLF.db.global.animations.exit.fadeOutDelay = value
						G_RLF.LootDisplay:UpdateFadeDelay()
					end,
					order = 1,
				},
			},
		},
	},
}
