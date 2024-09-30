local LootDisplay = G_RLF.RLF:NewModule("LootDisplay", "AceBucket-3.0", "AceEvent-3.0")

local lsm = LibStub("LibSharedMedia-3.0")

-- Private method declaration
local processFromQueue
local getTextWidth
local truncateItemLink

-- Private variable declaration
local frame = nil
local tempFontString = nil

-- Public methods
local logger

function LootDisplay:OnInitialize()
	frame = LootDisplayFrame
	frame:Load()

	tempFontString = UIParent:CreateFontString(nil, "ARTWORK")
	tempFontString:Hide() -- Prevent it from showing up
	self:RegisterBucketMessage({ "RLF_LootDisplay_RowReturned", "RLF_LootDisplay_Process" }, 0.2, function()
		G_RLF:fn(processFromQueue)
	end)
	self:RegisterBucketMessage("RLF_LootDisplay_UpdateRowPositions", 0.1, function()
		G_RLF:fn(frame:UpdateRowPositions())
	end)
	self:RegisterBucketMessage("RLF_RowHidden", 0.1, "ReleaseRows")
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
	self:SendMessage("RLF_LootDisplay_UpdateRowPositions")
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

function LootDisplay:ReleaseRows(rows)
	for row, freq in pairs(rows) do
		frame:ReleaseRow(row)
	end
	frame:CheckForStragglers()
end

local elementQueue = {}
function LootDisplay:ShowLoot(element)
	if type(element) ~= "table" then
		error("Expected arg to ShowLoot to be a table")
	end

	tinsert(elementQueue, element)
	self:SendMessage("RLF_LootDisplay_Process")
end

local function processRow(element)
	if not element:IsEnabled() then
		return
	end

	local key = element.key
	local textFn = element.textFn
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
			tinsert(elementQueue, element)
			return
		end

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
		row:Show()
	end

	row:ShowText(text, r, g, b, a)

	logFn(text, row.amount, new)

	row:ResetFadeOut()
end

processFromQueue = function()
	local snapshotQueueSize = #elementQueue
	if snapshotQueueSize > 0 then
		-- error("Test")
		local rowsToProcess = math.min(snapshotQueueSize, G_RLF.db.global.maxRows)
		LootDisplay:getLogger():Debug("Processing " .. rowsToProcess .. " items from element queue", G_RLF.addonName)
		for i = 1, rowsToProcess do
			local e = tremove(elementQueue, 1)
			processRow(e)
		end
	end
end

local function emptyQueue()
	local queueSize = #elementQueue
	for i = 1, queueSize do
		tremove(elementQueue, 1)
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
