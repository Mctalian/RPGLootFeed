local addonName = "RPGLootFeed"
local dbName = addonName .. "DB"
RLF = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0")

local options = {
    name = addonName,
    handler = RLF,
    type = "group",
    args = {
        desc = {
            type = "description",
            name = "TODO: Make an options panel",
            order = 0
        },
        -- howToHeader = {
        --     type = "header",
        --     name = "How to Use",
        --     order = 1
        -- },
        -- howToDesc = {
        --     type = "description",
        --     name = "0. Have multiple Edit Mode presets, one for each device (i.e. Steam Deck, Laptop, PC, etc.)\n1. Install this addon on all of the devices you play on.\n2. Set the \"Preset to Load\" below to the layout you want for each device.\n\nNow when you play on your SteamDeck in the morning and your PC in the evening, you don't need to manually change the Edit Mode presets!",
        --     order = 2
        -- },
        -- preset = {
        --     type = "select",
        --     name = "Preset to Load",
        --     desc = "The Edit Mode preset to load when logging in on this device.",
        --     get = "GetPreset",
        --     set = "SetPreset",
        --     order = -1
        -- }
    }
}

local defaults = {
    profile = {},
    global = {}
}

local layouts = nil

function RLF:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New(dbName, defaults, true)
    LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, options)
    self.initialized = false
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("LOOT_ITEM_SELF")
    self:RegisterChatCommand("rlf", "SlashCommand")
    self:RegisterChatCommand("rpglf", "SlashCommand")
    self:RegisterChatCommand("lootfeed", "SlashCommand")
    self:RegisterChatCommand("lootFeed", "SlashCommand")
    self:RegisterChatCommand("rpglootfeed", "SlashCommand")
    self:RegisterChatCommand("rpgLootFeed", "SlashCommand")
end

function RLF:PLAYER_ENTERING_WORLD(eventName, isReload)
    self:Print("isReload? " .. isReload)
    if self.initialized == false then
        self.initialized = true
        self:InitializeOptions()
    end
end

function RLF:LOOT_ITEM_SELF(...)
    self:Print(...)
end

function RLF:InitializeOptions()
    -- options.args.preset.values = {}
    -- for i, l in ipairs(layouts) do
    --     options.args.preset.values[i] = l.layoutName
    -- end
    if self.optionsFrame == nil then
        self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, addonName)
    end
end

-- function RLF:SetPreset(info, value)
--     self.db.global.presetIndexOnLogin = value
-- end

-- function RLF:GetPreset(info)
--     return self.db.global.presetIndexOnLogin
-- end

function RLF:SlashCommand(msg, editBox)
    LibStub("AceConfigDialog-3.0"):Open(addonName)
end
