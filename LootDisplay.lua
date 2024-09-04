local LootDisplay = {}

local Masque = LibStub and LibStub("Masque", true)
local iconGroup = Masque and Masque:Group(G_RLF.addonName)

-- Private method declaration
local configureFeedFrame
local applyRowStyles
local doesRowExist
local getFrameHeight
local getNumberOfRows
local getRow
local getTextWidth
local leaseRow
local returnRow
local rowAmountText
local rowBackground
local rowFadeOutAnimation
local rowHighlightBorder
local rowIcon
local rowMoneyIcon
local rowMoneyStyles
local rowMoneyText
local rowStyles
local configureTestArea
local createArrowsTestArea
local showTestArea
local hideTestArea
local truncateItemLink
local updateRowPositions

-- Private variable declaration
local defaults = {
	anchorPoint = "BOTTOMLEFT",
	relativePoint = UIParent,
	frameStrata = "MEDIUM",
	xOffset = 720,
	yOffset = 375,
	feedWidth = 330,
	maxRows = 10,
	rowHeight = 22,
	padding = 2,
	iconSize = 18,
	fadeOutDelay = 5,
	rowBackgroundGradientStart = { 0.1, 0.1, 0.1, 0.8 }, -- Default to dark grey with 80% opacity
	rowBackgroundGradientEnd = { 0.1, 0.1, 0.1, 0 }, -- Default to dark grey with 0% opacity
	font = "GameFontNormalSmall",
}
local config = nil
local rows = G_RLF.list()
local rowFramePool = {}
local frame = nil
local boundingBox = nil
local tempFontString = nil

-- Public methods
function LootDisplay:Initialize()
	config = DynamicPropertyTable(G_RLF.db.global, defaults)

	configureFeedFrame()

	configureTestArea()
	createArrowsTestArea()

	tempFontString = UIParent:CreateFontString(nil, "ARTWORK")
	tempFontString:Hide() -- Prevent it from showing up
end

function LootDisplay:SetBoundingBoxVisibility(show)
	if show then
		showTestArea()
	else
		hideTestArea()
	end
end

function LootDisplay:ToggleBoundingBox()
	self:SetBoundingBoxVisibility(not boundingBox:IsVisible())
end

function LootDisplay:UpdatePosition()
	frame:ClearAllPoints()
	frame:SetPoint(config.anchorPoint, _G[config.relativePoint], config.xOffset, config.yOffset)
end

function LootDisplay:UpdateRowPositions()
	updateRowPositions()
end

function LootDisplay:UpdateStrata()
	if frame then
		frame:SetFrameStrata(config.frameStrata)
	end
end

function LootDisplay:UpdateRowStyles()
	frame:SetSize(config.feedWidth, getFrameHeight())

	for row in rows:iterate() do
		applyRowStyles(row)
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
		if not G_RLF.db.global.disableRowHighlight then
			row.highlightAnimation:Stop()
			row.highlightAnimation:Play()
		end
		if row.fadeOutAnimation:IsPlaying() then
			row.fadeOutAnimation:Stop()
			row.fadeOutAnimation:Play()
		end
	else
		row = leaseRow(key)
		if row == nil then
			return
		end

		-- Initialize row content
		rowStyles(row)
		if Masque and iconGroup then
			local found = string.find(link, "item:")
			if found then
				row.icon:SetItem(link)
			else
				local quality = C_CurrencyInfo.GetCurrencyInfo(id).quality
				row.icon:SetItemButtonTexture(icon)
				row.icon:SetItemButtonQuality(quality, link)
			end
		else
			row.icon:SetTexture(icon)
		end
		row.amount = amountLooted
		local extraWidth = getTextWidth(" x" .. row.amount)
		row.link = truncateItemLink(link, extraWidth)
		row.fadeOutAnimation:Stop()
		row.fadeOutAnimation:Play()
	end
	row.amountText:SetText(row.link .. " x" .. row.amount)
	-- Add Tooltip
	row.amountText:SetScript("OnEnter", function()
		row.fadeOutAnimation:Stop()
		row.highlightAnimation:Stop()
		row.highlightBorder:SetAlpha(0)
		if not G_RLF.db.global.tooltip then
			return
		end
		if G_RLF.db.global.tooltipOnShift and not IsShiftKeyDown() then
			return
		end
		local inCombat = UnitAffectingCombat("player")
		if inCombat then
			GameTooltip:Hide()
			return
		end
		GameTooltip:SetOwner(row.amountText, "ANCHOR_RIGHT")
		GameTooltip:SetHyperlink(row.link) -- Use the item's link to show the tooltip
		GameTooltip:Show()
	end)
	row.amountText:SetScript("OnLeave", function()
		row.fadeOutAnimation:Play()
		GameTooltip:Hide()
	end)
