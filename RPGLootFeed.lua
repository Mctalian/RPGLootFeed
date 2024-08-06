local addonName = "RPGLootFeed"
local dbName = addonName .. "DB"
RLF = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0")

local options = {
    name = addonName,
    handler = RLF,
    type = "group",
    args = {
        visual = {
            type = "group",
            name = "Visual",
            desc = "Position and size the loot feed and its elements",
            args = {
                positioning = {
                    type = "header",
                    name = "Positioning",
                    order = 1,
                },
                anchorPoint = {
                    type = "select",
                    name = "Relative Screen Position",
                    desc = "Where on the screen to base the loot feed positioning",
                    get = "GetRelativePosition",
                    set = "SetRelativePosition",
                    values = {},
                    order = 2,
                },
                xOffset = {
                    type = "range",
                    name = "X Offset",
                    desc = "Adjust the loot feed left (negative) or right (positive)",
                    min = -500,
                    max = 500,
                    get = "GetXOffset",
                    set = "SetXOffset",
                    order = 3,
                },
                yOffset = {
                    type = "range",
                    name = "Y Offset",
                    desc = "Adjust the loot feed up (negative) or down (positive)",
                    min = -500,
                    max = 500,
                    get = "GetYOffset",
                    set = "SetYOffset",
                    order = 4,
                },
                sizing = {
                    type = "header",
                    name = "Sizing",
                    order = 5,
                },
                feedWidth = {
                    type = "range",
                    name = "Feed Width",
                    desc = "The width of the loot feed parent frame",
                    min = 10,
                    max = 1000,
                    get = "GetFeedWidth",
                    set = "SetFeedWidth",
                    order = 6,
                },
                feedHeight = {
                    type = "range",
                    name = "Feed Height",
                    desc = "The height of the loot feed parent frame",
                    min = 10,
                    max = 1000,
                    get = "GetFeedHeight",
                    set = "SetFeedHeight",
                    order = 6,
                },
                rowHeight = {
                    type = "range",
                    name = "Loot Item Height",
                    desc = "The height of each item \"row\" in the loot feed",
                    min = 5,
                    max = 100,
                    get = "GetRowHeight",
                    set = "SetRowHeight",
                    order = 7,
                },
                iconSize = {
                    type = "range",
                    name = "Loot Item Icon Size",
                    desc = "The size of the icons in each item \"row\" in the loot feed",
                    min = 5,
                    max = 100,
                    get = "GetIconSize",
                    set = "SetIconSize",
                    order = 8,
                },
                rowPadding = {
                    type = "range",
                    name = "Loot Item Padding",
                    desc = "The amount of space between item \"rows\" in the loot feed",
                    min = 0,
                    max = 10,
                    get = "GetRowPadding",
                    set = "SetRowPadding",
                    order = 9,
                },
            }
        },
        boundingBox = {
            type = "execute",
            name = "Show/Hide Bounding Box",
            width = "double",
            func = "ToggleBoundingBox",
            order = 1,
        },
        testMode = {
            type = "execute",
            name = "Toggle Test Mode",
            width = "double",
            func = "ToggleTestMode",
            order = 2,
        },
    }
}

local defaults = {
    profile = {},
    global = {
        anchorPoint = "CENTER",
        xOffset = 0,
        yOffset = 0,
        feedWidth = 200,
        feedHeight = 500,
        rowHeight = 20,
        rowPadding = 2,
        iconSize = 20
    }
}

