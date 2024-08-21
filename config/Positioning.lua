local Positioning = {}

G_RLF.defaults.global.relativePoint = "UIParent"
G_RLF.defaults.global.anchorPoint = "BOTTOMLEFT"
G_RLF.defaults.global.xOffset = 720
G_RLF.defaults.global.yOffset = 375

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

G_RLF.options.args.positioning = {
  type = "group",
  handler = Positioning,
  name = G_RLF.L["Positioning"],
  desc = G_RLF.L["PositioningDesc"],
  order = 5,
  args = {
      relativeTo = {
          type = "select",
          name = G_RLF.L["Anchor Relative To"],
          desc = G_RLF.L["RelativeToDesc"],
          get = "GetRelativeTo",
          set = "SetRelativeTo",
          values = EnumerateFrames(),
          order = 1
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
  },
}

function Positioning:SetRelativeTo(info, value)
  G_RLF.db.global.relativePoint = value
  G_RLF.LootDisplay:UpdatePosition()
end

function Positioning:GetRelativeTo(info)
  return G_RLF.db.global.relativePoint
end

function Positioning:SetRelativePosition(info, value)
  G_RLF.db.global.anchorPoint = value
  G_RLF.LootDisplay:UpdatePosition()
end

function Positioning:GetRelativePosition(info)
  return G_RLF.db.global.anchorPoint
end

function Positioning:SetXOffset(info, value)
  G_RLF.db.global.xOffset = value
  G_RLF.LootDisplay:UpdatePosition()
end

function Positioning:GetXOffset(info)
  return G_RLF.db.global.xOffset
end

function Positioning:SetYOffset(info, value)
  G_RLF.db.global.yOffset = value
  G_RLF.LootDisplay:UpdatePosition()
end

function Positioning:GetYOffset(info)
  return G_RLF.db.global.yOffset
end