LootDisplayRowMixin = {}

local ae = LibStub("AceEvent-3.0")
local lsm = LibStub("LibSharedMedia-3.0")

local Masque = LibStub and LibStub("Masque", true)
local iconGroup = Masque and Masque:Group(G_RLF.addonName)

local function rowBackground(row)
	local leftColor = CreateColor(unpack(G_RLF.db.global.rowBackgroundGradientStart))
	local rightColor = CreateColor(unpack(G_RLF.db.global.rowBackgroundGradientEnd))
	if not G_RLF.db.global.leftAlign then
		leftColor, rightColor = rightColor, leftColor
	end
	row.Background:SetGradient("HORIZONTAL", leftColor, rightColor)
end

local function rowIcon(row, icon)
	row.Icon:ClearAllPoints()
	row.Icon:SetSize(G_RLF.db.global.iconSize, G_RLF.db.global.iconSize)
	-- row.Icon.icon:SetSize(G_RLF.db.global.iconSize, G_RLF.db.global.iconSize)
	row.Icon.NormalTexture:SetTexture(nil)
	row.Icon.HighlightTexture:SetTexture(nil)
	row.Icon.PushedTexture:SetTexture(nil)
	row.Icon.IconBorder:SetSize(G_RLF.db.global.iconSize, G_RLF.db.global.iconSize)
	local anchor, xOffset = "LEFT", G_RLF.db.global.iconSize / 4
	if not G_RLF.db.global.leftAlign then
		anchor, xOffset = "RIGHT", -xOffset
	end
	if Masque and iconGroup then
		iconGroup:AddButton(row.Icon)
	end
	row.Icon:SetPoint(anchor, xOffset, 0)
	row.Icon:SetShown(icon ~= nil)
end

local function rowAmountText(row, icon)
	if G_RLF.db.global.useFontObjects or not G_RLF.db.global.fontFace then
		row.AmountText:SetFontObject(G_RLF.db.global.font)
	else
		local fontPath = lsm:Fetch(lsm.MediaType.FONT, G_RLF.db.global.fontFace)
		row.AmountText:SetFont(fontPath, G_RLF.db.global.fontSize, G_RLF.defaults.global.fontFlags)
	end
	local anchor = "LEFT"
	local iconAnchor = "RIGHT"
	row.AmountText:SetJustifyH("LEFT")
	local xOffset = G_RLF.db.global.iconSize / 2
	if not G_RLF.db.global.leftAlign then
		anchor = "RIGHT"
		iconAnchor = "LEFT"
		xOffset = xOffset * -1
		row.AmountText:SetJustifyH("RIGHT")
	end
	row.AmountText:ClearAllPoints()
	if icon then
		row.AmountText:SetPoint(anchor, row.Icon, iconAnchor, xOffset, 0)
	else
		row.AmountText:SetPoint(anchor, row.Icon, anchor, 0, 0)
	end
	-- Adjust the text position dynamically based on leftAlign or other conditions
end

local function updateBorderPositions(row)
	-- Adjust the Top border
	row.TopBorder:ClearAllPoints()
	row.TopBorder:SetWidth(row:GetWidth())
	row.TopBorder:SetHeight(4)
	row.TopBorder:SetTexCoord(0, 1, 1, 0)
	row.TopBorder:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 2)
	row.TopBorder:SetPoint("TOPRIGHT", row, "TOPRIGHT", 0, 2)

	-- Adjust the Left border
	row.LeftBorder:ClearAllPoints()
	row.LeftBorder:SetHeight(row:GetHeight())
	row.LeftBorder:SetWidth(4)
	row.LeftBorder:SetTexCoord(1, 0, 0, 1)
	row.LeftBorder:SetPoint("TOPLEFT", row, "TOPLEFT", -2, 0)
	row.LeftBorder:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", -2, 0)

	-- Adjust the Bottom border
	row.BottomBorder:ClearAllPoints()
	row.BottomBorder:SetWidth(row:GetWidth())
	row.BottomBorder:SetHeight(4)
	row.BottomBorder:SetTexCoord(0, 1, 0, 1)
	row.BottomBorder:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, -2)
	row.BottomBorder:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, -2)

	-- Adjust the Right border
	row.RightBorder:ClearAllPoints()
	row.RightBorder:SetHeight(row:GetHeight())
	row.RightBorder:SetWidth(4)
	row.RightBorder:SetTexCoord(0, 1, 0, 1)
	row.RightBorder:SetPoint("TOPRIGHT", row, "TOPRIGHT", 2, 0)
	row.RightBorder:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 2, 0)
end

local function rowHighlightBorder(row)
	if not row.HighlightAnimation then
		local borders = {
			row.TopBorder,
			row.RightBorder,
			row.BottomBorder,
			row.LeftBorder,
		}

		for _, b in ipairs(borders) do
			if not b.HighlightAnimation then
				b.HighlightAnimation = b:CreateAnimationGroup()
				local fadeIn = b.HighlightAnimation:CreateAnimation("Alpha")
				fadeIn:SetFromAlpha(0)
				fadeIn:SetToAlpha(1)
				fadeIn:SetDuration(0.2)

				local fadeOut = b.HighlightAnimation:CreateAnimation("Alpha")
				fadeOut:SetFromAlpha(1)
				fadeOut:SetToAlpha(0)
				fadeOut:SetDuration(0.2)
				fadeOut:SetStartDelay(0.3)
			end
		end

		row.HighlightAnimation = {}

		function row.HighlightAnimation:Stop()
			row.TopBorder.HighlightAnimation:Stop()
			row.RightBorder.HighlightAnimation:Stop()
			row.BottomBorder.HighlightAnimation:Stop()
			row.LeftBorder.HighlightAnimation:Stop()
		end

		function row.HighlightAnimation:Play()
			updateBorderPositions(row)
			row.TopBorder.HighlightAnimation:Play()
			row.RightBorder.HighlightAnimation:Play()
			row.BottomBorder.HighlightAnimation:Play()
			row.LeftBorder.HighlightAnimation:Play()
		end
	end
