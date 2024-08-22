local addonName = G_RLF.addonName
RLF = G_RLF.RLF
G_RLF.L = LibStub("AceLocale-3.0"):GetLocale(G_RLF.localeName)

function RLF:OnInitialize()
    G_RLF.db = LibStub("AceDB-3.0"):New(G_RLF.dbName, G_RLF.defaults, true)
    LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, G_RLF.options)
    G_RLF.LootDisplay:Initialize()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
    self:RegisterEvent("CHAT_MSG_LOOT")
    self:RegisterEvent("CHAT_MSG_MONEY")
    self:RegisterEvent("LOOT_READY")
    self:RegisterEvent("PLAYER_XP_UPDATE")
    self:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
    self:RegisterChatCommand("rlf", "SlashCommand")
    self:RegisterChatCommand("RLF", "SlashCommand")
    self:RegisterChatCommand("rpglootfeed", "SlashCommand")
    self:RegisterChatCommand("rpgLootFeed", "SlashCommand")
end

function RLF:SlashCommand(msg, editBox)
    LibStub("AceConfigDialog-3.0"):Open(addonName)
end

function RLF:PLAYER_ENTERING_WORLD(event, isLogin, isReload)
    self:InitializeOptions()
    self:CheckForLootAlertSystem()
    self:CheckForBossBanner()
    G_RLF.Rep:RefreshRepData()
    G_RLF.Xp:Snapshot()
    if isLogin and isReload == false then
        self:Print(G_RLF.L["Welcome"])
        if G_RLF.db.global.enableAutoLoot then
            C_CVar.SetCVar("autoLootDefault", "1")
        end
    end
end

function RLF:CHAT_MSG_COMBAT_FACTION_CHANGE(event, text)
    G_RLF.Rep:FindDelta()
end

function RLF:CURRENCY_DISPLAY_UPDATE(eventName, ...)
    G_RLF.Currency:OnUpdate(...)
end

function RLF:CHAT_MSG_LOOT(eventName, ...)
    G_RLF.Loot:OnItemLooted(...)
end

function RLF:LOOT_READY(eventName)
    G_RLF.Money:Snapshot()
end

function RLF:CHAT_MSG_MONEY(eventName, msg)
    G_RLF.Money:OnMoneyLooted(msg)
end

function RLF:PLAYER_XP_UPDATE(eventName, unitTarget)
    G_RLF.Xp:OnXpChange(unitTarget)
end

function RLF:InitializeOptions()
    if self.optionsFrame == nil then
        self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, addonName)
    end
end

local lootAlertAttempts = 0
function RLF:CheckForLootAlertSystem()
    if self:IsHooked(LootAlertSystem, "AddAlert") then
        return
    end
    if LootAlertSystem and LootAlertSystem.AddAlert then
        self:RawHook(LootAlertSystem, "AddAlert", "InterceptAddAlert", true)
    else
        if lootAlertAttempts <= 30 then
            lootAlertAttempts = lootAlertAttempts + 1
            -- Keep checking until it's available
            self:ScheduleTimer("CheckForLootAlertSystem", 1)
        else
            self:Print(G_RLF.L["AddLootAlertUnavailable"])
            self:Print(G_RLF.L["Issues"])
        end
    end
end

local bossBannerAttempts = 0
function RLF:CheckForBossBanner()
    if self:IsHooked(BossBanner, "OnEvent") then
        return
    end
    if BossBanner then
        self:RawHookScript(BossBanner, "OnEvent", "InterceptBossBannerAlert", true)
    else
        if bossBannerAttempts <= 30 then
            bossBannerAttempts = bossBannerAttempts + 1
            -- Keep checking until it's available
            self:ScheduleTimer("CheckForBossBanner", 1)
        else
            self:Print(G_RLF.L["BossBannerAlertUnavailable"])
            self:Print(G_RLF.L["Issues"])
        end
    end
end

function RLF:InterceptBossBannerAlert(s, event, ...)
    if G_RLF.db.global.bossBannerConfig == G_RLF.DisableBossBanner.FULLY_DISABLE then
        return
    end

    if G_RLF.db.global.bossBannerConfig == G_RLF.DisableBossBanner.DISABLE_LOOT and event == "ENCOUNTER_LOOT_RECEIVED" then
        return
    end

    local _, _, _, _, playerName, _ = ...;
    local myGuid = GetPlayerGuid()
    local myName, _ = GetNameAndServerNameFromGUID(myGuid)
    if G_RLF.db.global.bossBannerConfig == G_RLF.DisableBossBanner.DISABLE_MY_LOOT and event == "ENCOUNTER_LOOT_RECEIVED" and playerName == myName then
        return
    end

    if G_RLF.db.global.bossBannerConfig == G_RLF.DisableBossBanner.DISABLE_GROUP_LOOT and event == "ENCOUNTER_LOOT_RECEIVED" and playerName ~= myName then
        return
    end
    -- Call the original AddAlert function if not blocked
    self.hooks[BossBanner].OnEvent(s, event, ...)
end

function RLF:InterceptAddAlert(frame, ...)
    if G_RLF.db.global.disableBlizzLootToasts then
        return
    end
    -- Call the original AddAlert function if not blocked
    self.hooks[LootAlertSystem].AddAlert(frame, ...)
end
