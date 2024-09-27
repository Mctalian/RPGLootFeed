LootDisplayFrameMixin = {}

local acr = LibStub("AceConfigRegistry-3.0")
local ae = LibStub("AceEvent-3.0")

local rows = G_RLF.list()
local keyRowMap = {}
local rowFramePool = {}

local function getFrameHeight()
	return G_RLF.db.global.maxRows * (G_RLF.db.global.rowHeight + G_RLF.db.global.padding) - G_RLF.db.global.padding
end

local function getNumberOfRows()
	return rows.length
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

local function createArrowsTestArea(self)
	if not self.arrows then
		self.arrows = {
			self.ArrowUp,
			self.ArrowDown,
			self.ArrowLeft,
			self.ArrowRight,
		}

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

local function configureTestArea(self)
	self.BoundingBox:Hide() -- Hide initially

	self:MakeUnmovable()

	self.InstructionText:SetText(G_RLF.addonName .. "\n" .. G_RLF.L["Drag to Move"]) -- Set localized text
	self.InstructionText:Hide() -- Hide initially

	createArrowsTestArea(self)
end

function LootDisplayFrameMixin:Load()
	self:UpdateSize()
	self:SetPoint(
		G_RLF.db.global.anchorPoint,
		_G[G_RLF.db.global.relativePoint],
		G_RLF.db.global.xOffset,
		G_RLF.db.global.yOffset
	)

	self:SetFrameStrata(G_RLF.db.global.frameStrata) -- Set the frame strata here

	configureTestArea(self)
end

function LootDisplayFrameMixin:ClearFeed()
	local row = rows.last

	while row do
		local oldRow = row
		row = row._prev
		oldRow.FadeOutAnimation:Stop()
		oldRow:Hide()
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
	acr:NotifyChange(G_RLF.addonName)
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
	local row
	if #rowFramePool == 0 then
		-- Create a new row from the XML template
		row = CreateFrame("Frame", nil, self, "LootDisplayRowTemplate")
	else
		-- Reuse an existing row from the pool
		row = tremove(rowFramePool)
		row:Reset()
	end

	-- Assign the key to the row
	row.key = key
	keyRowMap[key] = row

	-- Add the row to the rows list and show it
	rows:push(row)

	-- Position the new row at the bottom (or top if growing up)
	if getNumberOfRows() == 1 then
		local vertDir = G_RLF.db.global.growUp and "BOTTOM" or "TOP"
		row:SetPoint(vertDir, self, vertDir)
		row:Show()
	else
		ae:SendMessage("RLF_LootDisplay_UpdateRowPositions")
	end

	return row
end

function LootDisplayFrameMixin:ReleaseRow(row)
	rows:remove(row)
	keyRowMap[row.key] = nil
	tinsert(rowFramePool, row)
	ae:SendMessage("RLF_LootDisplay_RowReturned")
	ae:SendMessage("RLF_LootDisplay_UpdateRowPositions")
end

function LootDisplayFrameMixin:UpdateRowPositions()
	local index = 0
	for row in rows:iterate() do
		if not row:IsFading() then
			row:ClearAllPoints()
			local vertDir = "BOTTOM"
			local yOffset = index * (G_RLF.db.global.rowHeight + G_RLF.db.global.padding)
			if not G_RLF.db.global.growUp then
				vertDir = "TOP"
				yOffset = yOffset * -1
			end
			row:SetPoint(vertDir, self, vertDir, 0, yOffset)
			row:UpdateStyles()
			index = index + 1
			row:Show()
		end
	end
end
