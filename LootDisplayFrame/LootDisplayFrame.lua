LootDisplayFrameMixin = {}

local acr = LibStub("AceConfigRegistry-3.0")

local function getFrameHeight()
	return G_RLF.db.global.maxRows * (G_RLF.db.global.rowHeight + G_RLF.db.global.padding) - G_RLF.db.global.padding
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

function LootDisplayFrameMixin:UpdateSize()
	self:SetSize(G_RLF.db.global.feedWidth, getFrameHeight())
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
	self:SetMovable(true)
	self:EnableMouse(true)
	self.InstructionText:Show()
	for i, a in ipairs(self.arrows) do
		a:Show()
	end
end

function LootDisplayFrameMixin:HideTestArea()
	self.BoundingBox:Hide()
	self:SetMovable(false)
	self:EnableMouse(false)
	self.BoundingBox.instructionText:Hide()
	for i, a in ipairs(self.arrows) do
		a:Hide()
	end
end
