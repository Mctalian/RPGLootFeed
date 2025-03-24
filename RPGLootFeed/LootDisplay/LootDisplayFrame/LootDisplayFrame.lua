---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

---@class RLF_LootDisplayFrame: Frame
---@field BoundingBox Texture
---@field InstructionText FontString
---@field ArrowUp Texture
---@field ArrowDown Texture
---@field ArrowLeft Texture
---@field ArrowRight Texture
LootDisplayFrameMixin = {}

function LootDisplayFrameMixin:getFrameHeight()
	local sizingDb = G_RLF.DbAccessor:Sizing(self.frameType)
	local padding = sizingDb.padding
	return sizingDb.maxRows * (sizingDb.rowHeight + padding) - padding
end

function LootDisplayFrameMixin:getNumberOfRows()
	return self.rows.length
end

function LootDisplayFrameMixin:getPositioningDetails()
	local stylingDb = G_RLF.DbAccessor:Styling(self.frameType)
	local growUp = stylingDb.growUp
	-- Position the new row at the bottom (or top if growing down)
	local vertDir = growUp and "BOTTOM" or "TOP"
	local opposite = growUp and "TOP" or "BOTTOM"
	local sizingDb = G_RLF.DbAccessor:Sizing(self.frameType)
	local yOffset = sizingDb.padding
	if not growUp then
		yOffset = -yOffset
	end

	return vertDir, opposite, yOffset
end

local function configureArrowRotation(arrow, direction)
	if direction == "UP" then
		arrow:SetRotation(0)
	elseif direction == "DOWN" then
		arrow:SetRotation(math.pi)
	elseif direction == "LEFT" then
		arrow:SetRotation(math.pi * 0.5)
	elseif direction == "RIGHT" then
		arrow:SetRotation(math.pi * 1.5)
	end
end

function LootDisplayFrameMixin:CreateArrowsTestArea()
	if not self.arrows then
		self.arrows = { self.ArrowUp, self.ArrowDown, self.ArrowLeft, self.ArrowRight }

		-- Set arrow rotations
		configureArrowRotation(self.ArrowUp, "UP")
		configureArrowRotation(self.ArrowDown, "DOWN")
		configureArrowRotation(self.ArrowLeft, "LEFT")
		configureArrowRotation(self.ArrowRight, "RIGHT")

		-- Hide arrows initially
		for _, arrow in ipairs(self.arrows) do
			arrow:Hide()
		end
	end
end

function LootDisplayFrameMixin:ConfigureTestArea()
	self.BoundingBox:Hide() -- Hide initially

	self:MakeUnmovable()

	local firstLine = addonName
	if self.frameType == G_RLF.Frames.PARTY then
		firstLine = firstLine .. " " .. G_RLF.L["Party Loot"]
	end
	self.InstructionText:SetText(firstLine .. "\n" .. G_RLF.L["Drag to Move"]) -- Set localized text
	self.InstructionText:Hide() -- Hide initially

	self:CreateArrowsTestArea()
end

-- Create the tab frame and anchor it to the loot frame
function LootDisplayFrameMixin:CreateTab()
	self.tab = CreateFrame("Button", nil, UIParent, "UIPanelButtonTemplate") --[[@as Button]]
	self.tab:SetSize(14, 14)
	local stylingDb = G_RLF.DbAccessor:Styling(self.frameType)
	if stylingDb.growUp then
		self.tab:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", -14, 0)
	else
		self.tab:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
	end
	self.tab:SetAlpha(0.2)
	self.tab:Hide()

	-- self.tab:SetText("History")
	-- Add an icon to the button
	local icon = self.tab:CreateTexture(nil, "ARTWORK")
	icon:SetTexture("Interface\\Icons\\INV_Misc_Book_09") -- Replace with the desired icon path
	icon:SetAllPoints(self.tab)

	-- Handle mouse enter and leave events to change alpha
	self.tab:SetScript("OnEnter", function()
		self.tab:SetAlpha(1.0)
		GameTooltip:SetOwner(self.tab, "ANCHOR_RIGHT")
		GameTooltip:SetText(G_RLF.L["Toggle Loot History"], 1, 1, 1)
		GameTooltip:Show()
	end)
	self.tab:SetScript("OnLeave", function()
		self.tab:SetAlpha(0.2)
		GameTooltip:Hide()
	end)

	-- Handle click event to show the history frame
	self.tab:SetScript("OnClick", function()
		self:ToggleHistoryFrame()
	end)
