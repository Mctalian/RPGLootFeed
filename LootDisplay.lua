local LootDisplay = G_RLF.RLF:NewModule("LootDisplay", "AceBucket-3.0", "AceEvent-3.0")

-- Private method declaration
local processRow
local processFromQueue
local doesRowExist
local getNumberOfRows
local getRow
local getTextWidth
local leaseRow
local returnRow
local returnRows
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
local defaultColor
local config = nil
local rows = G_RLF.list()
local rowFramePool = {}
local frame = nil
local boundingBox = nil
local tempFontString = nil

-- Public methods
local logger

function LootDisplay:OnInitialize()
	config = DynamicPropertyTable(G_RLF.db.global, defaults)

	frame = LootDisplayFrame
	frame:Load()

	tempFontString = UIParent:CreateFontString(nil, "ARTWORK")
	tempFontString:Hide() -- Prevent it from showing up
	self:RegisterBucketMessage("RLF_LootDisplay_RowReturned", 0.2, processFromQueue)
	self:RegisterMessage("RLF_RowHidden", returnRow)
end

function LootDisplay:SetBoundingBoxVisibility(show)
	if show then
		frame:ShowTestArea()
	else
		frame:HideTestArea()
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
	frame:UpdateSize()

	for row in rows:iterate() do
		row:UpdateStyles()
	end
end

function LootDisplay:UpdateFadeDelay()
	for row in rows:iterate() do
		row:UpdateFadeoutDelay()
	end
end

function LootDisplay:ShowLoot(type, ...)
	local key, textFn, isLink, icon, quantity, quality, r, g, b, a
	isLink = false
	local logType = type
	if type == "Currency" or type == "ItemLoot" then
		isLink = true
		local t, k
		k, t, icon, quantity = ...
		key = tostring(k)
		textFn = function(existingQuantity, truncatedLink)
			if not truncatedLink then
				return t
			end
			return truncatedLink .. " x" .. ((existingQuantity or 0) + quantity)
		end
		if type == "Currency" then
			quality = C_CurrencyInfo.GetCurrencyInfo(k).quality
		end
	elseif type == "Money" then
		key = "MONEY_LOOT"
		quantity = ...
		if not quantity then
			return
		end
		textFn = function(existingCopper)
			local sign = ""
			local total = (existingCopper or 0) + quantity
			if total < 0 then
				sign = "-"
			end
			return sign .. C_CurrencyInfo.GetCoinTextureString(math.abs(total))
		end
	elseif type == "Experience" then
		key = "EXPERIENCE"
		quantity = ...
		r, g, b, a = 1, 0, 1, 0.8
		textFn = function(existingXP)
			return "+" .. ((existingXP or 0) + quantity) .. " " .. G_RLF.L["XP"]
		end
	elseif type == "Reputation" then
		local factionName, rL, gL, bL
		quantity, factionName, rL, gL, bL = ...
		r, g, b = rL or 0.5, gL or 0.5, bL or 1
		a = 1
		key = "REP_" .. factionName
		textFn = function(existingRep)
			local sign = "+"
			local rep = (existingRep or 0) + quantity
			if rep < 0 then
				sign = "-"
			end
			return sign .. math.abs(rep) .. " " .. factionName
		end
	else
		self:getLogger():Error("Unknown type? " .. type, G_RLF.addonName, type)
	end
	processRow(key, textFn, icon, quantity, quality, r, g, b, a, logType)
end

local overflowQueue = {}
processRow = function(...)
	local key, textFn, icon, quantity, quality, r, g, b, a, logType = ...
	local isLink = not not icon
	local new = true
	local text

	local rD, gD, bD, aD = unpack(defaultColor or { 1, 1, 1, 1 })

	local row = getRow(key)
	if row then
		-- Update existing entry
		new = false
		row.meta = { ... }
		text = textFn(row.amount, row.link)
		row.amount = row.amount + quantity

		row:UpdateQuantity()
	else
		-- New row
		row = leaseRow(key)
		if row == nil then
			tinsert(overflowQueue, { ... })
			return
		end

		row.meta = { ... }
		row.amount = quantity

		if isLink then
			local extraWidth = getTextWidth(" x" .. row.amount)
			row.link = truncateItemLink(textFn(), extraWidth)
			text = textFn(0, row.link)

			row:UpdateIcon(key, icon, quality)

			row:SetupTooltip()
		else
			text = textFn()
		end

		row:UpdateStyles()
	end

	row:ShowText(text, r, g, b, a)

	local amountLogText = row.amount
	if not new then
		amountLogText = format("%s (+%s)", row.amount, quantity)
	end
	LootDisplay:getLogger():Info(logType .. " Shown", G_RLF.addonName, logType, key, text, amountLogText, new)

	row:ResetFadeOut()
end

processFromQueue = function()
	local snapshotQueueSize = #overflowQueue
	if snapshotQueueSize > 0 then
		-- error("Test")
		local rowsToProcess = math.min(snapshotQueueSize, config.maxRows)
		LootDisplay:getLogger():Debug("Processing " .. rowsToProcess .. " items from overflow queue", G_RLF.addonName)
		for i = 1, math.min(snapshotQueueSize, config.maxRows) do
			-- Get the first set of args from the queue
			local args = tremove(overflowQueue, 1) -- Remove and return the first element
			-- Call processRow with the unpacked arguments
			processRow(unpack(args))
		end
	end
end

function LootDisplay:HideLoot()
	local row = rows:shift()

	while row do
		row.FadeOutAnimation:Stop()
		row:Hide()
		row = rows:shift()
	end
end

G_RLF.LootDisplay = LootDisplay

updateRowPositions = function()
	local index = 0
	for row in rows:iterate() do
		if row:IsShown() then
			row:UpdateStyles()
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

leaseRow = function(key)
	if getNumberOfRows() >= config.maxRows then
		-- Skip this, we've already allocated too much
		return nil
	end
	local row
	if #rowFramePool == 0 then
		-- Create a new row from the XML template
		row = CreateFrame("Frame", nil, frame, "LootDisplayRowTemplate")
	else
		-- Reuse an existing row from the pool
		row = tremove(rowFramePool)
		row:Reset(defaultColor)
	end

	-- Assign the key to the row
	row.key = key

	-- Add the row to the rows list and show it
	rows:push(row)
	row:Show()

	-- Position the new row at the bottom (or top if growing up)
	if getNumberOfRows() == 1 then
		local vertDir = G_RLF.db.global.growUp and "BOTTOM" or "TOP"
		row:SetPoint(vertDir, frame, vertDir)
	else
		updateRowPositions()
	end

	return row
end

returnRow = function(_, row)
	tinsert(rowFramePool, row)
	LootDisplay:SendMessage("RLF_LootDisplay_RowReturned")
end
