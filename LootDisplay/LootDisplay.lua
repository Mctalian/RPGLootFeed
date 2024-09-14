local LootDisplay = G_RLF.RLF:NewModule("LootDisplay", "AceBucket-3.0", "AceEvent-3.0")

-- Private method declaration
local processRow
local processFromQueue
local doesRowExist
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
	self:RegisterBucketMessage("RLF_LootDisplay_RowReturned", 0.2, processFromQueue)
	self:RegisterMessage("RLF_RowHidden", function(_, row)
		frame:ReleaseRow(row)
	end)
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

	local row = frame:GetRow(key)
	if row then
		-- Update existing entry
		new = false
		row.meta = { ... }
		text = textFn(row.amount, row.link)
		row.amount = row.amount + quantity

		row:UpdateQuantity()
	else
		-- New row
		row = frame:LeaseRow(key)
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
		local rowsToProcess = math.min(snapshotQueueSize, G_RLF.db.global.maxRows)
		LootDisplay:getLogger():Debug("Processing " .. rowsToProcess .. " items from overflow queue", G_RLF.addonName)
		for i = 1, rowsToProcess do
			-- Get the first set of args from the queue
			local args = tremove(overflowQueue, 1) -- Remove and return the first element
			-- Call processRow with the unpacked arguments
			processRow(unpack(args))
		end
	end
end

function LootDisplay:HideLoot()
	frame:ClearFeed()
end

G_RLF.LootDisplay = LootDisplay

getTextWidth = function(text)
	tempFontString:SetFontObject(G_RLF.db.global.font)
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
