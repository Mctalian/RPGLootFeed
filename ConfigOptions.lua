local ConfigOptions = {}

G_RLF.defaults = {
    profile = {},
    global = {
        anchorPoint = "CENTER",
        xOffset = 0,
        yOffset = 0,
        feedWidth = 200,
        maxRows = 15,
        rowHeight = 20,
        padding = 2,
        iconSize = 20
    }
}

G_RLF.options = {
  name = addonName,
  handler = ConfigOptions,
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
                  name = "Anchor Point",
                  desc = "Where on the screen to base the loot feed positioning (also impacts sizing direction)",
                  get = "GetRelativePosition",
                  set = "SetRelativePosition",
                  values = {
                    ["TOPLEFT"] = "Top Left",
                    ["TOPRIGHT"] = "Top Right",
                    ["BOTTOMLEFT"] = "Bottom Left",
                    ["BOTTOMRIGHT"] = "Bottom Right",
                    ["TOP"] = "Top",
                    ["BOTTOM"] = "Bottom",
                    ["LEFT"] = "Left",
                    ["RIGHT"] = "Right",
                    ["CENTER"] = "Center",
                },
                  order = 2,
              },
              xOffset = {
                  type = "range",
                  name = "X Offset",
                  desc = "Adjust the loot feed left (negative) or right (positive)",
                  min = -1500,
                  max = 1500,
                  get = "GetXOffset",
                  set = "SetXOffset",
                  order = 3,
              },
              yOffset = {
                  type = "range",
                  name = "Y Offset",
                  desc = "Adjust the loot feed down (negative) or up (positive)",
                  min = -1500,
                  max = 1500,
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
              maxRows = {
                  type = "range",
                  name = "Maximum Rows to Display",
                  desc = "The maximum number of loot items to display in the feed",
                  min = 10,
                  max = 1000,
                  step = 1,
                  bigStep = 5,
                  get = "GetMaxRows",
                  set = "SetMaxRows",
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
      testMode = {
          type = "execute",
          name = "Toggle Test Mode",
          -- width = "double",
          func = "ToggleTestMode",
          order = 1,
      },
      clearRows = {
          type = "execute",
          name = "Clear rows",
          -- width = "double",
          func = "ClearRows",
          order = 2,
      },
      boundingBox = {
          type = "execute",
          name = "Toggle Area",
          -- width = "double",
          func = "ToggleBoundingBox",
          order = 3,
      },
  }
}


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

function ConfigOptions:ToggleBoundingBox()
    G_RLF.LootDisplay:ToggleBoundingBox()
end

function ConfigOptions:ToggleTestMode()
    G_RLF.TestMode:ToggleTestMode()
end

function ConfigOptions:ClearRows()
    G_RLF.LootDisplay:HideLoot()
end
