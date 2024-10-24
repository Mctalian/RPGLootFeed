local addonName, G_RLF = ...

LootDisplayRowMixin = {}

local function rowBackground(row)
	local changed = false
	if
		row.cachedGradientStart ~= G_RLF.db.global.rowBackgroundGradientStart
		or row.cachedGradientEnd ~= G_RLF.db.global.rowBackgroundGradientEnd
	then
		row.cachedGradientStart = G_RLF.db.global.rowBackgroundGradientStart
		row.cachedGradientEnd = G_RLF.db.global.rowBackgroundGradientEnd
		changed = true
	end

	if row.cachedBackgoundLeftAlign ~= G_RLF.db.global.leftAlign then
		row.cachedBackgoundLeftAlign = G_RLF.db.global.leftAlign
		changed = true
	end

	if changed then
		local leftColor = CreateColor(unpack(G_RLF.db.global.rowBackgroundGradientStart))
		local rightColor = CreateColor(unpack(G_RLF.db.global.rowBackgroundGradientEnd))
		if not G_RLF.db.global.leftAlign then
			leftColor, rightColor = rightColor, leftColor
		end
		row.Background:SetGradient("HORIZONTAL", leftColor, rightColor)
	end
end

local function rowIcon(row, icon)
	local changed = false
	if row.cachedIconSize ~= G_RLF.db.global.iconSize then
		row.cachedIconSize = G_RLF.db.global.iconSize
		changed = true
	end

	if row.cachedIconLeftAlign ~= G_RLF.db.global.leftAlign then
		row.cachedIconLeftAlign = G_RLF.db.global.leftAlign
		changed = true
	end

	if changed then
		row.Icon:ClearAllPoints()
		row.Icon:SetSize(G_RLF.db.global.iconSize, G_RLF.db.global.iconSize)
		row.Icon.IconBorder:SetSize(G_RLF.db.global.iconSize, G_RLF.db.global.iconSize)
		row.Icon.NormalTexture:SetTexture(nil)
		row.Icon.HighlightTexture:SetTexture(nil)
		row.Icon.PushedTexture:SetTexture(nil)
		local anchor, xOffset = "LEFT", G_RLF.db.global.iconSize / 4
		if not G_RLF.db.global.leftAlign then
			anchor, xOffset = "RIGHT", -xOffset
		end
		if G_RLF.Masque and G_RLF.iconGroup then
			G_RLF.iconGroup:AddButton(row.Icon)
		end
		row.Icon:SetPoint(anchor, xOffset, 0)
	end
	row.Icon:SetShown(icon ~= nil)
end

local function rowUnitPortrait(row)
	if row.unit then
		SetPortraitTexture(row.UnitPortrait, row.unit)
		local portraitSize = G_RLF.db.global.iconSize * 0.8
		row.UnitPortrait:SetSize(portraitSize, portraitSize)
		row.UnitPortrait:ClearAllPoints()
		local anchor, iconAnchor, xOffset = "LEFT", "RIGHT", G_RLF.db.global.iconSize / 4
		if not G_RLF.db.global.leftAlign then
			anchor, iconAnchor, xOffset = "RIGHT", "LEFT", -xOffset
		end

		row.UnitPortrait:SetPoint(anchor, row.Icon, iconAnchor, xOffset, 0)
		row.UnitPortrait:Show()
	else
		row.UnitPortrait:Hide()
	end
end