end

function LootDisplay:ShowMoney(copper)
	local key = "MONEY_LOOT" -- Use ID as a unique key
	local text

	if not copper or copper <= 0 then
		return
	end

	-- Check if the item or currency is already displayed
	local row = getRow(key)
	if row then
		-- Update existing entry
		row.copper = row.copper + copper
		row.highlightAnimation:Stop()
		row.highlightAnimation:Play()
	else
		row = leaseRow(key)
		if row == nil then
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

function LootDisplay:ShowXP(experience)
	local key = "EXPERIENCE" -- Use ID as a unique key
	local text

	-- Check if the item or currency is already displayed
	local row = getRow(key)
	if row then
		-- Update existing entry
		row.experience = row.experience + experience
		row.highlightAnimation:Stop()
		row.highlightAnimation:Play()
	else
		row = leaseRow(key)
		if row == nil then
			return
		end

		-- Initialize row content
		rowMoneyStyles(row)
		row.experience = experience
	end

	text = "+" .. row.experience .. " " .. G_RLF.L["XP"]
	row.amountText:SetText(text)
	row.amountText:SetTextColor(1, 0, 1, 0.8)

	row.fadeOutAnimation:Stop()
	row.fadeOutAnimation:Play()
end

function LootDisplay:ShowRep(rep, factionName, r, g, b)
	local key = "REP_" .. factionName -- Use ID as a unique key
	local text

	-- Check if the item or currency is already displayed
	local row = getRow(key)
	if row then
		-- Update existing entry
		row.rep = row.rep + rep
		row.highlightAnimation:Stop()
		row.highlightAnimation:Play()
	else
		row = leaseRow(key)
		if row == nil then
			return
		end

		-- Initialize row content
		rowMoneyStyles(row)
		row.rep = rep
	end
	local sign = "+"
	if rep < 0 then
		sign = "-"
	end
	text = sign .. math.abs(row.rep) .. " " .. factionName
	row.amountText:SetText(text)
	local r, g, b = r or 0.5, g or 0.5, b or 1
	row.amountText:SetTextColor(r, g, b, 1)

	row.fadeOutAnimation:Stop()
	row.fadeOutAnimation:Play()
end

function LootDisplay:HideLoot()
	local row = rows:shift()

	while row do
		row.fadeOutAnimation:Stop()
		returnRow(row)
		row = rows:shift()
	end
end

G_RLF.LootDisplay = LootDisplay

configureFeedFrame = function()
	frame = CreateFrame("Frame", "LootDisplayFrame", UIParent)
	frame:SetSize(config.feedWidth, getFrameHeight())
	frame:SetPoint(config.anchorPoint, _G[config.relativePoint], config.xOffset, config.yOffset)

	frame:SetFrameStrata(config.frameStrata) -- Set the frame strata here

	frame:SetClipsChildren(true) -- Enable clipping of child elements

	frame:SetClampedToScreen(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()

		-- Save the new position
		local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
		G_RLF.db.global.anchorPoint = point
		G_RLF.db.global.relativePoint = relativeTo or -1
		G_RLF.db.global.xOffset = xOfs
		G_RLF.db.global.yOffset = yOfs

		-- Update the frame position
		G_RLF.LootDisplay:UpdatePosition()
		LibStub("AceConfigRegistry-3.0"):NotifyChange(G_RLF.addonName)
	end)
end

