-- LootDisplay.lua
LootDisplay = {}

local defaults = {
  width = 200,
  height = 500,
  rowHeight = 20,
  rowPadding = 2,
  iconSize = 20,
  fadeOutDelay = 15,
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
  fadeOutDelay
)
  self.feedWidth = feedWidth or defaults.width
  self.feedHeight = feedHeight or defaults.height
  self.rows = {} -- Table to track displayed loot rows
  self.rowHeight = rowHeight or defaults.rowHeight -- Height of each row
  self.padding = rowPadding or defaults.rowPadding -- Space between rows
  self.iconSize = iconSize or defaults.iconSize
  self.fadeOutDelay = fadeOutDelay or defaults.fadeOutDelay

  self.frame = CreateFrame("Frame", "LootDisplayFrame", UIParent)
  self.frame:SetSize(self.feedWidth, self.feedHeight)
  self.frame:SetPoint(anchorPoint, UIParent, xOffset, yOffset)
  
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

function LootDisplay:UpdateRowSize(rowHeight, padding, iconSize)
  self.rowHeight = rowHeight or self.rowHeight
  self.padding = padding or self.padding
  self.iconSize = iconSize or self.iconSize
end

function LootDisplay:ShowLoot(id, link, icon, amountLooted)
    local key = tostring(id) -- Use ID as a unique key

    local function createNewRow()
      -- Create a new row
      local row = CreateFrame("Frame", nil, self.frame)
      row:SetSize(self.feedWidth, self.rowHeight)
      
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
        self.rows[key].amountText:SetText(link .. " x" .. self.rows[key].amount)
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
        row:Hide()
        self.rows[key] = nil
    end
end

function LootDisplay:GetCurrencyLink(currencyInfo)
    return string.format("|cffffffff|Hcurrency:%d|h[%s]|h|r", currencyInfo.currencyID, currencyInfo.name)
end

local testItemNumber = 0
local testItems = {
  { id = 2589 },
  { id = 2592 },
  { id = 1515 },
  { id = 730 },
  { id = 19019 },
  { id = 128507 },
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
        local _, itemLink, _, _, _, _, _, _, _, itemTexture = C_Item.GetItemInfo(item.id)
        if itemLink == nil then
          print(item.id .. " does not have a link...")
        else
          testItems[k].link = itemLink
        end
        if itemTexture == nil then
          print(item.id .. " does not have an icon...")
        else
          testItems[k].icon = itemTexture
        end
        testItemNumber = testItemNumber + 1
      end
      self.testTimer = C_Timer.NewTicker(5, function() self:GenerateRandomLoot() end)
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
