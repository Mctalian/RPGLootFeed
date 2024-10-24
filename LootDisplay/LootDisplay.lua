local addonName, G_RLF = ...

local LootDisplay = G_RLF.RLF:NewModule("LootDisplay", "AceEvent-3.0")

local lsm = G_RLF.lsm

-- Private method declaration
local processFromQueue
local debounceProcessFromQueue
local getTextWidth
local truncateItemLink

-- Private variable declaration
local frame = nil
local tempFontString = nil
local elementQueue = G_RLF.Queue:new()

--@alpha@
local TestLabelQueueSize
-- Create a label to display the queue size
TestLabelQueueSize = UIParent:CreateFontString(nil, "ARTWORK")
TestLabelQueueSize:SetFontObject(GameFontNormal)
TestLabelQueueSize:SetPoint("TOPLEFT", 10, -10)
TestLabelQueueSize:SetText("Queue Size: 0")

-- Function to update test labels
local function updateTestLabels()
	if TestLabelQueueSize then
		TestLabelQueueSize:SetText("Queue Size: " .. elementQueue:size())
	end
end
-- Wrapper function to update test labels after calling the original function
local function updateTestLabelsWrapper(func)
	return function(...)
		local result = { func(...) }
		updateTestLabels()
		return unpack(result)
	end
end

elementQueue.enqueue = updateTestLabelsWrapper(elementQueue.enqueue)
elementQueue.dequeue = updateTestLabelsWrapper(elementQueue.dequeue)
--@end-alpha@

-- Public methods
local logger

function LootDisplay:OnInitialize()
	frame = LootDisplayFrame
	frame:Load()

	tempFontString = UIParent:CreateFontString(nil, "ARTWORK")
	tempFontString:Hide() -- Prevent it from showing up
	frame.OnRowRelease = function()
		if elementQueue:size() > 0 then
			debounceProcessFromQueue()
		end
	end
	C_Timer.After(0, function()
		G_RLF.RLF:GetModule("TestMode"):OnLootDisplayReady()
	end)

	self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnPlayerCombatChange")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnPlayerCombatChange")
end

function LootDisplay:OnPlayerCombatChange()
	frame:UpdateTabVisibility()
end

function LootDisplay:SetBoundingBoxVisibility(show)
	if show then
		frame:ShowTestArea()
	else
		frame:HideTestArea()
	end
end

function LootDisplay:ToggleBoundingBox()
	self:SetBoundingBoxVisibility(not frame.BoundingBox:IsVisible())
end

function LootDisplay:UpdatePosition()
	frame:ClearAllPoints()
	frame:SetPoint(
		G_RLF.db.global.anchorPoint,
		_G[G_RLF.db.global.relativePoint],
		G_RLF.db.global.xOffset,
		G_RLF.db.global.yOffset
	)
end

function LootDisplay:UpdateRowPositions()
	frame:UpdateRowPositions()
end

function LootDisplay:UpdateStrata()
	if frame then
		frame:SetFrameStrata(G_RLF.db.global.frameStrata)
	end
end

function LootDisplay:UpdateRowStyles()
	frame:UpdateSize()
end

function LootDisplay:UpdateFadeDelay()
	frame:UpdateFadeDelay()
end

local function processRow(element)
	if not element:IsEnabled() then
		return
	end

	local key = element.key
	local textFn = element.textFn
	local secondaryTextFn = element.secondaryTextFn or function()
		return ""
	end
	local icon = element.icon
	local quantity = element.quantity
	local quality = element.quality
	local r, g, b, a = element.r, element.g, element.b, element.a
	local logFn = element.logFn
	local isLink = element.isLink

	local new = true
	local text

	local row = frame:GetRow(key)
	if row then
		-- Update existing entry
		new = false
		text = textFn(row.amount, row.link)
		row.amount = row.amount + quantity

		row:UpdateQuantity()
	else
		-- New row
		row = frame:LeaseRow(key)
		if row == nil then
			elementQueue:enqueue(element)
			return
		end

		row.amount = quantity

		if isLink then
			local extraWidth = getTextWidth(" x" .. row.amount)
			row.link = truncateItemLink(textFn(), extraWidth)
			row.quality = quality
			text = textFn(0, row.link)

			row:UpdateIcon(key, icon, quality)

			row:SetupTooltip()
		else
			text = textFn()
		end

		row:UpdateSecondaryText(secondaryTextFn)
		row:UpdateStyles()
	end

	if not new then
		row:UpdateSecondaryText(secondaryTextFn)
	end

	row:ShowText(text, r, g, b, a)

	logFn(text, row.amount, new)

	row:ResetFadeOut()
end

function LootDisplay:ShowLoot(element)
	elementQueue:enqueue(element)
	debounceProcessFromQueue()
end

processFromQueue = function()
	local snapshotQueueSize = elementQueue:size()
	if snapshotQueueSize > 0 then
		local rowsToProcess = math.min(snapshotQueueSize, G_RLF.db.global.maxRows)
		LootDisplay:getLogger():Debug("Processing " .. rowsToProcess .. " items from element queue", addonName)
		for i = 1, rowsToProcess do
			if elementQueue:isEmpty() then
				return
			end
			local e = elementQueue:dequeue()
			processRow(e)
		end
	end
end

local debounceTimer = nil
local maxWaitTimer = nil
local debounceDelay = 0.15 -- 150 milliseconds
local maxWaitTime = debounceDelay * 2
debounceProcessFromQueue = function()
	if debounceTimer then
		debounceTimer:Cancel()
	end

	debounceTimer = C_Timer.NewTimer(debounceDelay, function()
		G_RLF:fn(processFromQueue)
		debounceTimer = nil
	end)

	if not maxWaitTimer then
		maxWaitTimer = C_Timer.NewTimer(maxWaitTime, function()
			if debounceTimer then
				debounceTimer:Cancel()
				debounceTimer = nil
			end
			G_RLF:fn(processFromQueue)
			maxWaitTimer = nil
		end)
	end
end

local function emptyQueue()
	while not elementQueue:isEmpty() do
		elementQueue:dequeue()
	end
end

function LootDisplay:HideLoot()
	emptyQueue()
	frame:ClearFeed()
end

G_RLF.LootDisplay = LootDisplay

getTextWidth = function(text)
	if G_RLF.db.global.useFontObjects or not G_RLF.db.global.fontFace then
		tempFontString:SetFontObject(G_RLF.db.global.font)
	else
		local fontPath = lsm:Fetch(lsm.MediaType.FONT, G_RLF.db.global.fontFace)
		tempFontString:SetFont(fontPath, G_RLF.db.global.fontSize, G_RLF.defaults.global.fontFlags)
	end
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

	local maxWidth = G_RLF.db.global.feedWidth
		- G_RLF.db.global.iconSize
		- (G_RLF.db.global.iconSize / 4)
		- (G_RLF.db.global.iconSize / 2)
		- extraWidth

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

return LootDisplay
