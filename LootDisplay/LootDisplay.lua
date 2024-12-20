local addonName, G_RLF = ...

local LootDisplay = G_RLF.RLF:NewModule("LootDisplay", "AceBucket-3.0", "AceEvent-3.0", "AceHook-3.0")

local lsm = G_RLF.lsm

-- Private method declaration
local processFromQueue
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
function LootDisplay:OnInitialize()
	frame = LootDisplayFrame
	frame:Load()

	tempFontString = UIParent:CreateFontString(nil, "ARTWORK")
	tempFontString:Hide() -- Prevent it from showing up
end

function LootDisplay:OnEnable()
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnPlayerCombatChange")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnPlayerCombatChange")
	self:RegisterBucketEvent("BAG_UPDATE_DELAYED", 0.5, "BAG_UPDATE_DELAYED")
	self:RegisterMessage("RLF_NEW_LOOT", "OnLootReady")
	self:RegisterBucketMessage("RLF_ROW_RETURNED", 0.3, "OnRowReturn")

	RunNextFrame(function()
		G_RLF.RLF:GetModule("TestMode"):OnLootDisplayReady()
	end)

	if G_RLF:IsClassic() then
		self:RawHook(ItemButtonMixin, "SetItemButtonTexture", function(self, texture)
			if SetItemButtonTexture_Base then
				SetItemButtonTexture_Base(texture)
			else
				-- Handle the case where SetItemButtonTexture_Base doesn't exist
				self.icon:SetTexture(texture)
			end
		end, true)

		self:RawHook(ItemButtonMixin, "SetItemButtonQuality", function(self, quality, itemIDOrLink)
			if SetItemButtonQuality_Base then
				SetItemButtonQuality_Base(quality, itemIDOrLink)
			else
				if quality then
					-- Handle the case where SetItemButtonQuality_Base doesn't exist
					local r, g, b = C_Item.GetItemQualityColor(quality)
					self.IconBorder:SetVertexColor(r, g, b)
				end
			end
		end, true)
	end
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
	G_RLF:LogInfo("BAG_UPDATE_DELAYED", "WOWEVENT", self.moduleName, nil, "BAG_UPDATE_DELAYED")

	frame:UpdateRowItemCounts()
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
	local highlight = element.highlight

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

		row.id = element.key
		row.amount = quantity
		row.type = element.type

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
			row:SetupTooltip()
		else
			text = textFn()
		end

		if icon then
			row:UpdateIcon(key, icon, quality)
		end

		row:UpdateSecondaryText(secondaryTextFn)
		row:UpdateStyles()
	end

	if not new then
		row:UpdateSecondaryText(secondaryTextFn)
	end

	if element.type == "ItemLoot" and not element.unit then
		RunNextFrame(function()
			local itemCount = C_Item.GetItemCount(element.key, true, false, true, true)
			row:ShowItemCountText(itemCount, { wrapChar = G_RLF.WrapCharEnum.PARENTHESIS })
		end)
	end

	if element.type == "Currency" then
		row:ShowItemCountText(element.totalCount, { wrapChar = G_RLF.WrapCharEnum.PARENTHESIS })
	end

	if element.type == "Reputation" and element.repLevel then
		row:ShowItemCountText(
			element.repLevel,
			{ color = G_RLF:RGBAToHexFormat(0.5, 0.5, 1, 1), wrapChar = G_RLF.WrapCharEnum.ANGLE }
		)
	end

	if element.type == "Experience" and element.currentLevel and G_RLF.db.global.xp.showCurrentLevel then
		row:ShowItemCountText(element.currentLevel, {
			color = G_RLF:RGBAToHexFormat(unpack(G_RLF.db.global.xp.currentLevelColor)),
			wrapChar = G_RLF.WrapCharEnum.ANGLE,
		})
	end

	if element.type == "Professions" then
		row:ShowItemCountText(
			row.amount,
			{ color = "|cFF5555FF", wrapChar = G_RLF.WrapCharEnum.BRACKET, showSign = true }
		)
	end

	row:ShowText(text, r, g, b, a)

	if highlight then
		RunNextFrame(function()
			row:HighlightIcon()
		end)
	end

	logFn(text, row.amount, new)

	row:ResetFadeOut()
end

function LootDisplay:OnLootReady(_, element)
	RunNextFrame(function()
		processRow(element)
	end)
end

function LootDisplay:OnRowReturn()
	RunNextFrame(function()
		processFromQueue()
	end)
end

processFromQueue = function()
	local snapshotQueueSize = elementQueue:size()
	if snapshotQueueSize > 0 then
		local rowsToProcess = math.min(snapshotQueueSize, G_RLF.db.global.maxRows)
		G_RLF:LogDebug("Processing " .. rowsToProcess .. " items from element queue")
		for i = 1, rowsToProcess do
			if elementQueue:isEmpty() then
				return
			end
			local e = elementQueue:dequeue()
			RunNextFrame(function()
				processRow(e)
			end)
		end
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
