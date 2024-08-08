---@class LootDisplay
local LootDisplay = {}

-- Private method declaration
local createDynamicPropertyTable
local updateRowPositions
local rowBackground
local rowIcon
local rowAmountText
local rowFadeOutAnimation
local rowStyles
local getNumberOfRows
local getFrameHeight
local doesRowExist

-- Private variable declaration
local defaults = {
  anchorPoint = "CENTER",
  relativePoint = UIParent,
  xOffset = 0,
  yOffset = 0,
  feedWidth = 200,
  maxRows = 15,
  rowHeight = 20,
  padding = 2,
  iconSize = 20,
  fadeOutDelay = 15,
  rowBackgroundGradientStart = { 0.1, 0.1, 0.1, 0.8 }, -- Default to dark grey with 80% opacity
  rowBackgroundGradientEnd = { 0.1, 0.1, 0.1, 0 }, -- Default to dark grey with 0% opacity
}
local config = nil
local rows = G_RLF.list()
local rowFramePool = {}
local frame = nil
local boundingBox = nil

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

-- Public methods
function LootDisplay:Initialize()
  config = createDynamicPropertyTable(G_RLF.db.global, defaults)

  frame = CreateFrame("Frame", "LootDisplayFrame", UIParent)
  frame:SetSize(config.feedWidth, getFrameHeight())
  frame:SetPoint(config.anchorPoint, UIParent, config.xOffset, config.yOffset)

  frame:SetClipsChildren(true) -- Enable clipping of child elements
  
  boundingBox = frame:CreateTexture(nil, "BACKGROUND")
  boundingBox:SetColorTexture(1, 0, 0, 0.5) -- Red with 50% opacity
  boundingBox:SetAllPoints()
  boundingBox:Hide()
end

function LootDisplay:ToggleBoundingBox()
  if boundingBox:IsShown() then
    boundingBox:Hide()
  else
    boundingBox:Show()
  end
end

function LootDisplay:UpdatePosition()
  frame:ClearAllPoints()
  frame:SetPoint(config.anchor, config.relativePoint, config.xOffset, config.yOffset)
end

function LootDisplay:UpdateRowStyles()
  frame:SetSize(config.feedWidth, getFrameHeight())
end

function LootDisplay:ShowLoot(id, link, icon, amountLooted)
    local key = tostring(id) -- Use ID as a unique key

    -- Check if the item or currency is already displayed
    local row = getRow(key)
    if row then
        -- Update existing entry
        row.amount = row.amount + amountLooted

        row.amountText:SetText(row.link .. " x" .. row.amount)
        row.fadeOutAnimation:Stop()
        row.fadeOutAnimation:Play()
    else
        -- if #rows >= config.maxRows then
        --   -- Skip this, we've already allocated too much
        --   return
        -- end
        if #rowFramePool == 0 then
          -- Create a new row
          G_RLF:Print("Creating a new frame")
          row = CreateFrame("Frame", nil, frame)
        else
          G_RLF:Print("Reusing a frame")
          row = tremove(rowFramePool)
          row:ClearAllPoints()
        end
        rows:push(row)
        row.key = key
        row:Show()
        rowStyles(row, key)

        -- Initialize row content
        row.icon:SetTexture(icon)
        row.amount = amountLooted
        row.link = link
        row.amountText:SetText(link .. " x" .. amountLooted)

        -- Track the row
        G_RLF:Print(getNumberOfRows() .. " rows tracked")
        G_RLF:Print(#rowFramePool .. " rows in pool")

        -- Position the new row at the bottom of the frame
        if getNumberOfRows() == 1 then
          row:SetPoint("BOTTOM", frame, "BOTTOM")
        else
          updateRowPositions()
        end

        row.fadeOutAnimation:Stop()
        row.fadeOutAnimation:Play()
    end
end

function LootDisplay:HideLoot()
    -- Hide all rows
    for row in rows:iterate() do
        row.fadeOutAnimation:Stop()
        row:Hide()
        rows:remove(row)
        tinsert(rowFramePool, row)
    end
end

-- @type LootDisplay
G_RLF.LootDisplay = LootDisplay

-- Private method definition
createDynamicPropertyTable = function (globalTable, defaultsTable)
  local proxy = {}

  setmetatable(proxy, {
      __index = function(_, key)
          -- Check if the key exists in defaults, handle dynamically
          if defaultsTable[key] ~= nil then
              return globalTable[key] or defaultsTable[key]
          else
              return rawget(_, key)
          end
      end,
      __newindex = function(_, key, value)
          -- Update globalTable for dynamic properties
          if defaultsTable[key] ~= nil then
              globalTable[key] = value
          else
              rawset(_, key, value)
          end
      end
  })

  return proxy
end

rowBackground = function(row)
  -- Create row background
  if row.background == nil then
    row.background = row:CreateTexture(nil, "BACKGROUND")
  else
    row.background:ClearAllPoints()
  end
  row.background:SetTexture("Interface/Buttons/WHITE8x8")
  row.background:SetGradient("HORIZONTAL", CreateColor(unpack(config.rowBackgroundGradientStart)), CreateColor(unpack(config.rowBackgroundGradientEnd)) )
  row.background:SetAllPoints()
end

rowIcon = function(row)
  if row.icon == nil then
    row.icon = row:CreateTexture(nil, "ARTWORK")
  else
    row.icon:ClearAllPoints()
  end
  row.icon:SetSize(config.iconSize, config.iconSize)
  row.icon:SetPoint("LEFT", config.iconSize / 4, 0)
end

rowAmountText = function(row)
  if row.amountText == nil then
    row.amountText = row:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
  else
    row.amountText:ClearAllPoints()
  end
  row.amountText:SetPoint("LEFT", row.icon, "RIGHT", config.iconSize / 2, 0)
end

rowFadeOutAnimation = function(row, key, m)
  if row.fadeOutAnimation == nil then
    row.fadeOutAnimation = row:CreateAnimationGroup()
    local fadeOut = row.fadeOutAnimation:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(1)
    fadeOut:SetStartDelay(config.fadeOutDelay)
    fadeOut:SetScript("OnFinished", function()
        row:Hide()
        tinsert(rowFramePool, row)
        rows:remove(row)
        updateRowPositions() -- Recalculate positions
    end)
  end
end

rowStyles = function(row, key)
  row:SetSize(config.feedWidth, config.rowHeight)

  rowBackground(row)
  rowIcon(row)
  rowAmountText(row)
  rowFadeOutAnimation(row, key, self)
end

updateRowPositions = function()
  local index = 0
  for row in rows:iterate() do
    if row:IsShown() then
      rowStyles(row)
      row:ClearAllPoints()
      row:SetPoint("BOTTOM", frame, "BOTTOM", 0, index * (config.rowHeight + config.padding))
      index = index + 1
    end
  end
end

getNumberOfRows = function()
  local n = 0
  for row in rows:iterate() do
    n = n + 1
  end
  return n
end

getFrameHeight = function()
  return config.maxRows * (config.rowHeight + config.padding) - config.padding
end

getRow = function(key)
  for row in rows:iterate() do
    if row.key == key then
      return row
    end
  end
  return nil
end