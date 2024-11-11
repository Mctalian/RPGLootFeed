local addonName, G_RLF = ...

LootDisplayFrameMixin = {}

local rows = G_RLF.list()
local keyRowMap

local function getFrameHeight()
	return G_RLF.db.global.maxRows * (G_RLF.db.global.rowHeight + G_RLF.db.global.padding) - G_RLF.db.global.padding
end

local function getNumberOfRows()
	return rows.length
end

local function getPositioningDetails()
	-- Position the new row at the bottom (or top if growing down)
	local vertDir = G_RLF.db.global.growUp and "BOTTOM" or "TOP"
	local opposite = G_RLF.db.global.growUp and "TOP" or "BOTTOM"
	local yOffset = G_RLF.db.global.padding
	if not G_RLF.db.global.growUp then
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

	self.InstructionText:SetText(addonName .. "\n" .. G_RLF.L["Drag to Move"]) -- Set localized text
	self.InstructionText:Hide() -- Hide initially

	self:CreateArrowsTestArea()
end

-- Create the tab frame and anchor it to the LootDisplayFrame
function LootDisplayFrameMixin:CreateTab()
	self.tab = CreateFrame("Button", nil, UIParent, "UIPanelButtonTemplate")
	self.tab:SetSize(14, 14)
	if G_RLF.db.global.growUp then
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

-- Function to update the tab visibility based on conditions
function LootDisplayFrameMixin:UpdateTabVisibility()
	local inCombat = UnitAffectingCombat("player")
	local hasItems = getNumberOfRows() > 0
	local isEnabled = G_RLF.db.global.lootHistoryEnabled

	if not inCombat and not hasItems and isEnabled then
		self.tab:Show()
	else
		self.tab:Hide()
		self:HideHistoryFrame()
	end
end

function LootDisplayFrameMixin:Load()
	keyRowMap = {
		length = 0,
	}
	self.rowHistory = {}
	self.rowFramePool = CreateFramePool("Frame", self, "LootDisplayRowTemplate", function(pool, row)
		row:Reset()
		row:SetParent(self)
	end)
	self.vertDir, self.opposite, self.yOffset = getPositioningDetails()
	self:UpdateSize()
	self:SetPoint(
		G_RLF.db.global.anchorPoint,
		_G[G_RLF.db.global.relativePoint],
		G_RLF.db.global.xOffset,
		G_RLF.db.global.yOffset
	)

	self:SetFrameStrata(G_RLF.db.global.frameStrata) -- Set the frame strata here

	self:ConfigureTestArea()
	self:CreateTab()
end

function LootDisplayFrameMixin:ClearFeed()
	local row = rows.last

	while row do
		local oldRow = row
		row = row._prev
		oldRow.FadeOutAnimation:Stop()
		oldRow:Hide()
		self:ReleaseRow(oldRow)
	end
end

function LootDisplayFrameMixin:UpdateSize()
	self:SetSize(G_RLF.db.global.feedWidth, getFrameHeight())

	for row in rows:iterate() do
		row:UpdateStyles()
	end
end

function LootDisplayFrameMixin:UpdateFadeDelay()
	for row in rows:iterate() do
		row:UpdateFadeoutDelay()
	end
end

function LootDisplayFrameMixin:OnDragStop()
	self:StopMovingOrSizing()

	-- Save the new position
	local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
	G_RLF.db.global.anchorPoint = point
	G_RLF.db.global.relativePoint = relativeTo or -1
	G_RLF.db.global.xOffset = xOfs
	G_RLF.db.global.yOffset = yOfs

	-- Update the frame position
	G_RLF.LootDisplay:UpdatePosition()
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
	self:RegisterForDrag("")
end

function LootDisplayFrameMixin:GetRow(key)
	return keyRowMap[key]
end

function LootDisplayFrameMixin:LeaseRow(key)
	if getNumberOfRows() >= G_RLF.db.global.maxRows then
		-- Skip this, we've already allocated too much
		return nil
	end

	local row = self.rowFramePool:Acquire()

	row.key = key

	local success = rows:push(row)
	if not success then
		error("Tried to push a row that already exists in the list")
	end

	keyRowMap[key] = row
	keyRowMap.length = keyRowMap.length + 1

	row:SetPosition(self)
	RunNextFrame(function()
		row:ResetHighlightBorder()
		row:Show()
	end)
	self:UpdateTabVisibility()

	return row
end