local function rowText(row, icon)
	local fontChanged = false
	if
		row.cachedFontFace ~= G_RLF.db.global.fontFace
		or row.cachedFontSize ~= G_RLF.db.global.fontSize
		or row.cachedSecondaryFontSize ~= G_RLF.db.global.secondaryFontSize
		or row.cachedFontFlags ~= G_RLF.defaults.global.fontFlags
	then
		row.cachedFontFace = G_RLF.db.global.fontFace
		row.cachedFontSize = G_RLF.db.global.fontSize
		row.cachedSecondaryFontSize = G_RLF.db.global.secondaryFontSize
		row.cachedFontFlags = G_RLF.defaults.global.fontFlags
		fontChanged = true
	end

	if row.cachedUseFontObject ~= G_RLF.db.global.useFontObjects then
		row.cachedUseFontObject = G_RLF.db.global.useFontObjects
		fontChanged = true
	end

	if fontChanged then
		if G_RLF.db.global.useFontObjects or not G_RLF.db.global.fontFace then
			row.PrimaryText:SetFontObject(G_RLF.db.global.font)
			row.SecondaryText:SetFontObject(G_RLF.db.global.font)
		else
			local fontPath = G_RLF.lsm:Fetch(G_RLF.lsm.MediaType.FONT, G_RLF.db.global.fontFace)
			row.PrimaryText:SetFont(fontPath, G_RLF.db.global.fontSize, G_RLF.defaults.global.fontFlags)
			row.SecondaryText:SetFont(fontPath, G_RLF.db.global.secondaryFontSize, G_RLF.defaults.global.fontFlags)
		end
	end

	if
		row.cachedRowTextLeftAlign ~= G_RLF.db.global.leftAlign
		or row.cachedRowTextXOffset ~= G_RLF.db.global.iconSize / 4
		or row.cachedRowTextIcon ~= icon
		or row.cachedEnabledSecondaryText ~= G_RLF.db.global.enabledSecondaryRowText
		or row.cachedSecondaryText ~= row.secondaryText
		or row.cachedUnit ~= row.unit
	then
		row.cachedRowTextLeftAlign = G_RLF.db.global.leftAlign
		row.cachedRowTextXOffset = G_RLF.db.global.iconSize / 4
		row.cachedRowTextIcon = icon
		row.cachedEnabledSecondaryText = G_RLF.db.global.enabledSecondaryRowText
		row.cachedSecondaryText = row.secondaryText
		row.cachedUnit = row.unit

		local anchor = "LEFT"
		local iconAnchor = "RIGHT"
		local xOffset = G_RLF.db.global.iconSize / 4
		if not G_RLF.db.global.leftAlign then
			anchor = "RIGHT"
			iconAnchor = "LEFT"
			xOffset = xOffset * -1
		end
		row.PrimaryText:ClearAllPoints()
		row.PrimaryText:SetJustifyH(anchor)
		if icon then
			if row.unit then
				row.PrimaryText:SetPoint(anchor, row.UnitPortrait, iconAnchor, xOffset, 0)
			else
				row.PrimaryText:SetPoint(anchor, row.Icon, iconAnchor, xOffset, 0)
			end
		else
			row.PrimaryText:SetPoint(anchor, row.Icon, anchor, 0, 0)
		end

		if G_RLF.db.global.enabledSecondaryRowText and row.secondaryText ~= nil and row.secondaryText ~= "" then
			row.SecondaryText:ClearAllPoints()
			row.SecondaryText:SetJustifyH(anchor)
			if icon then
				if row.unit then
					row.SecondaryText:SetPoint(anchor, row.UnitPortrait, iconAnchor, xOffset, 0)
				else
					row.SecondaryText:SetPoint(anchor, row.Icon, iconAnchor, xOffset, 0)
				end
			else
				row.SecondaryText:SetPoint(anchor, row.Icon, anchor, 0, 0)
			end
			local padding = G_RLF.db.global.padding
			row.PrimaryText:SetPoint("BOTTOM", row, "CENTER", 0, padding)
			row.SecondaryText:SetPoint("TOP", row, "CENTER", 0, -padding)
			row.SecondaryText:SetShown(true)
		end
	end
	-- Adjust the text position dynamically based on leftAlign or other conditions
end

local function updateBorderPositions(row)
	if row.borderCachedWidth ~= row:GetWidth() or row.borderCachedHeight ~= row:GetHeight() then
		row.borderCachedWidth = row:GetWidth()
		row.borderCachedHeight = row:GetHeight()
	else
		return
	end
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
				fadeOut:SetScript("OnFinished", function()
					row:ResetHighlightBorder()
				end)
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
		row.FadeOutAnimation.fadeOut:SetFromAlpha(1)
		row.FadeOutAnimation.fadeOut:SetToAlpha(0)
		row.FadeOutAnimation.fadeOut:SetDuration(1)
		row.FadeOutAnimation.fadeOut:SetScript("OnFinished", function()
			row:Hide()
			local frame = LootDisplayFrame
			frame:ReleaseRow(row)
		end)
	end

	row.FadeOutAnimation.fadeOut:SetStartDelay(G_RLF.db.global.fadeOutDelay)
end

