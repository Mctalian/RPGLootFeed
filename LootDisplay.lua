---@class LootDisplay
local LootDisplay = {}

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

local function createDynamicPropertyTable(globalTable, defaultsTable)
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

local config = nil


function LootDisplay:Initialize()
  config = createDynamicPropertyTable(G_RLF.db.global, defaults)
  self.rows = {} -- Table to track displayed loot rows

  self.frame = CreateFrame("Frame", "LootDisplayFrame", UIParent)
  self.frame:SetSize(config.feedWidth, self:GetFrameHeight())
  self.frame:SetPoint(config.anchorPoint, UIParent, config.xOffset, config.yOffset)

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

function LootDisplay:UpdatePosition()
  self.frame:ClearAllPoints()
  self.frame:SetPoint(config.anchor, config.relativePoint, config.xOffset, config.yOffset)
end

function LootDisplay:UpdateRowStyles()
  self.frame:SetSize(config.feedWidth, self:GetFrameHeight())
end

function LootDisplay:GetFrameHeight()
  return config.maxRows * (config.rowHeight + config.padding) - config.padding
end

function LootDisplay:ShowLoot(id, link, icon, amountLooted)
    local key = tostring(id) -- Use ID as a unique key

    local function createNewRow()
      -- Create a new row
      local row = CreateFrame("Frame", nil, self.frame)
      row:SetSize(config.feedWidth, config.rowHeight)

      -- Create row background
      row.background = row:CreateTexture(nil, "BACKGROUND")
      row.background:SetTexture("Interface/Buttons/WHITE8x8")
      row.background:SetGradient("HORIZONTAL", CreateColor(unpack(config.rowBackgroundGradientStart)), CreateColor(unpack(config.rowBackgroundGradientEnd)) )
      row.background:SetAllPoints()
      
      row.icon = row:CreateTexture(nil, "ARTWORK")
      row.icon:SetSize(config.iconSize, config.iconSize)
      row.icon:SetPoint("LEFT", config.iconSize / 4, 0)

      row.amountText = row:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
      row.amountText:SetPoint("LEFT", row.icon, "RIGHT", config.iconSize / 2, 0)

      row.fadeOutAnimation = row:CreateAnimationGroup()
      local fadeOut = row.fadeOutAnimation:CreateAnimation("Alpha")
      fadeOut:SetFromAlpha(1)
      fadeOut:SetToAlpha(0)
      fadeOut:SetDuration(1)
      fadeOut:SetStartDelay(config.fadeOutDelay)
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
        row:SetPoint("BOTTOM", self.frame, "BOTTOM", 0, index * (config.rowHeight + config.padding))
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

function LootDisplay:GetCurrencyLink(currencyID, name)
    return string.format("|cffffffff|Hcurrency:%d|h[%s]|h|r", currencyID, name)
end

function LootDisplay:ToggleTestMode()
  if self.testMode then
      -- Stop test mode
      self.testMode = false
      if self.testTimer then
          self.testTimer:Cancel()
          self.testTimer = nil
      end
      G_RLF:Print("Test Mode Disabled")
  else
      -- Start test mode
      self.testMode = true
      G_RLF:Print("Test Mode Enabled")
      self.testTimer = C_Timer.NewTicker(1.5, function() self:GenerateRandomLoot() end)
  end
end

function LootDisplay:GenerateRandomLoot()
  -- Randomly decide whether to generate an item or currency
  if math.random() < 0.8 then
      -- Generate random item
      local item = G_RLF.TestItems[math.random(#G_RLF.TestItems)]
      local amountLooted = math.random(1, 5)
      self:ShowLoot(item.id, item.link, item.icon, amountLooted)
  else
      -- Generate random currency
      local currency = G_RLF.TestCurrencies[math.random(#G_RLF.TestCurrencies)]
      local amountLooted = math.random(1, 500)
      local currencyLink = self:GetCurrencyLink(currency.currencyID, currency.name)
      self:ShowLoot(currency.currencyID, currencyLink, currency.iconFileID, amountLooted)
  end
end

-- @type LootDisplay
G_RLF.LootDisplay = LootDisplay