rowBackground = function(row)
	-- Create row background
	if row.background == nil then
		row.background = row:CreateTexture(nil, "BACKGROUND")
	else
		row.background:ClearAllPoints()
	end
	row.background:SetTexture("Interface/Buttons/WHITE8x8")
	local leftColor = CreateColor(unpack(config.rowBackgroundGradientStart))
	local rightColor = CreateColor(unpack(config.rowBackgroundGradientEnd))
	if G_RLF.db.global.leftAlign == false then
		leftColor = CreateColor(unpack(config.rowBackgroundGradientEnd))
		rightColor = CreateColor(unpack(config.rowBackgroundGradientStart))
	end
	row.background:SetGradient("HORIZONTAL", leftColor, rightColor)
	row.background:SetAllPoints()
end

rowIcon = function(row)
	if row.icon == nil then
		if Masque and iconGroup then
			row.icon = CreateFrame("ItemButton", nil, row)
		else
			row.icon = row:CreateTexture(nil, "ARTWORK")
		end
	else
		row.icon:ClearAllPoints()
	end
	row.icon:SetSize(config.iconSize, config.iconSize)
	local anchor = "LEFT"
	local xOffset = config.iconSize / 4
	if G_RLF.db.global.leftAlign == false then
		anchor = "RIGHT"
		xOffset = xOffset * -1
	end
	if Masque and iconGroup then
		iconGroup:AddButton(row.icon)
	end
	row.icon:SetPoint(anchor, xOffset, 0)
	row.icon:Show()
end

rowMoneyIcon = function(row)
	if row.icon == nil then
		if Masque and iconGroup then
			row.icon = CreateFrame("ItemButton", nil, row)
			iconGroup:AddButton(row.icon)
		else
			row.icon = row:CreateTexture(nil, "ARTWORK")
		end
	else
		row.icon:ClearAllPoints()
	end
	row.icon:SetSize(config.iconSize, config.iconSize)
	local anchor = "LEFT"
	local xOffset = config.iconSize / 4
	if G_RLF.db.global.leftAlign == false then
		anchor = "RIGHT"
		xOffset = xOffset * -1
	end
	row.icon:SetPoint(anchor, xOffset, 0)
	row.icon:Hide()
end

local defaultColor
rowMoneyText = function(row)
	if row.amountText == nil then
		row.amountText = row:CreateFontString(nil, "ARTWORK")
		if not defaultColor then
			local r, g, b, a = row.amountText:GetTextColor()
			defaultColor = { r, g, b, a }
		end
	else
		row.amountText:ClearAllPoints()
	end
	local anchor = "LEFT"
	if G_RLF.db.global.leftAlign == false then
		anchor = "RIGHT"
	end
	row.amountText:SetFontObject(config.font)
	row.amountText:SetPoint(anchor, row.icon, anchor, 0, 0)
end

rowAmountText = function(row)
	if row.amountText == nil then
		row.amountText = row:CreateFontString(nil, "ARTWORK")
		if not defaultColor then
			local r, g, b, a = row.amountText:GetTextColor()
			defaultColor = { r, g, b, a }
		end
	else
		row.amountText:ClearAllPoints()
	end
	local anchor = "LEFT"
	local iconAnchor = "RIGHT"
	local xOffset = config.iconSize / 2
	if G_RLF.db.global.leftAlign == false then
		anchor = "RIGHT"
		iconAnchor = "LEFT"
		xOffset = xOffset * -1
	end
	row.amountText:SetFontObject(config.font)
	row.amountText:SetPoint(anchor, row.icon, iconAnchor, xOffset, 0)
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
		returnRow(row)
		rows:remove(row)
		updateRowPositions() -- Recalculate positions
	end)
end

-- Function to create and handle the highlight border
rowHighlightBorder = function(row)
	if row.highlightBorder == nil then
		row.highlightBorder = row:CreateTexture(nil, "OVERLAY")
		row.highlightBorder:SetTexture("Interface\\COMMON\\WhiteIconFrame")
		row.highlightBorder:SetBlendMode("ADD")
		row.highlightBorder:SetAlpha(0) -- Start with it invisible
	end

	row.highlightBorder:SetSize(config.feedWidth * 1.1, config.rowHeight)
	row.highlightBorder:SetPoint("LEFT", row, "LEFT", -config.feedWidth * 0.05, 0)

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

