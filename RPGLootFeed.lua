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
    self:RegisterChatCommand("rlf", "SlashCommand")
    self:RegisterChatCommand("RLF", "SlashCommand")
    self:RegisterChatCommand("rpglootfeed", "SlashCommand")
    self:RegisterChatCommand("rpgLootFeed", "SlashCommand")
end

local attempts = 0
function RLF:CheckForLootAlertSystem()
    if self:IsHooked(LootAlertSystem, "AddAlert") then
        return
    end
    if LootAlertSystem and LootAlertSystem.AddAlert then
        self:RawHook(LootAlertSystem, "AddAlert", "InterceptAddAlert", true)
    else
        if attempts <= 30 then
            attempts = attempts + 1
            -- Keep checking until it's available
            self:ScheduleTimer("CheckForLootAlertSystem", 1)
        else
            self:Print(G_RLF.L["AddLootAlertUnavailable"])
            self:Print(G_RLF.L["Issues"])
        end
    end
end

function RLF:InterceptAddAlert(frame, ...)
    if G_RLF.db.global.disableBlizzLootToasts then
        return
    end
    -- Call the original AddAlert function if not blocked
    self.hooks[LootAlertSystem].AddAlert(frame, ...)
end


function RLF:PLAYER_ENTERING_WORLD(event, isLogin, isReload)
    self:InitializeOptions()
    self:CheckForLootAlertSystem()
    if isLogin and isReload == false then
        self:Print(G_RLF.L["Welcome"])
    end
end

function RLF:CURRENCY_DISPLAY_UPDATE(eventName, currencyType, quantity, quantityChange, quantityGainSource,
    quantityLostSource)
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
    local msg, _, _, _, _, _, _, _, _, _, _, guid = ...
    local raidLoot = msg:match("HlootHistory:")
    if raidLoot then
        -- Ignore this message as it's a raid loot message
        return
    end
    -- This will not work if another addon is overriding formatting globals like LOOT_ITEM, LOOT_ITEM_MULTIPLE, etc.
    local self = guid == GetPlayerGuid()
    if not self then
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

function RLF:InitializeOptions()
    if self.optionsFrame == nil then
        self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, addonName)
    end
end

function RLF:SlashCommand(msg, editBox)
    LibStub("AceConfigDialog-3.0"):Open(addonName)
end
