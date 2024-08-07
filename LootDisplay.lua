-- LootDisplay.lua
LootDisplay = {}

local defaults = {
  width = 200,
  height = 500,
  rowHeight = 20,
  rowPadding = 2,
  iconSize = 20,
  fadeOutDelay = 15,
  rowBackgroundGradientStart = { 0.1, 0.1, 0.1, 0.8 }, -- Default to dark grey with 80% opacity
  rowBackgroundGradientEnd = { 0.1, 0.1, 0.1, 0 }, -- Default to dark grey with 0% opacity
}

function LootDisplay:Initialize(
  anchorPoint,
  xOffset,
  yOffset,
  feedWidth,
  feedHeight,
  rowHeight,
  rowPadding,
  iconSize,
  fadeOutDelay,
  rowBackgroundGradientStart,
  rowBackgroundGradientEnd
)
  self.feedWidth = feedWidth or defaults.width
  self.feedHeight = feedHeight or defaults.height
  self.rows = {} -- Table to track displayed loot rows
  self.rowHeight = rowHeight or defaults.rowHeight -- Height of each row
  self.padding = rowPadding or defaults.rowPadding -- Space between rows
  self.iconSize = iconSize or defaults.iconSize
  self.fadeOutDelay = fadeOutDelay or defaults.fadeOutDelay
  self.rowBackgroundGradientStart = rowBackgroundGradientStart or defaults.rowBackgroundGradientStart
  self.rowBackgroundGradientEnd = rowBackgroundGradientEnd or defaults.rowBackgroundGradientEnd

  self.frame = CreateFrame("Frame", "LootDisplayFrame", UIParent)
  self.frame:SetSize(self.feedWidth, self.feedHeight)
  self.frame:SetPoint(anchorPoint, UIParent, xOffset, yOffset)

  self.frame:SetClipsChildren(true) -- Enable clipping of child elements
  
  self.boundingBox = self.frame:CreateTexture(nil, "BACKGROUND")
  self.boundingBox:SetColorTexture(1, 0, 0, 0.5) -- Red with 50% opacity
  self.boundingBox:SetAllPoints()
  self.boundingBox:Hide()

  self.testMode = false
  self.testTimer = nil
end

function LootDisplay:ToggleBoundingBox()
  if self.boundingBox:IsShown() then
    self.boundingBox:Hide()
  else
    self.boundingBox:Show()
  end
end

function LootDisplay:SetPosition(anchor, relativePoint, xOffset, yOffset)
  -- Clear existing points
  self.frame:ClearAllPoints()
  -- Set new point
  self.frame:SetPoint(anchor, relativePoint, xOffset, yOffset)
end

-- Example configuration function to update frame position
function LootDisplay:UpdatePosition(anchor, xOffset, yOffset)
  -- Example config options, replace with your actual config storage
  local relativePoint = UIParent   -- Example relative point

  -- Call the function to set the position
  self:SetPosition(anchor or "CENTER", relativePoint, xOffset or 0, yOffset or 0)
end

function LootDisplay:UpdateSize(feedWidth, feedHeight)
  self.feedWidth = feedWidth or self.feedWidth or defaults.width
  self.feedHeight = feedHeight or self.feedHeight or defaults.height
  self.frame:SetSize(self.feedWidth, self.feedHeight)
end

function LootDisplay:UpdateRowStyles(rowHeight, padding, iconSize, rowBackgroundGradientStart, rowBackgroundGradientEnd)
  self.rowHeight = rowHeight or self.rowHeight
  self.padding = padding or self.padding
  self.iconSize = iconSize or self.iconSize
  self.rowBackgroundGradientStart = rowBackgroundGradientStart or self.rowBackgroundGradientStart
  self.rowBackgroundGradientEnd = rowBackgroundGradientEnd or self.rowBackgroundGradientEnd
end

function LootDisplay:ShowLoot(id, link, icon, amountLooted)
    local key = tostring(id) -- Use ID as a unique key

    local function createNewRow()
      -- Create a new row
      local row = CreateFrame("Frame", nil, self.frame)
      row:SetSize(self.feedWidth, self.rowHeight)

      -- Create row background
      row.background = row:CreateTexture(nil, "BACKGROUND")
      row.background:SetTexture("Interface/Buttons/WHITE8x8")
      row.background:SetGradient("HORIZONTAL", CreateColor(unpack(self.rowBackgroundGradientStart)), CreateColor(unpack(self.rowBackgroundGradientEnd)) )
      row.background:SetAllPoints()
      
      row.icon = row:CreateTexture(nil, "ARTWORK")
      row.icon:SetSize(self.iconSize, self.iconSize)
      row.icon:SetPoint("LEFT", self.iconSize / 4, 0)

      row.amountText = row:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
      row.amountText:SetPoint("LEFT", row.icon, "RIGHT", self.iconSize / 2, 0)

      row.fadeOutAnimation = row:CreateAnimationGroup()
      local fadeOut = row.fadeOutAnimation:CreateAnimation("Alpha")
      fadeOut:SetFromAlpha(1)
      fadeOut:SetToAlpha(0)
      fadeOut:SetDuration(1)
      fadeOut:SetStartDelay(self.fadeOutDelay)
      fadeOut:SetScript("OnFinished", function()
          row:Hide()
          self.rows[key] = nil
          self:UpdateRowPositions() -- Recalculate positions
      end)

      -- Initialize row content
      row.icon:SetTexture(icon)
      row.amount = amountLooted
      row.link = link
      row.amountText:SetText(link .. " x" .. amountLooted)

      -- Track the row
      self.rows[key] = row

      -- Position the new row at the bottom of the frame
      local rowIndex = self:GetNumberOfRows() + 1
      if rowIndex == 1 then
        row:SetPoint("BOTTOM", self.frame, "BOTTOM")
      else
        LootDisplay:UpdateRowPositions()
      end

      row:Show()
      row.fadeOutAnimation:Stop()
      row.fadeOutAnimation:Play()
    end

    -- Check if the item or currency is already displayed
    if self.rows[key] then
        -- Update existing entry
        self.rows[key].amount = self.rows[key].amount + amountLooted

        self.rows[key].amountText:SetText(self.rows[key].link .. " x" .. self.rows[key].amount)
        self.rows[key].fadeOutAnimation:Stop()
        self.rows[key].fadeOutAnimation:Play()
    else
        createNewRow()
    end