applyRowStyles = function(row)
	if row.copper ~= nil or row.experience ~= nil or row.rep ~= nil then
		rowMoneyStyles(row)
	else
		rowStyles(row)
	end
	if iconGroup then
		iconGroup:ReSkin(row.icon)
	end
end

updateRowPositions = function()
	local index = 0
	for row in rows:iterate() do
		if row:IsShown() then
			applyRowStyles(row)
			row:ClearAllPoints()
			local vertDir = "BOTTOM"
			local yOffset = index * (config.rowHeight + config.padding)
			if not G_RLF.db.global.growUp then
				vertDir = "TOP"
				yOffset = yOffset * -1
			end
			row:SetPoint(vertDir, frame, vertDir, 0, yOffset)
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
	tempFontString:SetFontObject(config.font)
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

local function createArrow(f, direction)
	local arrow = f:CreateTexture(nil, "OVERLAY")
	arrow:SetSize(16, 16) -- Example size, adjust as needed
	arrow:SetTexture("Interface\\Buttons\\Arrow-Up-Up") -- Using a built-in texture

	if direction == "UP" then
		arrow:SetPoint("TOP", f, "TOP", 0, -20)
		arrow:SetRotation(0)
	elseif direction == "DOWN" then
		arrow:SetPoint("BOTTOM", f, "BOTTOM", 0, 20)
		arrow:SetRotation(math.pi) -- Rotate 180 degrees
	elseif direction == "LEFT" then
		arrow:SetPoint("LEFT", f, "LEFT", 20, 0)
		arrow:SetRotation(math.pi * 0.5) -- Rotate 270 degrees
	elseif direction == "RIGHT" then
		arrow:SetPoint("RIGHT", f, "RIGHT", -20, 0)
		arrow:SetRotation(math.pi * 1.5) -- Rotate 90 degrees
	end

	arrow:Hide()

	return arrow
end

createArrowsTestArea = function()
	if not frame.arrows then
		frame.arrows = {
			createArrow(frame, "UP"),
			createArrow(frame, "DOWN"),
			createArrow(frame, "LEFT"),
			createArrow(frame, "RIGHT"),
		}
	end
end

configureTestArea = function()
	boundingBox = frame:CreateTexture(nil, "BACKGROUND")
	boundingBox:SetColorTexture(1, 0, 0, 0.5) -- Red with 50% opacity
	boundingBox:SetAllPoints()
	boundingBox:Hide()
	if not boundingBox.instructionText then
		boundingBox.instructionText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		boundingBox.instructionText:SetPoint("CENTER", frame, "CENTER")
		boundingBox.instructionText:SetText(G_RLF.addonName .. "\n" .. G_RLF.L["Drag to Move"])
		boundingBox.instructionText:SetTextColor(1, 1, 1)
		boundingBox.instructionText:Hide()
	end
end

showTestArea = function()
	boundingBox:Show()
	frame:SetMovable(true)
	frame:EnableMouse(true)
	boundingBox.instructionText:Show()
	for i, a in ipairs(frame.arrows) do
		a:Show()
	end
end

hideTestArea = function()
	boundingBox:Hide()
	frame:SetMovable(false)
	frame:EnableMouse(false)
	boundingBox.instructionText:Hide()
	for i, a in ipairs(frame.arrows) do
		a:Hide()
	end
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
		row.experience = nil
		row.rep = nil
		if row.highlightBorder then
			row.highlightBorder:SetAlpha(0)
		end
		if row.fadeOutAnimation then
			row.fadeOutAnimation:Stop()
		end
		if row.highlightAnimation then
			row.highlightAnimation:Stop()
		end
		if row.amountText then
			row.amountText:SetScript("OnEnter", nil)
			row.amountText:SetScript("OnLeave", nil)
			if defaultColor then
				row.amountText:SetTextColor(unpack(defaultColor))
			end
		end
	end
	row.key = key

	rows:push(row)
	row:Show()

	-- Position the new row at the bottom of the frame
	if getNumberOfRows() == 1 then
		local vertDir = "BOTTOM"
		if not G_RLF.db.global.growUp then
			vertDir = "TOP"
		end
		row:SetPoint(vertDir, frame, vertDir)
	else
		updateRowPositions()
	end

	return row
end

returnRow = function(row)
	row:Hide()
	tinsert(rowFramePool, row)
end
