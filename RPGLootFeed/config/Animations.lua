---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

local Animations = {}

---@class RLF_DBGlobal
G_RLF.defaults.global = G_RLF.defaults.global or {}

---@class RLF_ConfigAnimations
G_RLF.defaults.global.animations = {
	enter = {
		type = G_RLF.EnterAnimationType.FADE,
		duration = 0.3,
		slide = {
			direction = G_RLF.SlideDirection.LEFT,
		},
	},
	exit = {
		type = G_RLF.ExitAnimationType.FADE,
		duration = 1,
		fadeOutDelay = 5,
	},
	hover = {
		enabled = true,
		alpha = 0.25,
		baseDuration = 0.3,
	},
	update = {
		disableHighlight = false,
		duration = 0.2,
		loop = false,
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
					max = 60,
					get = function()
						return G_RLF.db.global.animations.exit.fadeOutDelay
					end,
					set = function(info, value)
						G_RLF.db.global.animations.exit.fadeOutDelay = value
						G_RLF.LootDisplay:UpdateFadeDelay()
					end,
					order = 1,
				},
				exitAnimationType = {
					type = "select",
					name = G_RLF.L["Exit Animation Type"],
					desc = G_RLF.L["ExitAnimationTypeDesc"],
					values = {
						[G_RLF.ExitAnimationType.NONE] = G_RLF.L["None"],
						[G_RLF.ExitAnimationType.FADE] = G_RLF.L["Fade"],
					},
					get = function()
						return G_RLF.db.global.animations.exit.type
					end,
					set = function(info, value)
						G_RLF.db.global.animations.exit.type = value
					end,
					order = 2,
				},
				exitAnimationDuration = {
					type = "range",
					name = G_RLF.L["Exit Animation Duration"],
					desc = G_RLF.L["ExitAnimationDurationDesc"],
					min = 0.1,
					max = 3,
					step = 0.1,
					get = function()
						return G_RLF.db.global.animations.exit.duration
					end,
					set = function(info, value)
						G_RLF.db.global.animations.exit.duration = value
						G_RLF.LootDisplay:UpdateFadeDelay()
					end,
					order = 3,
				},
			},
		},
		hoverAnimations = {
			type = "group",
			name = G_RLF.L["Hover Animation"],
			desc = G_RLF.L["HoverAnimationDesc"],
			inline = true,
			order = 3,
			args = {
				enabled = {
					type = "toggle",
					name = G_RLF.L["Enable Hover Animation"],
					desc = G_RLF.L["EnableHoverAnimationDesc"],
					get = function()
						return G_RLF.db.global.animations.hover.enabled
					end,
					set = function(info, value)
						G_RLF.db.global.animations.hover.enabled = value
					end,
					order = 1,
				},
				alpha = {
					type = "range",
					name = G_RLF.L["Hover Alpha"],
					desc = G_RLF.L["HoverAlphaDesc"],
					min = 0,
					max = 1,
					step = 0.05,
					disabled = function()
						return not G_RLF.db.global.animations.hover.enabled
					end,
					get = function()
						return G_RLF.db.global.animations.hover.alpha
					end,
					set = function(info, value)
						G_RLF.db.global.animations.hover.alpha = value
					end,
					order = 2,
				},
				baseDuration = {
					type = "range",
					name = G_RLF.L["Base Duration"],
					desc = G_RLF.L["BaseDurationDesc"],
					min = 0.1,
					max = 1,
					step = 0.1,
					disabled = function()
						return not G_RLF.db.global.animations.hover.enabled
					end,
					get = function()
						return G_RLF.db.global.animations.hover.baseDuration
					end,
					set = function(info, value)
						G_RLF.db.global.animations.hover.baseDuration = value
					end,
					order = 3,
				},
			},
		},
		updateAnimations = {
			type = "group",
			name = G_RLF.L["Update Animations"],
			desc = G_RLF.L["UpdateAnimationsDesc"],
			inline = true,
			order = 4,
			args = {
				disableHighlight = {
					type = "toggle",
					name = G_RLF.L["Disable Highlight"],
					desc = G_RLF.L["DisableHighlightDesc"],
					get = function()
						return G_RLF.db.global.animations.update.disableHighlight
					end,
					set = function(info, value)
						G_RLF.db.global.animations.update.disableHighlight = value
					end,
					order = 1,
				},
				duration = {
					type = "range",
					name = G_RLF.L["Update Animation Duration"],
					desc = G_RLF.L["UpdateAnimationDurationDesc"],
					min = 0.1,
					max = 1,
					step = 0.1,
					disabled = function()
						return G_RLF.db.global.animations.update.disableHighlight
					end,
					get = function()
						return G_RLF.db.global.animations.update.duration
					end,
					set = function(info, value)
						G_RLF.db.global.animations.update.duration = value
					end,
					order = 2,
				},
				loop = {
					type = "toggle",
					name = G_RLF.L["Loop Update Highlight"],
					desc = G_RLF.L["LoopUpdateHighlightDesc"],
					disabled = function()
						return G_RLF.db.global.animations.update.disableHighlight
					end,
					get = function()
						return G_RLF.db.global.animations.update.loop
					end,
					set = function(info, value)
						G_RLF.db.global.animations.update.loop = value
					end,
					order = 3,
				},
			},
		},
	},
}
