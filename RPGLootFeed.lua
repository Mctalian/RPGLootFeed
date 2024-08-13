local addonName = G_RLF.addonName
local dbName = G_RLF.dbName
RLF = G_RLF.RLF

function RLF:OnInitialize()
    G_RLF.db = LibStub("AceDB-3.0"):New(dbName, G_RLF.defaults, true)
    LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, G_RLF.options)
    G_RLF.LootDisplay:Initialize()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
    self:RegisterEvent("CHAT_MSG_LOOT")
    self:RegisterEvent("CHAT_MSG_MONEY")
    self:RegisterChatCommand("rlf", "SlashCommand")
    self:RegisterChatCommand("RLF", "SlashCommand")
    self:RegisterChatCommand("rpglootfeed", "SlashCommand")
    self:RegisterChatCommand("rpgLootFeed", "SlashCommand")
end

function RLF:PLAYER_ENTERING_WORLD(event, isLogin, isReload)
    if isLogin and isReload == false then
        self:InitializeOptions()
        self:Print("Welcome! Use /rlf to view options.")
    end
end

function RLF:CURRENCY_DISPLAY_UPDATE(eventName, currencyType, quantity, quantityChange, quantityGainSource,
    quantityLostSource)
    if currencyType == nil or quantityChange == 0 then
        return
    end

    local info = C_CurrencyInfo.GetCurrencyInfo(currencyType)
    if info == nil then
        return
    end

    G_RLF.LootDisplay:ShowLoot(info.currencyID, G_RLF:GetCurrencyLink(info.currencyID, info.name), info.iconFileID,
        quantityChange)
end

function RLF:CHAT_MSG_LOOT(eventName, msg)
    -- This will not work if another addon is overriding formatting globals like LOOT_ITEM, LOOT_ITEM_MULTIPLE, etc.
    local notSelf = msg:match("receives")
    if notSelf ~= null then
        return
    end
    local itemID = msg:match("Hitem:(%d+)")
    if itemID ~= nil then
        local amount = msg:match("rx(%d+)") or 1
        local _, itemLink, _, _, _, _, _, _, _, itemTexture = C_Item.GetItemInfo(itemID)
        G_RLF.LootDisplay:ShowLoot(itemID, itemLink, itemTexture, amount)
    end
end

function RLF:CHAT_MSG_MONEY(eventName, msg)
    local amountInCopper
    -- Initialize default values
    local gold, silver, copper = 0, 0, 0

    -- Patterns to match optional sections
    local goldPattern = "(%d+) Gold"
    local silverPattern = "(%d+) Silver"
    local copperPattern = "(%d+) Copper"

    -- Find and convert matches to numbers if they exist
    gold = tonumber(msg:match(goldPattern)) or gold
    silver = tonumber(msg:match(silverPattern)) or silver
    copper = tonumber(msg:match(copperPattern)) or copper

    amountInCopper = (gold * 100 * 100)
    amountInCopper = amountInCopper + (silver * 100)
    amountInCopper = amountInCopper + copper
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
