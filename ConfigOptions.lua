local ConfigOptions = {}

-- Enumerate available frames to anchor to
local function EnumerateFrames()
    local frames = {}
    local framesToCheck = {
        ["UIParent"] = "UIParent",
        ["PlayerFrame"] = "PlayerFrame",
        ["Minimap"] = "Minimap",
        ["MainMenuBarBackpackButton"] = "BagBar"
    }
    for f, s in pairs(framesToCheck) do
        if _G[f] then
            frames[f] = s
        end
    end
    return frames
end

G_RLF.defaults = {
    profile = {},
    global = {
        relativePoint = "UIParent",
        anchorPoint = "BOTTOMLEFT",
        leftAlign = true,
        xOffset = 720,
        yOffset = 375,
        feedWidth = 330,
        maxRows = 10,
        rowHeight = 22,
        padding = 2,
        iconSize = 18,
        fadeOutDelay = 5,
        rowBackgroundGradientStart = {0.1, 0.1, 0.1, 0.8}, -- Default to dark grey with 80% opacity
        rowBackgroundGradientEnd = {0.1, 0.1, 0.1, 0}, -- Default to dark grey with 0% opacity
        disableBlizzLootToasts = false,
        enableAutoLoot = false,
        bossBannerConfig = G_RLF.DisableBossBanner.ENABLED,
    }
}