function LootDisplayFrameMixin:ReleaseRow(row)
	if not row.key then
		error("Row without key: " .. row:Dump())
	end

	if keyRowMap[row.key] then
		keyRowMap[row.key] = nil
		keyRowMap.length = keyRowMap.length - 1
	end

	self:StoreRowHistory(row)

	row:UpdateNeighborPositions(self)
	rows:remove(row)
	row:SetParent(nil)

	self.rowFramePool:Release(row)
	self:OnRowRelease()
	self:UpdateTabVisibility()
end

function LootDisplayFrameMixin:StoreRowHistory(row)
	if not G_RLF.db.global.lootHistoryEnabled then
		return
	end

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
	}
	table.insert(self.rowHistory, 1, rowData)

	-- Trim the history to the configured limit
	if #self.rowHistory > G_RLF.db.global.historyLimit then
		table.remove(self.rowHistory) -- Remove the oldest entry to maintain the limit
	end
end

function LootDisplayFrameMixin:Dump()
	local firstKey, lastKey
	if rows.first then
		firstKey = rows.first.key or "NONE"
	else
		firstKey = "first nil"
	end

	if rows.last then
		lastKey = rows.last.key or "NONE"
	else
		lastKey = "last nil"
	end

	local children = { self:GetChildren() }
	local childrenLog = "["
	for i, r in ipairs(children) do
		if i > 0 then
			childrenLog = childrenLog .. ", "
		end
		childrenLog = childrenLog .. r:Dump()
	end
	childrenLog = childrenLog .. "]"

	return format(
		"{getNumberOfRows=%s,#rowFramePool=%s,#keyRowMap=%s,first.key=%s,last.key=%s,frame.children=%s}",
		getNumberOfRows(),
		self.rowFramePool:size(),
		keyRowMap.length,
		firstKey,
		lastKey,
		childrenLog
	)
end

function LootDisplayFrameMixin:UpdateRowPositions()
	self.vertDir, self.opposite, self.yOffset = getPositioningDetails()
	local index = 1
	for row in rows:iterate() do
		row:SetPosition(self)
		if index > getNumberOfRows() + 2 then
			error("Possible infinite loop detected!: " .. self:Dump())
		end
		index = index + 1
	end
end

function LootDisplayFrameMixin:CreateHistoryFrame()
	self.historyFrame = CreateFrame("ScrollFrame", "LootHistoryFrame", UIParent, "UIPanelScrollFrameTemplate")
	self.historyFrame:SetSize(self:GetSize())
	self.historyFrame:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)

	self.historyContent = CreateFrame("Frame", "LootHistoryFrameContent", self.historyFrame)
	self.historyContent:SetSize(self:GetSize())
	self.historyFrame:SetScrollChild(self.historyContent)

	self.historyRows = {}
	for i = 1, G_RLF.db.global.maxRows do
		local row = CreateFrame("Frame", nil, self.historyContent, "LootDisplayRowTemplate")
		row:SetSize(G_RLF.db.global.feedWidth, G_RLF.db.global.rowHeight)
		table.insert(self.historyRows, row)
	end

	self.historyFrame:SetScript("OnVerticalScroll", function(_, offset)
		self:UpdateHistoryFrame(offset)
	end)
end

function LootDisplayFrameMixin:UpdateHistoryFrame(offset)
	offset = offset or 0
	local rowHeight = G_RLF.db.global.rowHeight + G_RLF.db.global.padding
	local visibleRows = G_RLF.db.global.maxRows
	local totalRows = #self.rowHistory
	local contentSize = totalRows * rowHeight - G_RLF.db.global.padding
	local startIndex = math.floor(offset / rowHeight) + 1
	local endIndex = math.min(startIndex + visibleRows - 1, totalRows)

	for i, row in ipairs(self.historyRows) do
		local dataIndex = startIndex + i - 1
		if dataIndex <= endIndex then
			row:UpdateWithHistoryData(self.rowHistory[dataIndex])
			row:Show()
			row:ClearAllPoints()
			row:SetPoint("TOPLEFT", self.historyFrame, "TOPLEFT", 0, (i - 1) * -rowHeight)
		else
			row:Hide()
		end
	end

	self.historyFrame:SetSize(G_RLF.db.global.feedWidth, getFrameHeight() + rowHeight)
	self.historyContent:SetSize(G_RLF.db.global.feedWidth, contentSize)
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

function LootDisplayFrameMixin:HideHistoryFrame()
	if self.historyFrame then
		self.historyFrame:Hide()
		self.historyFrame:SetVerticalScroll(0)
	end
end
