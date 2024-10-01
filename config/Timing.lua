local addonName, G_RLF = ...

local Timing = {}

G_RLF.defaults.global.fadeOutDelay = 5

G_RLF.options.args.timing = {
	type = "group",
	handler = Timing,
	name = G_RLF.L["Timing"],
	desc = G_RLF.L["TimingDesc"],
	order = 8,
	args = {
		fadeOutDelay = {
			type = "range",
			name = G_RLF.L["Fade Out Delay"],
			desc = G_RLF.L["FadeOutDelayDesc"],
			min = 1,
			max = 30,
			get = "GetFadeOutDelay",
			set = "SetFadeOutDelay",
			order = 1,
		},
	},
}

function Timing:SetFadeOutDelay(info, value)
	G_RLF.db.global.fadeOutDelay = value
	G_RLF.LootDisplay:UpdateFadeDelay()
end

function Timing:GetFadeOutDelay(info, value)
	return G_RLF.db.global.fadeOutDelay
end