local function rowStyles(row)
	row:SetSize(G_RLF.db.global.feedWidth, G_RLF.db.global.rowHeight)
	rowBackground(row)
	rowIcon(row, row.icon)
	rowUnitPortrait(row)
	rowText(row, row.icon)
	rowHighlightBorder(row)
	rowFadeOutAnimation(row)
end

--@alpha@
rowStyles = G_RLF:ProfileFunction(rowStyles, "rowStyles")
rowBackground = G_RLF:ProfileFunction(rowBackground, "rowBackground")
rowIcon = G_RLF:ProfileFunction(rowIcon, "rowIcon")
rowUnitPortrait = G_RLF:ProfileFunction(rowUnitPortrait, "rowUnitPortrait")
rowText = G_RLF:ProfileFunction(rowText, "rowPrimaryText")
rowHighlightBorder = G_RLF:ProfileFunction(rowHighlightBorder, "rowHighlightBorder")
rowFadeOutAnimation = G_RLF:ProfileFunction(rowFadeOutAnimation, "rowFadeOutAnimation")
--@end-alpha@

local defaultColor = { 1, 1, 1, 1 }
function LootDisplayRowMixin:Reset()
	self:ClearAllPoints()

	-- Reset row-specific data
	self.key = nil
	self.amount = nil
	self.icon = nil
	self.link = nil
	self.secondaryText = nil
	self.unit = nil

	-- Reset UI elements that were part of the template
	self.TopBorder:SetAlpha(0)
	self.RightBorder:SetAlpha(0)
	self.BottomBorder:SetAlpha(0)
	self.LeftBorder:SetAlpha(0)

	self.Icon:Reset()

	self.UnitPortrait:SetTexture(nil)

	-- Reset amount text behavior
	self.PrimaryText:SetScript("OnEnter", nil)
	self.PrimaryText:SetScript("OnLeave", nil)

	self.PrimaryText:SetTextColor(unpack(defaultColor))
	rowBackground(self)
	rowHighlightBorder(self)
	rowFadeOutAnimation(self)
end

function LootDisplayRowMixin:UpdateStyles()
	rowStyles(self)
	if self.icon and G_RLF.iconGroup then
		G_RLF.iconGroup:ReSkin(self.Icon)
	end
end

function LootDisplayRowMixin:UpdateFadeoutDelay()
	rowFadeOutAnimation(self)
end

function LootDisplayRowMixin:UpdateSecondaryText(secondaryTextFn)
	if
		G_RLF.db.global.enabledSecondaryRowText
		and type(secondaryTextFn) == "function"
		and secondaryTextFn(self.amount) ~= ""
		and secondaryTextFn(self.amount) ~= nil
	then
		self.secondaryText = secondaryTextFn(self.amount)
	else
		self.secondaryText = nil
	end
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

function LootDisplayRowMixin:SetPosition(frame)
	-- Position the new row at the bottom (or top if growing down)
	local vertDir, opposite, yOffset = frame.vertDir, frame.opposite, frame.yOffset
	self:ClearAllPoints()
	if self._prev then
		self:SetPoint(vertDir, self._prev, opposite, 0, yOffset)
	else
		self:SetPoint(vertDir, frame, vertDir)
	end
end

function LootDisplayRowMixin:UpdateNeighborPositions(frame)
	local vertDir, opposite, yOffset = frame.vertDir, frame.opposite, frame.yOffset
	local _next = self._next
	local _prev = self._prev

	if _next then
		_next:ClearAllPoints()
		if _prev then
			_next:SetPoint(vertDir, _prev, opposite, 0, yOffset)
		else
			_next:SetPoint(vertDir, frame, vertDir)
		end
	end
end

function LootDisplayRowMixin:SetupTooltip(isHistoryFrame)
	-- Add Tooltip
	self.PrimaryText:SetScript("OnEnter", function()
		if not isHistoryFrame then
			self.FadeOutAnimation:Stop()
			self.HighlightAnimation:Stop()
			self:ResetHighlightBorder()
		end
		if G_RLF.db.global.tooltipOnShift and not IsShiftKeyDown() then
			return
		end
		local inCombat = UnitAffectingCombat("player")
		if inCombat then
			GameTooltip:Hide()
			return
		end
		GameTooltip:SetOwner(self.PrimaryText, "ANCHOR_RIGHT")
		GameTooltip:SetHyperlink(self.link) -- Use the item's link to show the tooltip
		GameTooltip:Show()
	end)
	self.PrimaryText:SetScript("OnLeave", function()
		if not isHistoryFrame then
			self.FadeOutAnimation:Play()
		end
		GameTooltip:Hide()
	end)
