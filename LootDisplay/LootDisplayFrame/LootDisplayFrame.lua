local addonName, G_RLF = ...

LootDisplayFrameMixin = {}

local rows = G_RLF.list()
local keyRowMap
local rowFramePool = G_RLF.Queue:new()

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

local function configureTestArea(self)
	self.BoundingBox:Hide() -- Hide initially

	self:MakeUnmovable()

	self.InstructionText:SetText(addonName .. "\n" .. G_RLF.L["Drag to Move"]) -- Set localized text
	self.InstructionText:Hide() -- Hide initially

	createArrowsTestArea(self)
end

function LootDisplayFrameMixin:Load()
	keyRowMap = {
		length = 0,
	}
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
	local row
	if rowFramePool:size() == 0 then
		-- Create a new row from the XML template
		row = CreateFrame("Frame", nil, self, "LootDisplayRowTemplate")
	else
		-- Reuse an existing row from the pool
		row = rowFramePool:dequeue()
		row:Reset()
	end
	row:SetParent(self)
	row.key = key
	local success = rows:push(row)
	if not success then
		error("Tried to push a row that already exists in the list")
	end
	keyRowMap[key] = row
	keyRowMap.length = keyRowMap.length + 1

	row:SetPosition(self)

	return row
end

function LootDisplayFrameMixin:CheckForStragglers()
	if getNumberOfRows() == 0 then
		local r = {}
		local children = { self:GetChildren() }
		for i, v in ipairs(children) do
			if v:IsShown() then
				tinsert(r, v)
			end
		end

		if #r > 0 then
			local keys = "["
			for i, k in ipairs(r) do
				if i > 1 then
					keys = keys .. ", "
				end
				keys = keys .. k.key
				r:Hide()
			end
			keys = keys .. "]"
			error(
				getNumberOfRows()
					.. " tracked rows, but still found "
					.. #r
					.. " row(s) as frame child(ren): "
					.. keys
					.. "\n\n"
					.. self:Dump()
			)
		end
	end
end

function LootDisplayFrameMixin:ReleaseRow(row)
	if row.key then
		if keyRowMap[row.key] then
			keyRowMap[row.key] = nil
			keyRowMap.length = keyRowMap.length - 1
		end
	else
		error("Row without key: " .. row:Dump())
	end
	row:UpdateNeighborPositions(self)
	rows:remove(row)
	row:SetParent(nil)
	row:Reset(true)
	rowFramePool:enqueue(row)
	self:OnRowRelease()
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
		rowFramePool:size(),
		keyRowMap.length,
		firstKey,
		lastKey,
		childrenLog
	)
end

function LootDisplayFrameMixin:UpdateRowPositions()
	local index = 1
	for row in rows:iterate() do
		row:SetPosition(self)
		if index > getNumberOfRows() + 2 then
			error("Possible infinite loop detected!: " .. self:Dump())
		end
		index = index + 1
	end
end
