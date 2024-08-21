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

function RLF:CHAT_MSG_COMBAT_FACTION_CHANGE(event, text)
    self:FindDelta()
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

function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end

local repData = {}
function RLF:RefreshRepData()
    local numFactions = C_Reputation.GetNumFactions()
    if numFactions <= 0 then
        return
    end

    for i = 1, numFactions do
        local factionData = C_Reputation.GetFactionDataByIndex(i)
        if not factionData.isHeader or factionData.isHeaderWithRep then
            repData[factionData.factionID] = factionData.currentStanding
            if C_Reputation.IsFactionParagon(factionData.factionID) then
                self:Print("Paragon " .. factionData.name .. " " .. factionData.currentStanding)
            end
            if C_Reputation.IsMajorFaction(factionData.factionID) then
                self:Print("Major " .. factionData.name)
                self:Print(dump(factionData))
            end
            -- self:Print(factionData.name .. " processed (" .. factionData.currentStanding .. "/" .. (factionData.currentReactionThreshold or factionData.nextReactionThreshold) .. ")")
        end
    end
end

function RLF:FindDelta()
    -- local numFactionElements = C_Reputation.GetNumFactions()
    -- local numFactions = 0
    -- for i = 1, numFactionElements do
    --     local factionData = C_Reputation.GetFactionDataByIndex(i)
    --     if not factionData.isHeader then
            
    --     end
    -- end
    -- if numFactions > #repData then
    --     for i = 1, numFactions do
    --         local fac
    --     end
    -- end
    for k, v in pairs(repData) do
        local factionData = C_Reputation.GetFactionDataByID(k)
        if factionData.currentStanding ~= v then
            G_RLF.LootDisplay:ShowRep(factionData.currentStanding - v, factionData)
        end
    end
    self:RefreshRepData()
end

local currentXP, currentMaxXP, currentLevel
function RLF:PLAYER_ENTERING_WORLD(event, isLogin, isReload)
    self:InitializeOptions()
    self:CheckForLootAlertSystem()
    self:CheckForBossBanner()
    self:RefreshRepData()
    currentXP = UnitXP("player")
    currentMaxXP = UnitXPMax("player")
    currentLevel = UnitLevel("player")
    if isLogin and isReload == false then
        self:Print(G_RLF.L["Welcome"])
        if G_RLF.db.global.enableAutoLoot then
            C_CVar.SetCVar("autoLootDefault", "1")
        end
    end
end

function RLF:CURRENCY_DISPLAY_UPDATE(eventName, currencyType, quantity, quantityChange, quantityGainSource,
    quantityLostSource)

    if not G_RLF.db.global.currencyFeed then
        return
    end

    if currencyType == nil or quantityChange <= 0 then
        return
    end

    local info = C_CurrencyInfo.GetCurrencyInfo(currencyType)
    if info == nil then
        return
    end

    G_RLF.LootDisplay:ShowLoot(info.currencyID, G_RLF:GetCurrencyLink(info.currencyID, info.name), info.iconFileID,
        quantityChange)
end

function RLF:CHAT_MSG_LOOT(eventName, ...)

    if not G_RLF.db.global.itemLootFeed then
        return
    end

    local msg, _, _, _, _, _, _, _, _, _, _, guid = ...
    local raidLoot = msg:match("HlootHistory:")
    if raidLoot then
        -- Ignore this message as it's a raid loot message
        return
    end
    -- This will not work if another addon is overriding formatting globals like LOOT_ITEM, LOOT_ITEM_MULTIPLE, etc.
    local me = guid == GetPlayerGuid()
    if not me then
        return
    end
    local itemID = msg:match("Hitem:(%d+)")
    if itemID ~= nil then
        local amount = msg:match("rx(%d+)") or 1
        local _, itemLink, _, _, _, _, _, _, _, itemTexture = C_Item.GetItemInfo(itemID)
        G_RLF.LootDisplay:ShowLoot(itemID, itemLink, itemTexture, amount)
    end
end

function RLF:LOOT_READY(eventName)
    -- Get current money to calculate the delta later
    self.startingMoney = GetMoney()
end

function RLF:CHAT_MSG_MONEY(eventName, msg)

    if not G_RLF.db.global.moneyFeed then
        return
    end

    local amountInCopper
    -- Old method that doesn't work well with other locales
    if self.startingMoney == nil then
        -- Initialize default values
        local gold, silver, copper = 0, 0, 0

        -- Patterns to match optional sections
        local goldPattern = "(%d+) " .. G_RLF.L["Gold"]
        local silverPattern = "(%d+) " .. G_RLF.L["Silver"]
        local copperPattern = "(%d+) " .. G_RLF.L["Copper"]

        -- Find and convert matches to numbers if they exist
        gold = tonumber(msg:match(goldPattern)) or gold
        silver = tonumber(msg:match(silverPattern)) or silver
        copper = tonumber(msg:match(copperPattern)) or copper

        amountInCopper = (gold * 100 * 100)
        amountInCopper = amountInCopper + (silver * 100)
        amountInCopper = amountInCopper + copper
    else
        amountInCopper = GetMoney() - self.startingMoney
        self.startingMoney = GetMoney()
    end
    G_RLF.LootDisplay:ShowMoney(amountInCopper)
end

function RLF:PLAYER_XP_UPDATE(eventName, unitTarget)

    if not G_RLF.db.global.xpFeed then
        return
    end

    if unitTarget == "player" then
        local newLevel = UnitLevel(unitTarget)
        local newCurrentXP = UnitXP(unitTarget)
        local delta = 0
        if newLevel > currentLevel then
            delta = (currentMaxXP - currentXP) + newCurrentXP
        else
            delta = newCurrentXP - currentXP
        end
        currentXP = newCurrentXP
        currentLevel = newLevel
        currentMaxXP = UnitXPMax(unitTarget)
        if delta > 0 then
            G_RLF.LootDisplay:ShowXP(delta)
        end
    end
end

function RLF:InitializeOptions()
    if self.optionsFrame == nil then
        self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, addonName)
    end
end

function RLF:SlashCommand(msg, editBox)
    LibStub("AceConfigDialog-3.0"):Open(addonName)
end
