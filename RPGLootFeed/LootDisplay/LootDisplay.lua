---@type string, G_RLF
local addonName, G_RLF = ...

---@class LootDisplay: RLF_Module, AceBucket, AceEvent, AceHook
local LootDisplay = G_RLF.RLF:NewModule("LootDisplay", "AceBucket-3.0", "AceEvent-3.0", "AceHook-3.0")

local lsm = G_RLF.lsm

-- Private method declaration
local processFromQueue

-- Private variable declaration
local frame = nil
local elementQueue = G_RLF.Queue:new()
G_RLF.tempFontString = nil

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
	---@type RLF_LootDisplayFrame
	frame = LootDisplayFrame
	frame:Load()

	G_RLF.tempFontString = UIParent:CreateFontString(nil, "ARTWORK")
	G_RLF.tempFontString:Hide() -- Prevent it from showing up
end

function LootDisplay:OnEnable()
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnPlayerCombatChange")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnPlayerCombatChange")
	self:RegisterBucketEvent("BAG_UPDATE_DELAYED", 0.5, "BAG_UPDATE_DELAYED")
	self:RegisterMessage("RLF_NEW_LOOT", "OnLootReady")
	self:RegisterMessage("RLF_NEW_PARTY_LOOT", "OnPartyLootReady")
	self:RegisterBucketMessage("RLF_ROW_RETURNED", 0.3, "OnRowReturn")

	RunNextFrame(function()
		G_RLF.RLF:GetModule("TestMode"):OnLootDisplayReady()
	end)

	if G_RLF:IsClassic() or G_RLF:IsCataClassic() then
		if not ItemButtonMixin.SetItemButtonTexture then
			ItemButtonMixin.SetItemButtonTexture = function(self, texture) end
		end

		self:RawHook(ItemButtonMixin, "SetItemButtonTexture", function(self, texture)
			if SetItemButtonTexture_Base then
				SetItemButtonTexture_Base(texture)
			else
				-- Handle the case where SetItemButtonTexture_Base doesn't exist
				self.icon:SetTexture(texture)
			end
		end, true)

		if not ItemButtonMixin.SetItemButtonQuality then
			ItemButtonMixin.SetItemButtonQuality = function(self, quality, itemIDOrLink) end
		end

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
	if frame == nil then
		return
	end

	frame:UpdateTabVisibility()
end

function LootDisplay:SetBoundingBoxVisibility(show)
	if frame == nil then
		return
	end

	if show then
		frame:ShowTestArea()
	else
		frame:HideTestArea()
	end
end

function LootDisplay:ToggleBoundingBox()
	if frame == nil then
		return
	end
	self:SetBoundingBoxVisibility(not frame.BoundingBox:IsVisible())
end

function LootDisplay:UpdatePosition()
	if frame == nil then
		return
	end
	frame:ClearAllPoints()
	frame:SetPoint(
		G_RLF.db.global.positioning.anchorPoint,
		_G[G_RLF.db.global.positioning.relativePoint],
		G_RLF.db.global.positioning.xOffset,
		G_RLF.db.global.positioning.yOffset
	)
end

function LootDisplay:UpdateRowPositions()
	if frame == nil then
		return
	end

	frame:UpdateRowPositions()
end

function LootDisplay:UpdateStrata()
	if frame then
		frame:SetFrameStrata(G_RLF.db.global.positioning.frameStrata)
	end
end

function LootDisplay:UpdateRowStyles()
	if frame == nil then
		return
	end

	frame:UpdateSize()
end

function LootDisplay:UpdateEnterAnimation()
	if frame == nil then
		return
	end

	frame:UpdateEnterAnimationType()
end

function LootDisplay:UpdateFadeDelay()
	if frame == nil then
		return
	end

	frame:UpdateFadeDelay()
end

function LootDisplay:BAG_UPDATE_DELAYED()
	if frame == nil then
		return
	end

	G_RLF:LogInfo("BAG_UPDATE_DELAYED", "WOWEVENT", self.moduleName, nil, "BAG_UPDATE_DELAYED")

	frame:UpdateRowItemCounts()
end

local function processRow(element)
	if frame == nil then
		return
	end

	if not element:IsEnabled() then
		return
	end

	local key = element.key
	local unit = element.unit

	if unit then
		key = unit .. "_" .. key
	end

	local row = frame:GetRow(key)
	if row then
		RunNextFrame(function()
			row:UpdateQuantity(element)
		end)
	else
		-- New row
		row = frame:LeaseRow(key)
		if row == nil then
			elementQueue:enqueue(element)
			return
		end

		RunNextFrame(function()
			row:BootstrapFromElement(element)
		end)
	end
end

function LootDisplay:OnLootReady(_, element)
	processRow(element)
end

function LootDisplay:OnPartyLootReady(_, element)
	processRow(element)
end

function LootDisplay:OnRowReturn()
	processFromQueue()
end

processFromQueue = function()
	local snapshotQueueSize = elementQueue:size()
	if snapshotQueueSize > 0 then
		local rowsToProcess = math.min(snapshotQueueSize, G_RLF.db.global.sizing.maxRows)
		G_RLF:LogDebug("Processing " .. rowsToProcess .. " items from element queue")
		for i = 1, rowsToProcess do
			if elementQueue:isEmpty() then
				return
			end
			local e = elementQueue:dequeue()
			processRow(e)
		end
	end
end

local function emptyQueue()
	while not elementQueue:isEmpty() do
		elementQueue:dequeue()
	end
end

function LootDisplay:HideLoot()
	if frame == nil then
		return
	end

	emptyQueue()
	frame:ClearFeed()
end

G_RLF.LootDisplay = LootDisplay

function G_RLF:CalculateTextWidth(text)
	local fontFace = G_RLF.db.global.styling.fontFace
	if G_RLF.db.global.styling.useFontObjects or not fontFace then
		G_RLF.tempFontString:SetFontObject(G_RLF.db.global.styling.font)
	else
		local fontPath = lsm:Fetch(lsm.MediaType.FONT, fontFace)
		G_RLF.tempFontString:SetFont(
			fontPath,
			G_RLF.db.global.styling.fontSize,
			G_RLF.defaults.global.styling.fontFlags
		)
	end
	G_RLF.tempFontString:SetText(text)
	local width = G_RLF.tempFontString:GetStringWidth()
	return width
end

function G_RLF:TruncateItemLink(itemLink, extraWidth)
	local originalLink = itemLink .. ""
	local itemName = string.match(itemLink, "%[(.-)%]")
	local begIndex, endIndex = string.find(originalLink, itemName, 1, true)
	if begIndex == nil then
		return originalLink
	end
	local linkStart = string.sub(originalLink, 0, begIndex - 1)
	local linkEnd = string.sub(originalLink, endIndex + 1)

	local iconSize = G_RLF.db.global.sizing.iconSize
	local maxWidth = G_RLF.db.global.sizing.feedWidth - iconSize - (iconSize / 4) - (iconSize / 2) - extraWidth

	-- Calculate the width of the item name plus the link start and end
	local itemNameWidth = G_RLF:CalculateTextWidth("[" .. itemName .. "]")

	-- If the width exceeds maxWidth, truncate and add ellipses
	if itemNameWidth > maxWidth then
		-- Approximate truncation by progressively shortening the name
		while G_RLF:CalculateTextWidth("[" .. itemName .. "...]") > maxWidth and #itemName > 0 do
			itemName = string.sub(itemName, 1, -2)
		end
		itemName = itemName .. "..."
	end

	return linkStart .. itemName .. linkEnd
end

return LootDisplay