end

--- Function to update the loot history tab visibility
function LootDisplayFrameMixin:UpdateTabVisibility()
	local inCombat = UnitAffectingCombat("player")
	local hasItems = self:getNumberOfRows() > 0
	local isEnabled = G_RLF.db.global.lootHistory.enabled
	local hideTab = G_RLF.db.global.lootHistory.hideTab

	if not inCombat and not hasItems and isEnabled then
		self.tab:Show()
	else
		self:HideHistoryFrame()
	end

	if hideTab then
		self.tab:Hide()
	end
end

--- Load the loot display frame
--- @param frame? G_RLF.Frames
function LootDisplayFrameMixin:Load(frame)
	self.frameType = frame or G_RLF.Frames.MAIN
	---@type list<RLF_LootDisplayRow>
	self.rows = G_RLF.list()
	---@type table<string, RLF_LootDisplayRow | integer>
	self.keyRowMap = {
		---@type integer
		length = 0,
	}
	---@type RLF_LootHistoryRowData[]
	self.rowHistory = {}
	self.rowFramePool = CreateFramePool("Frame", self, "LootDisplayRowTemplate")
	self.vertDir, self.opposite, self.yOffset = self:getPositioningDetails()
	local positioningDb = G_RLF.DbAccessor:Positioning(self.frameType)
	self:UpdateSize()
	self:SetPoint(
		positioningDb.anchorPoint,
		_G[positioningDb.relativePoint],
		positioningDb.xOffset,
		positioningDb.yOffset
	)

	self:SetFrameStrata(positioningDb.frameStrata) -- Set the frame strata here

	self:ConfigureTestArea()
	self:CreateTab()
end

function LootDisplayFrameMixin:ClearFeed()
	local row = self.rows.last

	while row do
		local oldRow = row
		row = row._prev
		oldRow.ExitAnimation:Stop()
		oldRow:Hide()
		self:ReleaseRow(oldRow)
	end
end

function LootDisplayFrameMixin:UpdateSize()
	local sizingDb = G_RLF.DbAccessor:Sizing(self.frameType)
	self:SetSize(sizingDb.feedWidth, self:getFrameHeight())

	for row in self.rows:iterate() do
		row:UpdateStyles()
	end
end

function LootDisplayFrameMixin:UpdateFadeDelay()
	for row in self.rows:iterate() do
		row:UpdateFadeoutDelay()
	end
end

function LootDisplayFrameMixin:UpdateEnterAnimationType()
	for row in self.rows:iterate() do
		row:UpdateEnterAnimation()
	end
end

function LootDisplayFrameMixin:OnDragStop()
	self:StopMovingOrSizing()

	-- Save the new position
	local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
	local positioningDb = G_RLF.DbAccessor:Positioning(self.frameType)
	positioningDb.anchorPoint = point
	positioningDb.relativePoint = relativeTo or "UIParent"
	positioningDb.xOffset = xOfs
	positioningDb.yOffset = yOfs

	-- Update the frame position
	G_RLF.LootDisplay:UpdatePosition(self.frameType)
	G_RLF:NotifyChange(addonName)
end

function LootDisplayFrameMixin:ShowTestArea()
	self.BoundingBox:Show()
	self:RegisterForDrag("LeftButton")
	self:SetMovable(true)
	self:EnableMouse(true)
	self.InstructionText:Show()
	for i, a in ipairs(self.arrows) do
		a:Show()
	end
end

function LootDisplayFrameMixin:HideTestArea()
	self.BoundingBox:Hide()
	self:MakeUnmovable()
	self.InstructionText:Hide()
	for i, a in ipairs(self.arrows) do
		a:Hide()
	end
end

