local addonName, G_RLF = ...

local LootDisplay = G_RLF.RLF:NewModule("LootDisplay", "AceBucket-3.0", "AceEvent-3.0")

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
local pendingCounts = {}

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
	RunNextFrame(function()
		G_RLF.RLF:GetModule("TestMode"):OnLootDisplayReady()
	end)

	self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnPlayerCombatChange")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnPlayerCombatChange")
	self:RegisterBucketEvent("BAG_UPDATE_DELAYED", 0.5, "BAG_UPDATE_DELAYED")
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

function LootDisplay:BAG_UPDATE_DELAYED()
	self:getLogger():Info(eventName, "WOWEVENT", self.moduleName, nil, eventName)

	local snapshotCountsNum = #pendingCounts

	local function ItemCountUpdate(itemId, row)
		local itemCount = C_Item.GetItemCount(itemId, true, false, true, true)
		if itemCount and itemCount > 0 then
			row:ShowItemCountText(itemCount)
		else
			print("ItemCountUpdate", "No item count", itemId, itemCount)
		end
	end

	for i = 1, snapshotCountsNum do
		local itemId, row = unpack(pendingCounts[1])
		RunNextFrame(function()
			ItemCountUpdate(itemId, row)
		end)
		tremove(pendingCounts, 1)
	end
	if #pendingCounts > 0 then
		print("BAG_UPDATE_DELAYED", "Pending counts remaining", #pendingCounts)
		print(dump(pendingCounts))
	end
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
	local unit = element.unit
	local itemCount = element.itemCount

	if unit then
		key = unit .. "_" .. key
	end

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

		if unit then
			row.unit = unit
		end

		row.amount = quantity

		if isLink then
			local extraWidthStr = " x" .. row.amount
			if element.itemCount then
				extraWidthStr = extraWidthStr .. " (" .. element.itemCount .. ")"
			end

			local extraWidth = getTextWidth(extraWidthStr)
			if row.unit then
				local portraitSize = G_RLF.db.global.iconSize * 0.8
				extraWidth = extraWidth + portraitSize - (portraitSize / 2)
			end
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

	if element.type == "ItemLoot" and not element.unit then
		tinsert(pendingCounts, { textFn(), row })
	end

	if element.type == "Currency" then
		row:ShowItemCountText(element.totalCount)
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
		LootDisplay:getLogger():Debug("Processing " .. rowsToProcess .. " items from element queue")
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
		debounceTimer = nil
	end

	debounceTimer = C_Timer.NewTimer(debounceDelay, function()
		LootDisplay:getLogger():Debug("Debounce Timer fired", addonName)
		if maxWaitTimer then
			maxWaitTimer:Cancel()
			maxWaitTimer = nil
		end
		debounceTimer:Cancel()
		debounceTimer = nil
		G_RLF:fn(processFromQueue)
	end)

	if not maxWaitTimer then
		maxWaitTimer = C_Timer.NewTimer(maxWaitTime, function()
			LootDisplay:getLogger():Debug("Max Wait Timer fired", addonName)
			if debounceTimer then
				debounceTimer:Cancel()
				debounceTimer = nil
			end
			maxWaitTimer:Cancel()
			maxWaitTimer = nil
			G_RLF:fn(processFromQueue)
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