end

local function rowFadeOutAnimation(row)
	if not row.FadeOutAnimation then
		row.FadeOutAnimation = row:CreateAnimationGroup()
	end
	if not row.FadeOutAnimation.fadeOut then
		row.FadeOutAnimation.fadeOut = row.FadeOutAnimation:CreateAnimation("Alpha")
	end

	row.FadeOutAnimation.fadeOut:SetFromAlpha(1)
	row.FadeOutAnimation.fadeOut:SetToAlpha(0)
	row.FadeOutAnimation.fadeOut:SetDuration(1)
	row.FadeOutAnimation.fadeOut:SetStartDelay(G_RLF.db.global.fadeOutDelay)
	row.FadeOutAnimation.fadeOut:SetScript("OnFinished", function()
		row:Hide()
	end)
end

local function rowStyles(row)
	row:SetSize(G_RLF.db.global.feedWidth, G_RLF.db.global.rowHeight)
	rowBackground(row)
	rowIcon(row, row.icon)
	rowAmountText(row, row.icon)
	rowHighlightBorder(row)
	rowFadeOutAnimation(row)
end

local defaultColor = { 1, 1, 1, 1 }
function LootDisplayRowMixin:Reset()
	self:ClearAllPoints()

	-- Reset row-specific data
	self.key = nil
	self.amount = nil
	self.icon = nil
	self.link = nil

	-- Reset UI elements that were part of the template
	self.TopBorder:SetAlpha(0)
	self.RightBorder:SetAlpha(0)
	self.BottomBorder:SetAlpha(0)
	self.LeftBorder:SetAlpha(0)
	self.FadeOutAnimation:Stop()
	self.HighlightAnimation:Stop()

	-- Reset amount text behavior
	self.AmountText:SetScript("OnEnter", nil)
	self.AmountText:SetScript("OnLeave", nil)

	self.AmountText:SetTextColor(unpack(defaultColor))
end

function LootDisplayRowMixin:UpdateStyles()
	rowStyles(self)
	if self.icon and iconGroup then
		iconGroup:ReSkin(self.Icon)
	end
end

function LootDisplayRowMixin:UpdateFadeoutDelay()
	rowFadeOutAnimation(self)
end

function LootDisplayRowMixin:UpdateQuantity()
	if not G_RLF.db.global.disableRowHighlight then
		self.HighlightAnimation:Stop()
		self.HighlightAnimation:Play()
	end
	if self.FadeOutAnimation:IsPlaying() then
		self.FadeOutAnimation:Stop()
		self.FadeOutAnimation:Play()
	end
end

function LootDisplayRowMixin:SetupTooltip()
	-- Add Tooltip
	self.AmountText:SetScript("OnEnter", function()
		self.FadeOutAnimation:Stop()
		self.HighlightAnimation:Stop()
		self:ResetHighlightBorder()
		if not G_RLF.db.global.tooltip then
			return
		end
		if G_RLF.db.global.tooltipOnShift and not IsShiftKeyDown() then
			return
		end
		local inCombat = UnitAffectingCombat("player")
		if inCombat then
			GameTooltip:Hide()
			return
		end
		GameTooltip:SetOwner(self.AmountText, "ANCHOR_RIGHT")
		GameTooltip:SetHyperlink(self.link) -- Use the item's link to show the tooltip
		GameTooltip:Show()
	end)
	self.AmountText:SetScript("OnLeave", function()
		self.FadeOutAnimation:Play()
		GameTooltip:Hide()
	end)
end

function LootDisplayRowMixin:ShowText(text, r, g, b, a)
	if a == nil then
		a = 1
	end

	self.AmountText:SetText(text)

	if r == nil and g == nil and b == nil and self.amount ~= nil and self.amount < 0 then
		r, g, b, a = 1, 0, 0, 0.8
	elseif r == nil or g == nil or b == nil then
		r, g, b, a = unpack(defaultColor)
	end

	self.AmountText:SetTextColor(r, g, b, a)
end

function LootDisplayRowMixin:UpdateIcon(key, icon, quality)
	if icon then
		self.icon = icon
		if not quality then
			self.Icon:SetItem(self.link)
		else
			self.Icon:SetItemButtonTexture(icon)
			self.Icon:SetItemButtonQuality(quality, self.link)
		end
		if Masque and iconGroup then
			iconGroup:ReSkin(self.Icon)
		end
	end
end

function LootDisplayRowMixin:ResetFadeOut()
	self.FadeOutAnimation:Stop()
	self.FadeOutAnimation:Play()
end

function LootDisplayRowMixin:OnHide()
	ae:SendMessage("RLF_RowHidden", self)
end

function LootDisplayRowMixin:ResetHighlightBorder()
	self.TopBorder:SetAlpha(0)
	self.RightBorder:SetAlpha(0)
	self.BottomBorder:SetAlpha(0)
	self.LeftBorder:SetAlpha(0)
end
