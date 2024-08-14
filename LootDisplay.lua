local LootDisplay = {}

-- Private method declaration
local createDynamicPropertyTable
local doesRowExist
local getFrameHeight
local getNumberOfRows
local getRow
local getTextWidth
local leaseRow
local rowAmountText
local rowBackground
local rowFadeOutAnimation
local rowHighlightBorder
local rowIcon
local rowMoneyIcon
local rowMoneyStyles
local rowMoneyText
local rowStyles
local truncateItemLink
local updateRowPositions

-- Private variable declaration
local defaults = {
    anchorPoint = "BOTTOMLEFT",
    relativePoint = UIParent,
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
    font = "GameFontNormalSmall"
}
local config = nil
local rows = G_RLF.list()
local rowFramePool = {}
local frame = nil
local boundingBox = nil
local tempFontString = nil

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

    tempFontString = UIParent:CreateFontString(nil, "ARTWORK", config.font)
    tempFontString:Hide() -- Prevent it from showing up
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
    frame:SetPoint(config.anchorPoint, config.relativePoint, config.xOffset, config.yOffset)
end

function LootDisplay:UpdateRowStyles()
    frame:SetSize(config.feedWidth, getFrameHeight())

    for row in rows:iterate() do
        if row.copper ~= nil then
            rowMoneyStyles(row)
        else
            rowStyles(row)
        end
    end
end

function LootDisplay:UpdateFadeDelay()
    for row in rows:iterate() do
        rowFadeOutAnimation(row)
    end
end

function LootDisplay:ShowLoot(id, link, icon, amountLooted)
    local key = tostring(id) -- Use ID as a unique key

    -- Check if the item or currency is already displayed
    local row = getRow(key)
    if row then
        -- Update existing entry
        row.amount = row.amount + amountLooted
        row.highlightAnimation:Stop()
        row.highlightAnimation:Play()
    else
        row = leaseRow(key)
        if (row == nil) then
            return
        end

        -- Initialize row content
        rowStyles(row)
        row.icon:SetTexture(icon)
        row.amount = amountLooted
        local extraWidth = getTextWidth(" x" .. row.amount)
        row.link = truncateItemLink(link, extraWidth)
    end
    row.amountText:SetText(row.link .. " x" .. row.amount)
    row.fadeOutAnimation:Stop()
    row.fadeOutAnimation:Play()
end

function LootDisplay:ShowMoney(copper)
    local key = "MONEY_LOOT" -- Use ID as a unique key
    local text

    -- Check if the item or currency is already displayed
    local row = getRow(key)
    if row then
        -- Update existing entry
        row.copper = row.copper + copper
        row.highlightAnimation:Stop()
        row.highlightAnimation:Play()
    else
        row = leaseRow(key)
        if (row == nil) then
            return
        end

        -- Initialize row content
        rowMoneyStyles(row)
        row.copper = copper
    end

    text = C_CurrencyInfo.GetCoinTextureString(row.copper)
    row.amountText:SetText(text)

    row.fadeOutAnimation:Stop()
    row.fadeOutAnimation:Play()
end

function LootDisplay:HideLoot()
    local row = rows:shift()

    while row do
        row.fadeOutAnimation:Stop()
        row:Hide()
        tinsert(rowFramePool, row)
        row = rows:shift()
    end
end

G_RLF.LootDisplay = LootDisplay

-- Private method definition
createDynamicPropertyTable = function(globalTable, defaultsTable)
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
    row.background:SetGradient("HORIZONTAL", CreateColor(unpack(config.rowBackgroundGradientStart)),
        CreateColor(unpack(config.rowBackgroundGradientEnd)))
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
    row.icon:Show()
end

rowMoneyIcon = function(row)
    if row.icon == nil then
        row.icon = row:CreateTexture(nil, "ARTWORK")
    else
        row.icon:ClearAllPoints()
        row.icon:SetTexture(nil)
    end
    row.icon:SetSize(config.iconSize, config.iconSize)
    row.icon:SetPoint("LEFT", config.iconSize / 4, 0)
    row.icon:Hide()
end

rowMoneyText = function(row)
    if row.amountText == nil then
        row.amountText = row:CreateFontString(nil, "ARTWORK", config.font)
    else
        row.amountText:ClearAllPoints()
    end
    row.amountText:SetPoint("LEFT", row.icon, "LEFT", 0, 0)
end

rowAmountText = function(row)
    if row.amountText == nil then
        row.amountText = row:CreateFontString(nil, "ARTWORK", config.font)
    else
        row.amountText:ClearAllPoints()
    end
    row.amountText:SetPoint("LEFT", row.icon, "RIGHT", config.iconSize / 2, 0)
end