end

function LootDisplay:GetNumberOfRows()
  local rows = 0
  for key, row in pairs(self.rows) do
    rows = rows + 1
  end
  return rows
end

function LootDisplay:UpdateRowPositions()
    local index = 0
    for key, row in pairs(self.rows) do
        row:SetPoint("BOTTOM", self.frame, "BOTTOM", 0, index * (self.rowHeight + self.padding))
        index = index + 1
    end
end

function LootDisplay:HideLoot()
    -- Hide all rows
    for key, row in pairs(self.rows) do
        self.rows[key].fadeOutAnimation:Stop()
        self.rows[key]:Hide()
        self.rows[key] = nil
    end
end

function LootDisplay:GetCurrencyLink(currencyInfo)
    return string.format("|cffffffff|Hcurrency:%d|h[%s]|h|r", currencyInfo.currencyID, currencyInfo.name)
end

local testItemNumber = 0
local testItems = {
  { 
    id = 2589, 
    link = "|cffffffff|Hitem:2589::::::::1:::::::|h[Linen Cloth]|h|r", 
    icon = 132889 
  },
  { 
    id = 2592, 
    link = "|cffffffff|Hitem:2592::::::::1:::::::|h[Wool Cloth]|h|r", 
    icon = 132911 
  },
  { 
    id = 1515, 
    link = "|cff9d9d9d|Hitem:1515::::::::1:::::::|h[Rough Wooden Staff]|h|r", 
    icon = 135146
  },
  { 
    id = 730, 
    link = "|cff9d9d9d|Hitem:730::::::::1:::::::|h[Murloc Eye]|h|r", 
    icon = 133884 
  },
  { 
    id = 19019, 
    link = "|cffff8000|Hitem:19019::::::::1:::::::|h[Thunderfury, Blessed Blade of the Windseeker]|h|r", 
    icon = 135349
  },
  { 
    id = 128507, 
    link = "|cff0070dd|Hitem:128507::::::::1:::::::|h[Inflatable Thunderfury, Blessed Blade of the Windseeker]|h|r", 
    icon = 135349
  },
}

local testCurrencies = {
  { currencyID = 2245, name = "Flightstone", iconFileID = 4638586 }, -- Dragonflight
  { currencyID = 1191, name = "Valor", iconFileID = 463447 },
  { currencyID = 1828, name = "Soul Ash", iconFileID = 3743738 }, -- Shadowlands
  { currencyID = 1792, name = "Honor", iconFileID = 255347 },
  { currencyID = 1755, name = "Argus Waystone", iconFileID = 399041 }, -- Legion
  { currencyID = 1580, name = "Seal of Wartorn Fate", iconFileID = 1416740 }, -- Battle for Azeroth
  { currencyID = 1273, name = "Seal of Broken Fate", iconFileID = 1604168 }, -- Legion
  { currencyID = 1166, name = "Timewarped Badge", iconFileID = 463446 },
  { currencyID = 515, name = "Darkmoon Prize Ticket", iconFileID = 134481 },
  { currencyID = 241, name = "Champion's Seal", iconFileID = 236689 } -- Wrath of the Lich King
}


function LootDisplay:ToggleTestMode()
  if self.testMode then
      -- Stop test mode
      self.testMode = false
      if self.testTimer then
          self.testTimer:Cancel()
          self.testTimer = nil
      end
      print("Test Mode Disabled")
  else
      -- Start test mode
      self.testMode = true
      print("Test Mode Enabled")
      for k, item in pairs(testItems) do
        testItemNumber = testItemNumber + 1
      end
      self.testTimer = C_Timer.NewTicker(1.5, function() self:GenerateRandomLoot() end)
  end
end

function LootDisplay:GenerateRandomLoot()
  -- Randomly decide whether to generate an item or currency
  if math.random() < 0.8 then
      -- Generate random item
      local item = testItems[math.random(testItemNumber)]
      local amountLooted = math.random(1, 5)
      self:ShowLoot(item.id, item.link, item.icon, amountLooted)
  else
      -- Generate random currency
      local currency = testCurrencies[math.random(#testCurrencies)]
      local amountLooted = math.random(1, 500)
      local currencyLink = self:GetCurrencyLink(currency)
      self:ShowLoot(currency.currencyID, currencyLink, currency.iconFileID, amountLooted)
  end
end