function LootDisplayFrameMixin:MakeUnmovable()
	self:SetMovable(false)
	self:EnableMouse(false)
	self:RegisterForDrag()
end

--- Get row from key
--- @param key string
--- @return RLF_LootDisplayRow
function LootDisplayFrameMixin:GetRow(key)
	if key == "length" then
		error("Attempted to access key 'length' from GetRow")
	end
	return self.keyRowMap[key] --[[@as RLF_LootDisplayRow]]
end

function LootDisplayFrameMixin:LeaseRow(key)
	local sizingDb = G_RLF.DbAccessor:Sizing(self.frameType)
	if self:getNumberOfRows() >= sizingDb.maxRows then
		-- Skip this, we've already allocated too much
		return nil
	end

	---@type RLF_LootDisplayRow
	local row = self.rowFramePool:Acquire()
	row.frameType = self.frameType
	row.key = key
	RunNextFrame(function()
		row:Hide()
	end)

	local success = self.rows:push(row)
	if not success then
		error("Tried to push a row that already exists in the list")
	end

	row:Init()
	row:SetParent(self)

	self.keyRowMap[key] = row
	self.keyRowMap.length = self.keyRowMap.length + 1

	row:UpdatePosition(self)
	RunNextFrame(function()
		row:ResetHighlightBorder()
	end)
	self:UpdateTabVisibility()

	return row
end

function LootDisplayFrameMixin:ReleaseRow(row)
	if not row.key then
		error("Row without key: " .. row:Dump())
	end

	if self.keyRowMap[row.key] then
		self.keyRowMap[row.key] = nil
		self.keyRowMap.length = self.keyRowMap.length - 1
	end

	self:StoreRowHistory(row)

	row:UpdateNeighborPositions(self)
	self.rows:remove(row)
	row:SetParent(nil)
	row.key = nil
	row:Reset()
	self.rowFramePool:Release(row)
	if self.frameType == G_RLF.Frames.MAIN then
		G_RLF:SendMessage("RLF_ROW_RETURNED")
	else
		G_RLF:SendMessage("RLF_PARTY_ROW_RETURNED")
	end
	self:UpdateTabVisibility()
end

function LootDisplayFrameMixin:StoreRowHistory(row)
	if not G_RLF.db.global.lootHistory.enabled then
		return
	end

	---@class RLF_LootHistoryRowData
	local rowData = {
		key = row.key,
		amount = row.amount,
		quality = row.quality,
		icon = row.icon,
		link = row.link,
		rowText = row.PrimaryText:GetText(),
		textColor = { row.PrimaryText:GetTextColor() },
		unit = row.unit,
		secondaryText = row.SecondaryText:GetText(),
		secondaryTextColor = { row.SecondaryText:GetTextColor() },
	}
	table.insert(self.rowHistory, 1, rowData)

	-- Trim the history to the configured limit
	if #self.rowHistory > G_RLF.db.global.lootHistory.historyLimit then
		table.remove(self.rowHistory) -- Remove the oldest entry to maintain the limit
	end
end

function LootDisplayFrameMixin:Dump()
	local firstKey, lastKey
	if self.rows.first then
		firstKey = self.rows.first.key or "NONE"
	else
		firstKey = "first nil"
	end

	if self.rows.last then
		lastKey = self.rows.last.key or "NONE"
	else
		lastKey = "last nil"
	end

	return format(
		"{getNumberOfRows=%s,#rowFramePool=%s,#keyRowMap=%s,first.key=%s,last.key=%s}",
		self:getNumberOfRows(),
		self.rowFramePool:size(),
		self.keyRowMap.length,
		firstKey,
		lastKey
	)
end

function LootDisplayFrameMixin:UpdateRowPositions()
	self.vertDir, self.opposite, self.yOffset = self:getPositioningDetails()
	local index = 1
	for row in self.rows:iterate() do
		row:UpdatePosition(self)
		if index > self:getNumberOfRows() + 2 then
			error("Possible infinite loop detected!: " .. self:Dump())
		end
		index = index + 1
	end
end