G_RLF.options = {
    name = addonName,
    handler = ConfigOptions,
    type = "group",
    args = {
        testMode = {
            type = "execute",
            name = G_RLF.L["Toggle Test Mode"],
            -- width = "double",
            func = "ToggleTestMode",
            order = 1
        },
        clearRows = {
            type = "execute",
            name = G_RLF.L["Clear rows"],
            -- width = "double",
            func = "ClearRows",
            order = 2
        },
        boundingBox = {
            type = "execute",
            name = G_RLF.L["Toggle Area"],
            -- width = "double",
            func = "ToggleBoundingBox",
            order = 3
        },
        visual = {
            type = "group",
            name = G_RLF.L["Visual"],
            desc = G_RLF.L["VisualDesc"],
            order = 4,
            args = {
                positioning = {
                    type = "header",
                    name = G_RLF.L["Positioning"],
                    order = 1
                },
                relativeTo = {
                    type = "select",
                    name = G_RLF.L["Anchor Relative To"],
                    desc = G_RLF.L["RelativeToDesc"],
                    get = "GetRelativeTo",
                    set = "SetRelativeTo",
                    values = EnumerateFrames(),
                    order = 1.1
                },
                anchorPoint = {
                    type = "select",
                    name = G_RLF.L["Anchor Point"],
                    desc = G_RLF.L["AnchorPointDesc"],
                    get = "GetRelativePosition",
                    set = "SetRelativePosition",
                    values = {
                        ["TOPLEFT"] = G_RLF.L["Top Left"],
                        ["TOPRIGHT"] = G_RLF.L["Top Right"],
                        ["BOTTOMLEFT"] = G_RLF.L["Bottom Left"],
                        ["BOTTOMRIGHT"] = G_RLF.L["Bottom Right"],
                        ["TOP"] = G_RLF.L["Top"],
                        ["BOTTOM"] = G_RLF.L["Bottom"],
                        ["LEFT"] = G_RLF.L["Left"],
                        ["RIGHT"] = G_RLF.L["Right"],
                        ["CENTER"] = G_RLF.L["Center"]
                    },
                    order = 2
                },
                xOffset = {
                    type = "range",
                    name = G_RLF.L["X Offset"],
                    desc = G_RLF.L["XOffsetDesc"],
                    min = -1500,
                    max = 1500,
                    get = "GetXOffset",
                    set = "SetXOffset",
                    order = 3
                },
                yOffset = {
                    type = "range",
                    name = G_RLF.L["Y Offset"],
                    desc = G_RLF.L["YOffsetDesc"],
                    min = -1500,
                    max = 1500,
                    get = "GetYOffset",
                    set = "SetYOffset",
                    order = 4
                },
                rowFormat = {
                    type = "header",
                    name = G_RLF.L["Row Format"],
                    order = 5
                },
                leftAlign = {
                    type = "toggle",
                    name = G_RLF.L["Left Align"],
                    desc = G_RLF.L["LeftAlignDesc"],
                    get = "GetLeftAlign",
                    set = "SetLeftAlign",
                    order = 6,
                },
                feedWidth = {
                    type = "range",
                    name = G_RLF.L["Feed Width"],
                    desc = G_RLF.L["FeedWidthDesc"],
                    min = 10,
                    max = 1000,
                    get = "GetFeedWidth",
                    set = "SetFeedWidth",
                    order = 7
                },
                maxRows = {
                    type = "range",
                    name = G_RLF.L["Maximum Rows to Display"],
                    desc = G_RLF.L["MaxRowsDesc"],
                    min = 10,
                    max = 1000,
                    step = 1,
                    bigStep = 5,
                    get = "GetMaxRows",
                    set = "SetMaxRows",
                    order = 8
                },
                rowHeight = {
                    type = "range",
                    name = G_RLF.L["Loot Item Height"],
                    desc = G_RLF.L["RowHeightDesc"],
                    min = 5,
                    max = 100,
                    get = "GetRowHeight",
                    set = "SetRowHeight",
                    order = 9
                },
                iconSize = {
                    type = "range",
                    name = G_RLF.L["Loot Item Icon Size"],
                    desc = G_RLF.L["IconSizeDesc"],
                    min = 5,
                    max = 100,
                    get = "GetIconSize",
                    set = "SetIconSize",
                    order = 10
                },
                rowPadding = {
                    type = "range",
                    name = G_RLF.L["Loot Item Padding"],
                    desc = G_RLF.L["RowPaddingDesc"],
                    min = 0,
                    max = 10,
                    get = "GetRowPadding",
                    set = "SetRowPadding",
                    order = 11
                },
                timing = {
                    type = "header",
                    name = G_RLF.L["Timing"],
                    order = 12
                },
                fadeOutDelay = {
                    type = "range",
                    name = G_RLF.L["Fade Out Delay"],
                    desc = G_RLF.L["FadeOutDelayDesc"],
                    min = 1,
                    max = 30,
                    get = "GetFadeOutDelay",
                    set = "SetFadeOutDelay",
                    order = 13
                },
                styles = {
                    type = "header",
                    name = G_RLF.L["Row Styling"],
                    order = 14
                },
                gradientStart = {
                    type = "color",
                    name = G_RLF.L["Background Gradient Start"],
                    desc = G_RLF.L["GradientStartDesc"],
                    hasAlpha = true,
                    get = "GetGradientStartColor",
                    set = "SetGradientStartColor",
                    order = 15
                },
                gradientEnd = {
                    type = "color",
                    name = G_RLF.L["Background Gradient End"],
                    desc = G_RLF.L["GradientEndDesc"],
                    hasAlpha = true,
                    get = "GetGradientEndColor",
                    set = "SetGradientEndColor",
                    order = 16
                }
            }
        },
        blizz = {
            type = "group",
            name = G_RLF.L["Blizzard UI"],
            desc = G_RLF.L["BlizzUIDesc"],
            order = 5,
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
            }
        }
    }
}

function ConfigOptions:SetRelativeTo(info, value)
    G_RLF.db.global.relativePoint = value
    G_RLF.LootDisplay:UpdatePosition()
end

function ConfigOptions:GetRelativeTo(info)
    return G_RLF.db.global.relativePoint
end

function ConfigOptions:SetRelativePosition(info, value)
    G_RLF.db.global.anchorPoint = value
    G_RLF.LootDisplay:UpdatePosition()
end

function ConfigOptions:GetRelativePosition(info)
    return G_RLF.db.global.anchorPoint
end

function ConfigOptions:SetXOffset(info, value)
    G_RLF.db.global.xOffset = value
    G_RLF.LootDisplay:UpdatePosition()
end

function ConfigOptions:GetXOffset(info)
    return G_RLF.db.global.xOffset
end