function RLF:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New(dbName, defaults, true)
    LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, options)
    self.initialized = false
    LootDisplay:Initialize(
        self.db.global.anchorPoint,
        self.db.global.xOffset,
        self.db.global.yOffset,
        self.db.global.feedWidth,
        self.db.global.feedHeight,
        self.db.global.rowHeight,
        self.db.global.rowPadding,
        self.db.global.iconSize
    )
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
    if currencyType == nil then
        return
    end
    local info = C_CurrencyInfo.GetCurrencyInfo(currencyType)
    -- local info = C_Item.GetItemInfo(iId)
    if info == nil then
        return
    end
    local currencyInfo = LootInfo:new(info)
    if currencyInfo == nil then
        return
    end
    LootDisplay:ShowLoot(currencyInfo.currencyID, LootDisplay:GetCurrencyLink(currencyInfo), currencyInfo.iconFileID, quantityChange)
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
        LootDisplay:ShowLoot(itemID, itemLink, itemTexture, amount)
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
    options.args.visual.args.anchorPoint.values["TOPLEFT"] = "Top Left"
    options.args.visual.args.anchorPoint.values["TOPRIGHT"] = "Top Right"
    options.args.visual.args.anchorPoint.values["BOTTOMLEFT"] = "Bottom Left"
    options.args.visual.args.anchorPoint.values["BOTTOMRIGHT"] = "Bottom Right"
    options.args.visual.args.anchorPoint.values["TOP"] = "Top"
    options.args.visual.args.anchorPoint.values["BOTTOM"] = "Bottom"
    options.args.visual.args.anchorPoint.values["LEFT"] = "Left"
    options.args.visual.args.anchorPoint.values["RIGHT"] = "Right"
    options.args.visual.args.anchorPoint.values["CENTER"] = "Center"

    if self.optionsFrame == nil then
        self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, addonName)
    end
end

function RLF:SetRelativePosition(info, value)
    self.db.global.anchorPoint = value
    self:UpdateLootFeedPosition()
end

function RLF:GetRelativePosition(info)
    return self.db.global.anchorPoint
end

function RLF:SetXOffset(info, value)
    self.db.global.xOffset = value
    self:UpdateLootFeedPosition()
end

function RLF:GetXOffset(info)
    return self.db.global.xOffset
end

function RLF:SetYOffset(info, value)
    self.db.global.yOffset = value
    self:UpdateLootFeedPosition()
end

function RLF:GetYOffset(info)
    return self.db.global.yOffset
end

function RLF:SetFeedWidth(info, value)
    self.db.global.feedWidth = value
    self:UpdateLootFeedSize()
end

function RLF:GetFeedWidth(info)
    return self.db.global.feedWidth
end

function RLF:SetFeedHeight(info, value)
    self.db.global.feedHeight = value
    self:UpdateLootFeedSize()
end

function RLF:GetFeedHeight(info)
    return self.db.global.feedHeight
end

function RLF:SetRowHeight(info, value)
    self.db.global.rowHeight = value
    self:UpdateRowSize()
end

function RLF:GetRowHeight(info, value)
    return self.db.global.rowHeight
end

function RLF:SetIconSize(info, value)
    self.db.global.iconSize = value
    self:UpdateRowSize()
end

function RLF:GetIconSize(info, value)
    return self.db.global.iconSize
end

function RLF:SetRowPadding(info, value)
    self.db.global.rowPadding = value
    self:UpdateRowSize()
end

function RLF:GetRowPadding(info, value)
    return self.db.global.rowPadding
end

function RLF:ToggleBoundingBox()
    LootDisplay:ToggleBoundingBox()
end

function RLF:ToggleTestMode()
    LootDisplay:ToggleTestMode()
end

function RLF:UpdateLootFeedPosition()
    LootDisplay:UpdatePosition(self.db.global.anchorPoint, self.db.global.xOffset, self.db.global.yOffset)
end

function RLF:UpdateLootFeedSize()
    LootDisplay:UpdateSize(self.db.global.feedWidth, self.db.global.feedHeight)
end

function RLF:UpdateRowSize()
    LootDisplay:UpdateRowSize(self.db.global.rowHeight, self.db.global.rowPadding, self.db.global.iconSize)
end

function RLF:SlashCommand(msg, editBox)
    LibStub("AceConfigDialog-3.0"):Open(addonName)
end