rowFadeOutAnimation = function(row)
    if row.fadeOutAnimation == nil then
        row.fadeOutAnimation = row:CreateAnimationGroup()
    end

    if row.fadeOutAnimation.fadeOutAlpha == nil then
        row.fadeOutAnimation.fadeOutAlpha = row.fadeOutAnimation:CreateAnimation("Alpha")
    end

    row.fadeOutAnimation.fadeOutAlpha:SetFromAlpha(1)
    row.fadeOutAnimation.fadeOutAlpha:SetToAlpha(0)
    row.fadeOutAnimation.fadeOutAlpha:SetDuration(1)
    row.fadeOutAnimation.fadeOutAlpha:SetStartDelay(config.fadeOutDelay)
    row.fadeOutAnimation.fadeOutAlpha:SetScript("OnFinished", function()
        row:Hide()
        tinsert(rowFramePool, row)
        rows:remove(row)
        updateRowPositions() -- Recalculate positions
    end)
end

-- Function to create and handle the highlight border
rowHighlightBorder = function(row)
    if row.highlightBorder == nil then
        row.highlightBorder = row:CreateTexture(nil, "OVERLAY")
        row.highlightBorder:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
        row.highlightBorder:SetBlendMode("ADD")
        row.highlightBorder:SetAlpha(0) -- Start with it invisible
    end

    row.highlightBorder:SetSize(config.feedWidth * 2, config.rowHeight * 2)
    row.highlightBorder:SetPoint("LEFT", row, "LEFT", -config.feedWidth / 2, 0)

    -- Create the animation group
    if row.highlightAnimation == nil then
        row.highlightAnimation = row.highlightBorder:CreateAnimationGroup()
    end

    if row.highlightAnimation.fadeInAlpha == nil then
        -- Fade in animation
        row.highlightAnimation.fadeInAlpha = row.highlightAnimation:CreateAnimation("Alpha")
        row.highlightAnimation.fadeInAlpha:SetFromAlpha(0)
        row.highlightAnimation.fadeInAlpha:SetToAlpha(1)
        row.highlightAnimation.fadeInAlpha:SetDuration(0.2)
    end

    if row.highlightAnimation.fadeOutAlpha == nil then
        -- Fade out animation
        row.highlightAnimation.fadeOutAlpha = row.highlightAnimation:CreateAnimation("Alpha")
        row.highlightAnimation.fadeOutAlpha:SetFromAlpha(1)
        row.highlightAnimation.fadeOutAlpha:SetToAlpha(0)
        row.highlightAnimation.fadeOutAlpha:SetDuration(0.2)
        row.highlightAnimation.fadeOutAlpha:SetStartDelay(0.3)
    end
end

rowMoneyStyles = function(row)
    row:SetSize(config.feedWidth, config.rowHeight)

    rowBackground(row)
    rowMoneyIcon(row)
    rowHighlightBorder(row)
    rowMoneyText(row)
    rowFadeOutAnimation(row)
end

rowStyles = function(row)
    row:SetSize(config.feedWidth, config.rowHeight)

    rowBackground(row)
    rowIcon(row)
    rowHighlightBorder(row)
    rowAmountText(row)
    rowFadeOutAnimation(row)
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

getTextWidth = function(text)
    tempFontString:SetText(text)
    local width = tempFontString:GetStringWidth()
    return width
end

truncateItemLink = function(itemLink, extraWidth)
    local originalLink = itemLink .. ""
    local itemName = string.match(itemLink, "%[(.-)%]")
    local begIndex, endIndex = string.find(originalLink, itemName, 1, true)
    if begIndex == nil then
        return originalLink
    end
    local linkStart = string.sub(originalLink, 0, begIndex - 1)
    local linkEnd = string.sub(originalLink, endIndex + 1)

    local maxWidth = config.feedWidth - config.iconSize - (config.iconSize / 4) - (config.iconSize / 2) - extraWidth

    -- Calculate the width of the item name plus the link start and end
    local itemNameWidth = getTextWidth("[" .. itemName .. "]")

    -- If the width exceeds maxWidth, truncate and add ellipses
    if itemNameWidth > maxWidth then
        -- Approximate truncation by progressively shortening the name
        while getTextWidth("[" .. itemName .. "...]") > maxWidth and #itemName > 0 do
            itemName = string.sub(itemName, 1, -2)
        end
        itemName = itemName .. "..."
    end

    return linkStart .. itemName .. linkEnd
end

leaseRow = function(key)
    if getNumberOfRows() >= config.maxRows then
        -- Skip this, we've already allocated too much
        return nil
    end
    local row
    if #rowFramePool == 0 then
        -- Create a new row
        row = CreateFrame("Frame", nil, frame)
    else
        row = tremove(rowFramePool)
        row:ClearAllPoints()
        row.amount = nil
        row.copper = nil
        row.link = nil
    end

    rows:push(row)
    row.key = key
    row:Show()

    -- Position the new row at the bottom of the frame
    if getNumberOfRows() == 1 then
        row:SetPoint("BOTTOM", frame, "BOTTOM")
    else
        updateRowPositions()
    end

    return row
end

