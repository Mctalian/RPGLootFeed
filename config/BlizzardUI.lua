local addonName, G_RLF = ...

local BlizzardUI = {}

G_RLF.defaults.global.enableAutoLoot = false
G_RLF.defaults.global.disableBlizzLootToasts = false
G_RLF.defaults.global.disableBlizzMoneyAlerts = false
G_RLF.defaults.global.bossBannerConfig = G_RLF.DisableBossBanner.ENABLED

G_RLF.options.args.blizz = {
	type = "group",
	handler = BlizzardUI,
	name = G_RLF.L["Blizzard UI"],
	desc = G_RLF.L["BlizzUIDesc"],
	order = 9,
	args = {
		enableAutoLoot = {
			type = "toggle",
			name = G_RLF.L["Enable Auto Loot"],
			desc = G_RLF.L["EnableAutoLootDesc"],
			get = "GetEnableAutoLoot",
			set = "SetEnableAutoLoot",
			order = 1,
		},
		alerts = {
			type = "header",
			name = G_RLF.L["Alerts"],
			order = 2,
		},
		disableLootToast = {
			type = "toggle",
			name = G_RLF.L["Disable Loot Toasts"],
			desc = G_RLF.L["DisableLootToastDesc"],
			get = "GetDisableLootToast",
			set = "SetDisableLootToast",
			order = 3,
		},
		disableMoneyAlert = {
			type = "toggle",
			name = G_RLF.L["Disable Money Alerts"],
			desc = G_RLF.L["DisableMoneyAlertsDesc"],
			get = "GetDisableMoneyAlerts",
			set = "SetDisableMoneyAlerts",
			order = 4,
		},
		bossBanner = {
			type = "select",
			name = G_RLF.L["Disable Boss Banner Elements"],
			desc = G_RLF.L["DisableBossBannerDesc"],
			get = "GetBossBannerConfig",
			set = "SetBossBannerConfig",
			width = "double",
			values = {
				[G_RLF.DisableBossBanner.ENABLED] = G_RLF.L["Do not disable BossBanner"],
				[G_RLF.DisableBossBanner.FULLY_DISABLE] = G_RLF.L["Disable All BossBanner"],
				[G_RLF.DisableBossBanner.DISABLE_LOOT] = G_RLF.L["Disable All BossBanner Loot"],
				[G_RLF.DisableBossBanner.DISABLE_MY_LOOT] = G_RLF.L["Only Disable My BossBanner Loot"],
				[G_RLF.DisableBossBanner.DISABLE_GROUP_LOOT] = G_RLF.L["Disable Party/Raid Loot"],
			},
			order = 5,
		},
		chat = {
			type = "header",
			name = G_RLF.L["Chat"],
			order = 6,
		},
		disableLootChatMessages = {
			type = "execute",
			name = G_RLF.L["Disable Loot Chat Messages"],
			desc = G_RLF.L["DisableLootChatMessagesDesc"],
			width = "double",
			func = "DisableLootChatMessages",
			order = 7,
		},
		disableCurrencyChatMessages = {
			type = "execute",
			name = G_RLF.L["Disable Currency Chat Messages"],
			desc = G_RLF.L["DisableCurrencyChatMessagesDesc"],
			width = "double",
			func = "DisableCurrencyChatMessages",
			order = 8,
		},
		disableMoneyChatMessages = {
			type = "execute",
			name = G_RLF.L["Disable Money Chat Messages"],
			desc = G_RLF.L["DisableMoneyChatMessagesDesc"],
			width = "double",
			func = "DisableMoneyChatMessages",
			order = 9,
		},
		disableXpChatMessages = {
			type = "execute",
			name = G_RLF.L["Disable Experience Chat Messages"],
			desc = G_RLF.L["DisableExperienceChatMessagesDesc"],
			width = "double",
			func = "DisableExperienceChatMessages",
			order = 10,
		},
		disableRepChatMessages = {
			type = "execute",
			name = G_RLF.L["Disable Reputation Chat Messages"],
			desc = G_RLF.L["DisableReputationChatMessagesDesc"],
			width = "double",
			func = "DisableReputationChatMessages",
			order = 11,
		},
	},
}

function BlizzardUI:SetDisableLootToast(info, value)
	G_RLF.db.global.disableBlizzLootToasts = value
end

function BlizzardUI:GetDisableLootToast(info, value)
	return G_RLF.db.global.disableBlizzLootToasts
end

function BlizzardUI:GetDisableMoneyAlerts(info, value)
	return G_RLF.db.global.disableBlizzMoneyAlerts
end

function BlizzardUI:SetDisableMoneyAlerts(info, value)
	G_RLF.db.global.disableBlizzMoneyAlerts = value
end

function BlizzardUI:GetEnableAutoLoot(info, value)
	return G_RLF.db.global.enableAutoLoot
end

function BlizzardUI:SetEnableAutoLoot(info, value)
	C_CVar.SetCVar("autoLootDefault", value and "1" or "0")
	G_RLF.db.global.enableAutoLoot = value
end

function BlizzardUI:SetBossBannerConfig(info, value)
	G_RLF.db.global.bossBannerConfig = value
end

function BlizzardUI:GetBossBannerConfig(info, value)
	return G_RLF.db.global.bossBannerConfig
end

function BlizzardUI:DisableLootChatMessages()
	ChatFrameUtil.ForEachChatFrame(function(frame)
		ChatFrame_RemoveMessageGroup(frame, "LOOT")
	end)
	G_RLF:Print(G_RLF.L["Item Loot messages Disabled"])
end

function BlizzardUI:DisableCurrencyChatMessages()
	ChatFrameUtil.ForEachChatFrame(function(frame)
		ChatFrame_RemoveMessageGroup(frame, "CURRENCY")
	end)
	G_RLF:Print(G_RLF.L["Currency messages Disabled"])
end

function BlizzardUI:DisableMoneyChatMessages()
	ChatFrameUtil.ForEachChatFrame(function(frame)
		ChatFrame_RemoveMessageGroup(frame, "MONEY")
	end)
	G_RLF:Print(G_RLF.L["Money messages Disabled"])
end

function BlizzardUI:DisableExperienceChatMessages()
	ChatFrameUtil.ForEachChatFrame(function(frame)
		ChatFrame_RemoveMessageGroup(frame, "COMBAT_XP_GAIN")
	end)
	G_RLF:Print(G_RLF.L["XP messages Disabled"])
end

function BlizzardUI:DisableReputationChatMessages()
	ChatFrameUtil.ForEachChatFrame(function(frame)
		ChatFrame_RemoveMessageGroup(frame, "COMBAT_FACTION_CHANGE")
	end)
	G_RLF:Print(G_RLF.L["Rep messages Disabled"])
end
