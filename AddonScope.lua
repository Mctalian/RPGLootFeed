-- Define the global scope early so that the whole addon can use it
G_RLF = {}
local addonName = "RPGLootFeed"
local dbName = addonName .. "DB"
G_RLF.RLF = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0")
G_RLF.addonName = addonName
G_RLF.dbName = dbName

function G_RLF:Print(...)
    G_RLF.RLF:Print(...)
end

function G_RLF:GetCurrencyLink(currencyID, name)
    return string.format("|cffffffff|Hcurrency:%d|h[%s]|h|r", currencyID, name)
end
