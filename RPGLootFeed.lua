local addonName = G_RLF.addonName
local dbName = G_RLF.dbName
RLF = G_RLF.RLF

local defaults = {
    profile = {},
    global = {
        anchorPoint = "CENTER",
        xOffset = 0,
        yOffset = 0,
        feedWidth = 200,
        maxRows = 15,
        rowHeight = 20,
        rowPadding = 2,
        iconSize = 20
    }
}

function RLF:OnInitialize()
    G_RLF.db = LibStub("AceDB-3.0"):New(dbName, defaults, true)
    LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, G_RLF.options)
    self.initialized = false
    G_RLF.LootDisplay:Initialize()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
    self:RegisterEvent("CHAT_MSG_LOOT")
    self:RegisterChatCommand("rlf", "SlashCommand")
    self:RegisterChatCommand("RLF", "SlashCommand")
    self:RegisterChatCommand("rpglootfeed", "SlashCommand")
    self:RegisterChatCommand("rpgLootFeed", "SlashCommand")
end

function RLF:PLAYER_ENTERING_WORLD(event, isLogin, isReload)
    if self.initialized == false then
        self.initialized = true
        self:InitializeOptions()
    end
end

function RLF:CURRENCY_DISPLAY_UPDATE(eventName, currencyType, quantity, quantityChange, quantityGainSource, quantityLostSource)
    if currencyType == nil or quantityChange == 0 then
        return
    end

    local info = C_CurrencyInfo.GetCurrencyInfo(currencyType)
    if info == nil then
        return
    end

    G_RLF.LootDisplay:ShowLoot(info.currencyID, G_RLF.LootDisplay:GetCurrencyLink(info.currencyID, info.name), info.iconFileID, quantityChange)
end

function RLF:CHAT_MSG_LOOT(eventName, msg)
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

function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then k = '"' .. k .. '"' end
            s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
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