function LootDisplayFrameMixin:CreateHistoryFrame()
	self.historyFrame = CreateFrame("ScrollFrame", "LootHistoryFrame", UIParent, "UIPanelScrollFrameTemplate")
	self.historyFrame:SetSize(self:GetSize())
	self.historyFrame:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
	self.historyFrame.title = self.historyFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	self.historyFrame.title:SetPoint("BOTTOMLEFT", self.historyFrame, "TOPLEFT", 0, 0)
	if self.frameType == G_RLF.Frames.PARTY then
		self.historyFrame.title:SetText(G_RLF.L["Party Loot History"] --[[@as string]])
	else
		self.historyFrame.title:SetText(G_RLF.L["Loot History"] --[[@as string]])
	end

	self.historyContent = CreateFrame("Frame", "LootHistoryFrameContent", self.historyFrame)
	self.historyContent:SetSize(self:GetSize())
	self.historyFrame:SetScrollChild(self.historyContent)

	---@type RLF_LootDisplayRow[]
	self.historyRows = {}
	local sizingDb = G_RLF.DbAccessor:Sizing(self.frameType)
	for i = 1, sizingDb.maxRows do
		local row = CreateFrame("Frame", nil, self.historyContent, "LootDisplayRowTemplate")
		row:SetSize(sizingDb.feedWidth, sizingDb.rowHeight)
		table.insert(self.historyRows, row)
	end

	self.historyFrame:SetScript("OnVerticalScroll", function(_, offset)
		self:UpdateHistoryFrame(offset)
	end)
end

function LootDisplayFrameMixin:UpdateHistoryFrame(offset)
	offset = offset or 0
	---@type RLF_ConfigSizing
	local sizingDb = G_RLF.DbAccessor:Sizing(self.frameType)
	local padding = sizingDb.padding
	local feedWidth = sizingDb.feedWidth
	local rowHeight = sizingDb.rowHeight + padding
	local visibleRows = sizingDb.maxRows
	local totalRows = #self.rowHistory
	local contentSize = totalRows * rowHeight - padding
	local startIndex = math.floor(offset / rowHeight) + 1
	local endIndex = math.min(startIndex + visibleRows - 1, totalRows)

	for i, row in ipairs(self.historyRows) do
		local dataIndex = startIndex + i - 1
		if dataIndex <= endIndex then
			row:UpdateWithHistoryData(self.rowHistory[dataIndex])
			row:Show()
			row:ElementsVisible()
			row:ClearAllPoints()
			row:SetPoint("TOPLEFT", self.historyFrame, "TOPLEFT", 0, (i - 1) * -rowHeight)
		else
			row:Hide()
		end
	end

	self.historyFrame:SetSize(feedWidth, self:getFrameHeight() + rowHeight)
	self.historyContent:SetSize(feedWidth, contentSize)
end

function LootDisplayFrameMixin:ToggleHistoryFrame()
	if not self.historyFrame or not self.historyFrame:IsVisible() then
		self:ShowHistoryFrame()
	else
		self:HideHistoryFrame()
	end
end

function LootDisplayFrameMixin:ShowHistoryFrame()
	if not self.historyFrame then
		self:CreateHistoryFrame()
	end
	self:UpdateHistoryFrame()
	self.historyFrame:Show()
end

function LootDisplayFrameMixin:HideHistoryFrame(otherFrame)
	if self.tab then
		self.tab:Hide()
	end
	if self.historyFrame then
		self.historyFrame:Hide()
		self.historyFrame:SetVerticalScroll(0)
	end

	if otherFrame then
		return
	end

	if self.frameType == G_RLF.Frames.MAIN then
		local partyFrame = G_RLF.RLF_PartyLootFrame
		if partyFrame then
			partyFrame:HideHistoryFrame(true)
		end
	else
		local mainFrame = G_RLF.RLF_MainLootFrame
		if mainFrame then
			mainFrame:HideHistoryFrame(true)
		end
	end
end

function LootDisplayFrameMixin:UpdateRowItemCounts()
	for row in self.rows:iterate() do
		if row.id and row.type == "ItemLoot" and not row.unit then
			row:UpdateItemCount(row)
		end
	end
end