function ConfigOptions:SetYOffset(info, value)
    G_RLF.db.global.yOffset = value
    G_RLF.LootDisplay:UpdatePosition()
end

function ConfigOptions:GetYOffset(info)
    return G_RLF.db.global.yOffset
end

function ConfigOptions:SetFeedWidth(info, value)
    G_RLF.db.global.feedWidth = value
    G_RLF.LootDisplay:UpdateRowStyles()
end

function ConfigOptions:GetFeedWidth(info)
    return G_RLF.db.global.feedWidth
end

function ConfigOptions:SetMaxRows(info, value)
    G_RLF.db.global.maxRows = value
    G_RLF.LootDisplay:UpdateRowStyles()
end

function ConfigOptions:GetMaxRows(info)
    return G_RLF.db.global.maxRows
end

function ConfigOptions:SetRowHeight(info, value)
    G_RLF.db.global.rowHeight = value
    G_RLF.LootDisplay:UpdateRowStyles()
end

function ConfigOptions:GetRowHeight(info, value)
    return G_RLF.db.global.rowHeight
end

function ConfigOptions:SetIconSize(info, value)
    G_RLF.db.global.iconSize = value
    G_RLF.LootDisplay:UpdateRowStyles()
end

function ConfigOptions:GetIconSize(info, value)
    return G_RLF.db.global.iconSize
end

function ConfigOptions:SetRowPadding(info, value)
    G_RLF.db.global.padding = value
    G_RLF.LootDisplay:UpdateRowStyles()
end

function ConfigOptions:GetRowPadding(info, value)
    return G_RLF.db.global.padding
end

function ConfigOptions:GetGradientStartColor(info, value)
    local r, g, b, a = unpack(G_RLF.db.global.rowBackgroundGradientStart)
    return r, g, b, a
end

function ConfigOptions:SetGradientStartColor(info, r, g, b, a)
    G_RLF.db.global.rowBackgroundGradientStart = { r, g, b, a }
end

function ConfigOptions:GetGradientEndColor(info, value)
    local r, g, b, a = unpack(G_RLF.db.global.rowBackgroundGradientEnd)
    return r, g, b, a
end

function ConfigOptions:SetGradientEndColor(info, r, g, b, a)
    G_RLF.db.global.rowBackgroundGradientEnd = { r, g, b, a }
end

function ConfigOptions:SetFadeOutDelay(info, value)
    G_RLF.db.global.fadeOutDelay = value
    G_RLF.LootDisplay:UpdateFadeDelay()
end

function ConfigOptions:GetFadeOutDelay(info, value)
    return G_RLF.db.global.fadeOutDelay
end

function ConfigOptions:SetDisableLootToast(info, value)
    G_RLF.db.global.disableBlizzLootToasts = value
end

function ConfigOptions:GetDisableLootToast(info, value)
    return G_RLF.db.global.disableBlizzLootToasts
end

function ConfigOptions:GetEnableAutoLoot(info, value)
    return G_RLF.db.global.enableAutoLoot
end

function ConfigOptions:SetEnableAutoLoot(info, value)
    C_CVar.SetCVar("autoLootDefault", value and "1" or "0");
    G_RLF.db.global.enableAutoLoot = value
end

function ConfigOptions:SetBossBannerConfig(info, value)
    G_RLF.db.global.bossBannerConfig = value
    G_RLF:Print(G_RLF.db.global.bossBannerConfig)
end

function ConfigOptions:GetBossBannerConfig(info, value)
    return G_RLF.db.global.bossBannerConfig
end

function ConfigOptions:SetLeftAlign(info, value)
    G_RLF.db.global.leftAlign = value
    G_RLF.LootDisplay:UpdateRowStyles()
end

function ConfigOptions:GetLeftAlign(info, value)
    return G_RLF.db.global.leftAlign
end

function ConfigOptions:ToggleBoundingBox()
    G_RLF.LootDisplay:ToggleBoundingBox()
end

function ConfigOptions:ToggleTestMode()
    G_RLF.TestMode:ToggleTestMode()
end

function ConfigOptions:ClearRows()
    G_RLF.LootDisplay:HideLoot()
end