end

function LootDisplayRowMixin:IsFading()
	return self.FadeOutAnimation:IsPlaying() and not self.FadeOutAnimation.fadeOut:IsDelaying()
end

function LootDisplayRowMixin:Dump()
	local prevKey, nextKey
	if self._prev then
		prevKey = self._prev.key or "NONE"
	else
		prevKey = "prev nil"
	end

	if self._next then
		nextKey = self._next.key or "NONE"
	else
		nextKey = "next nil"
	end

	return format(
		"{name=%s, key=%s, amount=%s, PrimaryText=%s, _prev.key=%s, _next.key=%s}",
		self:GetDebugName(),
		self.key or "NONE",
		self.amount or "NONE",
		self.PrimaryText:GetText() or "NONE",
		prevKey,
		nextKey
	)
end

function LootDisplayRowMixin:ShowText(text, r, g, b, a)
	if a == nil then
		a = 1
	end

	self.PrimaryText:SetText(text)

	if r == nil and g == nil and b == nil and self.amount ~= nil and self.amount < 0 then
		r, g, b, a = 1, 0, 0, 0.8
	elseif r == nil or g == nil or b == nil then
		r, g, b, a = unpack(defaultColor)
	end

	self.PrimaryText:SetTextColor(r, g, b, a)

	if G_RLF.db.global.enabledSecondaryRowText and self.secondaryText ~= nil and self.secondaryText ~= "" then
		self.SecondaryText:SetText(self.secondaryText)
		self.SecondaryText:Show()
	else
		self.SecondaryText:Hide()
	end
end

function LootDisplayRowMixin:UpdateIcon(key, icon, quality)
	-- Only update if the icon has changed
	if icon and self.icon ~= icon then
		self.icon = icon

		RunNextFrame(function()
			-- Handle quality logic
			if not quality then
				self.Icon:SetItem(self.link)
			else
				self.Icon:SetItemButtonTexture(icon)
				self.Icon:SetItemButtonQuality(quality, self.link)
			end

			if self.Icon.IconOverlay then
				self.Icon.IconOverlay:SetSize(G_RLF.db.global.iconSize, G_RLF.db.global.iconSize)
			end
			if self.Icon.ProfessionQualityOverlay then
				self.Icon.ProfessionQualityOverlay:SetSize(G_RLF.db.global.iconSize, G_RLF.db.global.iconSize)
			end

			self.Icon.NormalTexture:SetTexture(nil)
			self.Icon.HighlightTexture:SetTexture(nil)
			self.Icon.PushedTexture:SetTexture(nil)

			-- Masque reskinning (may be costly, consider reducing frequency)
			if G_RLF.Masque and G_RLF.iconGroup then
				G_RLF.iconGroup:ReSkin(self.Icon)
			end
		end)
	end
end

function LootDisplayRowMixin:ResetFadeOut()
	RunNextFrame(function()
		self.FadeOutAnimation:Stop()
		self.FadeOutAnimation:Play()
	end)
end

function LootDisplayRowMixin:ResetHighlightBorder()
	self.TopBorder:SetAlpha(0)
	self.RightBorder:SetAlpha(0)
	self.BottomBorder:SetAlpha(0)
	self.LeftBorder:SetAlpha(0)
end

function LootDisplayRowMixin:UpdateWithHistoryData(data)
	self:Reset()
	self.key = data.key
	self.amount = data.amount
	self.link = data.link
	self.quality = data.quality
	self.unit = data.unit
	self.PrimaryText:SetText(data.rowText)
	self.PrimaryText:SetTextColor(unpack(data.textColor))
	if self.unit and data.secondaryText then
		self.secondaryText = data.secondaryText
		self.SecondaryText:SetText(self.secondaryText)
	end
	if data.icon then
		self:UpdateIcon(self.key, data.icon, self.quality)
		self:SetupTooltip(true)
	else
		self.icon = nil
	end
	self:UpdateStyles()
end
