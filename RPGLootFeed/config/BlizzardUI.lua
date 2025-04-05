---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

local BlizzardUI = {}

---@class RLF_DBGlobal
G_RLF.defaults.global = G_RLF.defaults.global or {}

---@class RLF_ConfigBlizzardUI
G_RLF.defaults.global.blizzOverrides = {
	enableAutoLoot = false,
	disableBlizzLootToasts = false,
	disableBlizzMoneyAlerts = false,
	bossBannerConfig = G_RLF.DisableBossBanner.ENABLED,
}

G_RLF.options.args.blizz = {
	type = "group",
	handler = BlizzardUI,
	name = G_RLF.L["Blizzard UI"],
	desc = G_RLF.L["BlizzUIDesc"],
	order = G_RLF.level1OptionsOrder.blizz,
	args = {
		enableAutoLoot = {
			type = "toggle",
			name = G_RLF.L["Enable Auto Loot"],
			desc = G_RLF.L["EnableAutoLootDesc"],
			get = function(info, value)
				return G_RLF.db.global.blizzOverrides.enableAutoLoot
			end,
			set = function(info, value)
				C_CVar.SetCVar("autoLootDefault", value and "1" or "0")
				G_RLF.db.global.blizzOverrides.enableAutoLoot = value
			end,
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
			get = function(info, value)
				return G_RLF.db.global.blizzOverrides.disableBlizzLootToasts
			end,
			set = function(info, value)
				G_RLF.db.global.blizzOverrides.disableBlizzLootToasts = value
			end,
			order = 3,
		},
		disableMoneyAlert = {
			type = "toggle",
			name = G_RLF.L["Disable Money Alerts"],
			desc = G_RLF.L["DisableMoneyAlertsDesc"],
			get = function(info, value)
				return G_RLF.db.global.blizzOverrides.disableBlizzMoneyAlerts
			end,
			set = function(info, value)
				G_RLF.db.global.blizzOverrides.disableBlizzMoneyAlerts = value
			end,
			order = 4,
		},
		bossBanner = {
			type = "select",
			name = G_RLF.L["Disable Boss Banner Elements"],
			desc = G_RLF.L["DisableBossBannerDesc"],
			get = function(info, value)
				return G_RLF.db.global.blizzOverrides.bossBannerConfig
			end,
			set = function(info, value)
				G_RLF.db.global.blizzOverrides.bossBannerConfig = value
			end,
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
			func = function()
				ChatFrameUtil.ForEachChatFrame(function(frame)
					ChatFrame_RemoveMessageGroup(frame, "LOOT")
				end)
				G_RLF:Print(G_RLF.L["Item Loot messages Disabled"])
			end,
			order = 7,
		},
		disableCurrencyChatMessages = {
			type = "execute",
			name = G_RLF.L["Disable Currency Chat Messages"],
			desc = G_RLF.L["DisableCurrencyChatMessagesDesc"],
			width = "double",
			func = function()
				ChatFrameUtil.ForEachChatFrame(function(frame)
					ChatFrame_RemoveMessageGroup(frame, "CURRENCY")
				end)
				G_RLF:Print(G_RLF.L["Currency messages Disabled"])
			end,
			order = 8,
		},
		disableMoneyChatMessages = {
			type = "execute",
			name = G_RLF.L["Disable Money Chat Messages"],
			desc = G_RLF.L["DisableMoneyChatMessagesDesc"],
			width = "double",
			func = function()
				ChatFrameUtil.ForEachChatFrame(function(frame)
					ChatFrame_RemoveMessageGroup(frame, "MONEY")
				end)
				G_RLF:Print(G_RLF.L["Money messages Disabled"])
			end,
			order = 9,
		},
		disableXpChatMessages = {
			type = "execute",
			name = G_RLF.L["Disable Experience Chat Messages"],
			desc = G_RLF.L["DisableExperienceChatMessagesDesc"],
			width = "double",
			func = function()
				ChatFrameUtil.ForEachChatFrame(function(frame)
					ChatFrame_RemoveMessageGroup(frame, "COMBAT_XP_GAIN")
				end)
				G_RLF:Print(G_RLF.L["XP messages Disabled"])
			end,
			order = 10,
		},
		disableRepChatMessages = {
			type = "execute",
			name = G_RLF.L["Disable Reputation Chat Messages"],
			desc = G_RLF.L["DisableReputationChatMessagesDesc"],
			width = "double",
			func = function()
				ChatFrameUtil.ForEachChatFrame(function(frame)
					ChatFrame_RemoveMessageGroup(frame, "COMBAT_FACTION_CHANGE")
				end)
				G_RLF:Print(G_RLF.L["Rep messages Disabled"])
			end,
			order = 11,
		},
	},
}
