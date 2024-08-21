local BlizzardUI = {}

G_RLF.defaults.global.enableAutoLoot = false
G_RLF.defaults.global.disableBlizzLootToasts = false
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
          order = 1
      },
      alerts = {
          type = "header",
          name = G_RLF.L["Alerts"],
          order = 2
      },
      disableLootToast = {
          type = "toggle",
          name = G_RLF.L["Disable Loot Toasts"],
          desc = G_RLF.L["DisableLootToastDesc"],
          get = "GetDisableLootToast",
          set = "SetDisableLootToast",
          order = 3
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
          order = 4
      },
      chat = {
          type = "header",
          name = G_RLF.L["Chat"],
          order = 5
      },
      disableLootChatMessages = {
          type = "execute",
          name = G_RLF.L["Disable Loot Chat Messages"],
          desc = G_RLF.L["DisableLootChatMessagesDesc"],
          width = "double",
          func = "DisableLootChatMessages",
          order = 6
      },
      disableCurrencyChatMessages = {
          type = "execute",
          name = G_RLF.L["Disable Currency Chat Messages"],
          desc = G_RLF.L["DisableCurrencyChatMessagesDesc"],
          width = "double",
          func = "DisableCurrencyChatMessages",
          order = 7
      },
      disableMoneyChatMessages = {
          type = "execute",
          name = G_RLF.L["Disable Money Chat Messages"],
          desc = G_RLF.L["DisableMoneyChatMessagesDesc"],
          width = "double",
          func = "DisableMoneyChatMessages",
          order = 8
      },
      disableXpChatMessages = {
        type = "execute",
        name = G_RLF.L["Disable Experience Chat Messages"],
        desc = G_RLF.L["DisableExperienceChatMessagesDesc"],
        width = "double",
        func = "DisableExperienceChatMessages",
        order = 9
    },
  }
}


function BlizzardUI:SetDisableLootToast(info, value)
  G_RLF.db.global.disableBlizzLootToasts = value
end

function BlizzardUI:GetDisableLootToast(info, value)
  return G_RLF.db.global.disableBlizzLootToasts
end

function BlizzardUI:GetEnableAutoLoot(info, value)
  return G_RLF.db.global.enableAutoLoot
end

function BlizzardUI:SetEnableAutoLoot(info, value)
  C_CVar.SetCVar("autoLootDefault", value and "1" or "0");
  G_RLF.db.global.enableAutoLoot = value
end

function BlizzardUI:SetBossBannerConfig(info, value)
  G_RLF.db.global.bossBannerConfig = value
  G_RLF:Print(G_RLF.db.global.bossBannerConfig)
end

function BlizzardUI:GetBossBannerConfig(info, value)
  return G_RLF.db.global.bossBannerConfig
end

function BlizzardUI:DisableLootChatMessages()
  ChatFrameUtil.ForEachChatFrame(function (frame)
      ChatFrame_RemoveMessageGroup(frame, "LOOT")
  end)
  G_RLF:Print(G_RLF.L["Item Loot messages Disabled"])
end

function BlizzardUI:DisableCurrencyChatMessages()
  ChatFrameUtil.ForEachChatFrame(function (frame)
      ChatFrame_RemoveMessageGroup(frame, "CURRENCY")
  end)
  G_RLF:Print(G_RLF.L["Currency messages Disabled"])
end

function BlizzardUI:DisableMoneyChatMessages()
  ChatFrameUtil.ForEachChatFrame(function (frame)
      ChatFrame_RemoveMessageGroup(frame, "MONEY")
  end)
  G_RLF:Print(G_RLF.L["Money messages Disabled"])
end

function BlizzardUI:DisableExperienceChatMessages()
  ChatFrameUtil.ForEachChatFrame(function (frame)
      ChatFrame_RemoveMessageGroup(frame, "COMBAT_XP_GAIN")
  end)
  G_RLF:Print(G_RLF.L["XP messages Disabled"])
end
