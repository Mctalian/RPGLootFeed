local addonName, G_RLF = ...

LootDisplayRowMixin = {}

function LootDisplayRowMixin:StyleBackground()
	local changed = false

	if
		self.cachedGradientStart ~= G_RLF.db.global.rowBackgroundGradientStart
		or self.cachedGradientEnd ~= G_RLF.db.global.rowBackgroundGradientEnd
	then
		self.cachedGradientStart = G_RLF.db.global.rowBackgroundGradientStart
		self.cachedGradientEnd = G_RLF.db.global.rowBackgroundGradientEnd
		changed = true
	end

	if self.cachedBackgoundLeftAlign ~= G_RLF.db.global.leftAlign then
		self.cachedBackgoundLeftAlign = G_RLF.db.global.leftAlign
		changed = true
	end

	if changed then
		local leftColor = CreateColor(unpack(G_RLF.db.global.rowBackgroundGradientStart))
		local rightColor = CreateColor(unpack(G_RLF.db.global.rowBackgroundGradientEnd))
		if not G_RLF.db.global.leftAlign then
			leftColor, rightColor = rightColor, leftColor
		end
		self.Background:SetGradient("HORIZONTAL", leftColor, rightColor)
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
		RunNextFrame(function()
			if row.unit then
				SetPortraitTexture(row.UnitPortrait, row.unit)
			end
		end)
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
			row.ItemCountText:SetFontObject(G_RLF.db.global.font)
			row.SecondaryText:SetFontObject(G_RLF.db.global.font)
		else
			local fontPath = G_RLF.lsm:Fetch(G_RLF.lsm.MediaType.FONT, G_RLF.db.global.fontFace)
			row.PrimaryText:SetFont(fontPath, G_RLF.db.global.fontSize, G_RLF.defaults.global.fontFlags)
			row.ItemCountText:SetFont(fontPath, G_RLF.db.global.fontSize, G_RLF.defaults.global.fontFlags)
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
		row.ItemCountText:ClearAllPoints()
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
					local classColor
					if GetExpansionLevel() >= G_RLF.Expansion.BFA then
						classColor = C_ClassColor.GetClassColor(select(2, UnitClass(row.unit)))
					else
						classColor = RAID_CLASS_COLORS[select(2, UnitClass(row.unit))]
					end
					row.SecondaryText:SetTextColor(classColor.r, classColor.g, classColor.b, 1)
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

		row.ItemCountText:SetPoint(anchor, row.PrimaryText, iconAnchor, xOffset, 0)
	end
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
				fadeIn:SetSmoothing("IN_OUT")

				local fadeOut = b.HighlightAnimation:CreateAnimation("Alpha")
				fadeOut:SetFromAlpha(1)
				fadeOut:SetToAlpha(0)
				fadeOut:SetDuration(0.2)
				fadeOut:SetStartDelay(0.3)
				fadeOut:SetSmoothing("IN_OUT")
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
		row.FadeOutAnimation.fadeOut:SetScript("OnUpdate", function()
			if row.glowTexture and row.glowTexture:IsShown() then
				row.glowTexture:SetAlpha(0.75 * (1 - row.FadeOutAnimation.fadeOut:GetProgress()))
			end
		end)
		row.FadeOutAnimation.fadeOut:SetScript("OnFinished", function()
			row:Hide()
			local frame = LootDisplayFrame
			frame:ReleaseRow(row)
		end)
	end

	row.FadeOutAnimation.fadeOut:SetStartDelay(G_RLF.db.global.fadeOutDelay)
end

local function rowHighlightIcon(row)
	if not row.glowTexture then
		-- Create the glow texture
		row.glowTexture = row.Icon:CreateTexture(nil, "OVERLAY")
		row.glowTexture:SetDrawLayer("OVERLAY", 7)
		row.glowTexture:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
		row.glowTexture:SetPoint("CENTER", row.Icon, "CENTER", 0, 0)
		row.glowTexture:SetSize(row.Icon:GetWidth() * 1.75, row.Icon:GetHeight() * 1.75)
		row.glowTexture:SetBlendMode("ADD") -- "ADD" is often better for glow effects
		row.glowTexture:SetAlpha(0.75)
		row.glowTexture:SetTexCoord(0.00781250, 0.50781250, 0.27734375, 0.52734375)
	end

	row.glowTexture:Hide()

	-- Create the animation group if it doesn't exist
	if not row.glowAnimationGroup then
		row.glowAnimationGroup = row.glowTexture:CreateAnimationGroup()

		-- Add a scale animation for pulsing
		local scaleUp = row.glowAnimationGroup:CreateAnimation("Scale")
		scaleUp:SetScale(1.25, 1.25) -- Slightly increase size
		scaleUp:SetDuration(0.5) -- Half a second to scale up
		scaleUp:SetOrder(1)
		scaleUp:SetSmoothing("IN_OUT") -- Smooth scaling in and out

		local scaleDown = row.glowAnimationGroup:CreateAnimation("Scale")
		scaleDown:SetScale(0.8, 0.8) -- Slightly decrease size back
		scaleDown:SetDuration(0.5) -- Half a second to scale down
		scaleDown:SetOrder(2)
		scaleDown:SetSmoothing("IN_OUT")

		-- Optional: Add a subtle alpha fade during the pulse
		local alphaPulse = row.glowAnimationGroup:CreateAnimation("Alpha")
		alphaPulse:SetFromAlpha(0.75)
		alphaPulse:SetToAlpha(1)
		alphaPulse:SetDuration(0.5)
		alphaPulse:SetOrder(1)
		alphaPulse:SetSmoothing("IN_OUT")

		row.glowAnimationGroup:SetLooping("REPEAT")
	end
end

local function rowStyles(row)
	row:SetSize(G_RLF.db.global.feedWidth, G_RLF.db.global.rowHeight)
	row:StyleBackground()
	rowIcon(row, row.icon)
	RunNextFrame(function()
		rowHighlightIcon(row)
	end)
	rowUnitPortrait(row)
	rowText(row, row.icon)
	rowHighlightBorder(row)
	row:SetRowBorders()
	rowFadeOutAnimation(row)
end

--@alpha@
rowStyles = G_RLF:ProfileFunction(rowStyles, "rowStyles")
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
	self.id = nil
	self.key = nil
	self.amount = nil
	self.icon = nil
	self.link = nil
	self.secondaryText = nil
	self.unit = nil
	self.type = nil

	-- Reset UI elements that were part of the template
	self.TopBorder:SetAlpha(0)
	self.RightBorder:SetAlpha(0)
	self.BottomBorder:SetAlpha(0)
	self.LeftBorder:SetAlpha(0)

	self.Icon:Reset()
	self.Icon:SetScript("OnEnter", nil)
	self.Icon:SetScript("OnLeave", nil)
	self.Icon:SetScript("OnMouseUp", nil)
	self.Icon:SetScript("OnEvent", nil)

	if self.glowAnimationGroup then
		self.glowAnimationGroup:Stop()
	end
	if self.glowTexture then
		self.glowTexture:Hide()
	end

	self.UnitPortrait:SetTexture(nil)
	self.SecondaryText:SetText(nil)
	self.SecondaryText:SetTextColor(unpack(defaultColor))
	self.ItemCountText:SetText(nil)
	self.ItemCountText:Hide()
	self.ClickableButton:Hide()
	local textures = { self.ClickableButton:GetRegions() }
	for _, region in ipairs(textures) do
		if region:GetObjectType() == "Texture" then
			region:Hide()
		end
	end

	self.ClickableButton:SetScript("OnEnter", nil)
	self.ClickableButton:SetScript("OnLeave", nil)
	self.ClickableButton:SetScript("OnMouseUp", nil)
	self.ClickableButton:SetScript("OnEvent", nil)

	self.isHistoryMode = false

	self.PrimaryText:SetTextColor(unpack(defaultColor))
	self:StyleBackground()
	rowHighlightBorder(self)
	rowFadeOutAnimation(self)
	self:SetUpHideOnRightClick()
	RunNextFrame(function()
		self:SetUpHoverEffect()
	end)
end

function LootDisplayRowMixin:SetUpHideOnRightClick()
	self:SetScript("OnMouseUp", function(_, button)
		if button == "RightButton" and not self.isHistoryMode then
			if not self.FadeOutAnimation then
				return
			end
			-- Stop any ongoing animation
			if self.FadeOutAnimation:IsPlaying() then
				self.FadeOutAnimation:Stop()
			end

			-- Remove the delay for immediate fade-out
			self.FadeOutAnimation.fadeOut:SetStartDelay(0)

			-- Start the fade-out animation
			self.FadeOutAnimation:Play()
		end
	end)
end

function LootDisplayRowMixin:UpdateStyles()
	rowStyles(self)
	if self.icon and G_RLF.iconGroup then
		G_RLF.iconGroup:ReSkin(self.Icon)
	end
end

function LootDisplayRowMixin:SetRowBorders()
	if not G_RLF.db.global.enableRowBorder then
		self.StaticTopBorder:Hide()
		self.StaticRightBorder:Hide()
		self.StaticBottomBorder:Hide()
		self.StaticLeftBorder:Hide()
	end

	if self.cachedBorderSize ~= G_RLF.db.global.rowBorderSize then
		self.cachedBorderSize = G_RLF.db.global.rowBorderSize
		self.StaticTopBorder:SetSize(0, G_RLF.db.global.rowBorderSize)
		self.StaticRightBorder:SetSize(G_RLF.db.global.rowBorderSize, 0)
		self.StaticBottomBorder:SetSize(0, G_RLF.db.global.rowBorderSize)
		self.StaticLeftBorder:SetSize(G_RLF.db.global.rowBorderSize, 0)
	end

	if self.cacheBorderColor ~= G_RLF.db.global.rowBorderColor or G_RLF.db.global.rowBorderClassColors then
		self.cacheBorderColor = G_RLF.db.global.rowBorderColor
		if G_RLF.db.global.rowBorderClassColors then
			local classColor
			if GetExpansionLevel() >= G_RLF.Expansion.BFA then
				classColor = C_ClassColor.GetClassColor(select(2, UnitClass(self.unit or "player")))
			else
				classColor = RAID_CLASS_COLORS[select(2, UnitClass(self.unit or "player"))]
			end
			self.StaticTopBorder:SetColorTexture(classColor.r, classColor.g, classColor.b, 1)
			self.StaticRightBorder:SetColorTexture(classColor.r, classColor.g, classColor.b, 1)
			self.StaticBottomBorder:SetColorTexture(classColor.r, classColor.g, classColor.b, 1)
			self.StaticLeftBorder:SetColorTexture(classColor.r, classColor.g, classColor.b, 1)
		else
			local r, g, b, a = unpack(G_RLF.db.global.rowBorderColor)
			self.StaticTopBorder:SetColorTexture(r, g, b, a)
			self.StaticRightBorder:SetColorTexture(r, g, b, a)
			self.StaticBottomBorder:SetColorTexture(r, g, b, a)
			self.StaticLeftBorder:SetColorTexture(r, g, b, a)
		end
	end

	if G_RLF.db.global.enableRowBorder then
		self.StaticTopBorder:Show()
		self.StaticRightBorder:Show()
		self.StaticBottomBorder:Show()
		self.StaticLeftBorder:Show()
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
	-- Dynamically size the button to match the PrimaryText width
	self.ClickableButton:ClearAllPoints()
	self.ClickableButton:SetPoint("LEFT", self.PrimaryText, "LEFT")
	self.ClickableButton:SetSize(self.PrimaryText:GetStringWidth(), self.PrimaryText:GetStringHeight())
	self.ClickableButton:Show()
	-- Add Tooltip
	-- Tooltip logic
	local function showTooltip()
		if not G_RLF.db.global.tooltip then
			return
		end
		if G_RLF.db.global.tooltipOnShift and not IsShiftKeyDown() then
			return
		end
		local inCombat = UnitAffectingCombat("player")
		if inCombat then
			return
		end
		GameTooltip:SetOwner(self.ClickableButton, "ANCHOR_RIGHT")
		GameTooltip:SetHyperlink(self.link) -- Use the item's link to show the tooltip
		GameTooltip:Show()
	end

	local function hideTooltip()
		GameTooltip:Hide()
	end

	-- OnEnter: Show tooltip or listen for Shift changes
	self.ClickableButton:SetScript("OnEnter", function()
		if not isHistoryFrame then
			self.FadeOutAnimation:Stop()
			self.HighlightAnimation:Stop()
			self:ResetHighlightBorder()
		end
		showTooltip()

		-- Start listening for Shift key changes
		self.ClickableButton:RegisterEvent("MODIFIER_STATE_CHANGED")
	end)

	-- OnLeave: Hide tooltip and stop listening for Shift changes
	self.ClickableButton:SetScript("OnLeave", function()
		if not isHistoryFrame then
			self.FadeOutAnimation:Play()
		end
		hideTooltip()

		-- Stop listening for Shift key changes
		self.ClickableButton:UnregisterEvent("MODIFIER_STATE_CHANGED")
	end)

	-- Handle Shift key changes
	self.ClickableButton:SetScript("OnEvent", function(_, event, key, state)
		if event == "MODIFIER_STATE_CHANGED" and key == "LSHIFT" then
			if state == 1 then
				showTooltip()
			else
				hideTooltip()
			end
		end
	end)

	local function handleClick(button)
		if button == "LeftButton" and not IsModifiedClick() then
			-- Open the ItemRefTooltip to mimic in-game chat behavior
			if self.link then
				SetItemRef(self.link, self.link, button, self.ClickableButton)
			end
		elseif button == "LeftButton" and IsShiftKeyDown() then
			-- Custom behavior for right click, if needed
			if ChatEdit_GetActiveWindow() then
				ChatEdit_InsertLink(self.link)
			else
				ChatFrame_OpenChat(self.link)
			end
		elseif button == "RightButton" and not self.isHistoryMode then
			-- Stop any ongoing animation
			if self.FadeOutAnimation:IsPlaying() then
				self.FadeOutAnimation:Stop()
			end

			-- Remove the delay for immediate fade-out
			self.FadeOutAnimation.fadeOut:SetStartDelay(0)

			-- Start the fade-out animation
			self.FadeOutAnimation:Play()
		end
	end

	-- Add Click Handling for ItemRefTooltip
	self.ClickableButton:SetScript("OnMouseUp", function(_, button)
		handleClick(button)
	end)

	if self.Icon then
		self.Icon:SetScript("OnEnter", function()
			if not isHistoryFrame then
				self.FadeOutAnimation:Stop()
				self.HighlightAnimation:Stop()
				self:ResetHighlightBorder()
			end
			showTooltip()
			self.Icon:RegisterEvent("MODIFIER_STATE_CHANGED")
		end)
		self.Icon:SetScript("OnLeave", function()
			if not isHistoryFrame then
				self.FadeOutAnimation:Play()
			end
			hideTooltip()
			self.Icon:UnregisterEvent("MODIFIER_STATE_CHANGED")
		end)
		self.Icon:SetScript("OnEvent", function(_, event, key, state)
			if event == "MODIFIER_STATE_CHANGED" and key == "LSHIFT" then
				if state == 1 then
					showTooltip()
				else
					hideTooltip()
				end
			end
		end)
		self.Icon:SetScript("OnMouseUp", function(_, button)
			handleClick(button)
		end)
	end
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

function LootDisplayRowMixin:UpdateItemCount()
	RunNextFrame(function()
		if self.id then
			local itemCount = C_Item.GetItemCount(self.id, true, false, true, true)

			if itemCount then
				self:ShowItemCountText(itemCount, { wrapChar = G_RLF.WrapCharEnum.PARENTHESIS })
			end
		end
	end)
end

function LootDisplayRowMixin:ShowItemCountText(itemCount, options)
	local WrapChar = G_RLF.WrapCharEnum
	options = options or {}
	local color = options.color or "|cFFBCBCBC"
	local wrapChar = options.wrapChar or WrapChar.DEFAULT
	local showSign = options.showSign or false

	local sChar, eChar
	if wrapChar == WrapChar.SPACE then
		sChar, eChar = " ", ""
	elseif wrapChar == WrapChar.PARENTHESIS then
		sChar, eChar = "(", ")"
	elseif wrapChar == WrapChar.BRACKET then
		sChar, eChar = "[", "]"
	elseif wrapChar == WrapChar.BRACE then
		sChar, eChar = "{", "}"
	elseif wrapChar == WrapChar.ANGLE then
		sChar, eChar = "<", ">"
	else
		sChar, eChar = "", ""
	end

	if itemCount and (itemCount > 1 or (showSign and itemCount >= 1)) then
		local sign = ""
		if showSign then
			sign = "+"
		end
		self.ItemCountText:SetText(color .. sChar .. sign .. itemCount .. eChar .. "|r")
		self.ItemCountText:Show()
	else
		self.ItemCountText:Hide()
	end
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

	if self.link then
		self.ClickableButton:SetSize(self.PrimaryText:GetStringWidth(), self.PrimaryText:GetStringHeight())
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

-- Utility function to check if the mouse is over the parent or any of its children
local function isMouseOverSelfOrChildren(frame)
	if frame:IsMouseOver() then
		return true
	end

	for _, child in ipairs({ frame:GetChildren() }) do
		if child:IsMouseOver() then
			return true
		end
	end

	return false
end

function LootDisplayRowMixin:SetUpHoverEffect()
	local highlightedAlpha = 0.25
	-- Fade-in animation group
	if not self.HighlightFadeIn then
		self.HighlightFadeIn = self.HighlightBGOverlay:CreateAnimationGroup()

		local fadeIn = self.HighlightFadeIn:CreateAnimation("Alpha")
		local startingAlpha = self.HighlightBGOverlay:GetAlpha()
		fadeIn:SetFromAlpha(startingAlpha) -- Start from the current alpha
		fadeIn:SetToAlpha(highlightedAlpha) -- Target alpha for the highlight
		local duration = 0.3 * (highlightedAlpha - startingAlpha) / highlightedAlpha
		fadeIn:SetDuration(duration)
		fadeIn:SetSmoothing("OUT")

		-- Ensure alpha is held at target level after animation finishes
		self.HighlightFadeIn:SetScript("OnFinished", function()
			self.HighlightBGOverlay:SetAlpha(highlightedAlpha) -- Hold at target alpha
		end)
	end

	-- Fade-out animation group
	if not self.HighlightFadeOut then
		self.HighlightFadeOut = self.HighlightBGOverlay:CreateAnimationGroup()

		local fadeOut = self.HighlightFadeOut:CreateAnimation("Alpha")
		local startingAlpha = self.HighlightBGOverlay:GetAlpha()
		fadeOut:SetFromAlpha(startingAlpha) -- Start from the target alpha of the fade-in
		fadeOut:SetToAlpha(0) -- Return to original alpha
		local duration = 0.3 * startingAlpha / highlightedAlpha
		fadeOut:SetDuration(duration)
		fadeOut:SetSmoothing("IN")
		-- fadeOut:SetStartDelay(0.15) -- Delay before starting the fade-out

		-- Ensure alpha is fully reset after animation finishes
		self.HighlightFadeOut:SetScript("OnFinished", function()
			self.HighlightBGOverlay:SetAlpha(0) -- Reset to invisible
		end)
	end

	-- OnEnter: Play fade-in animation
	self:SetScript("OnEnter", function()
		if self.hasMouseOver then
			return
		end
		self.hasMouseOver = true
		-- Stop fade-out if it’s playing
		if self.HighlightFadeOut:IsPlaying() then
			self.HighlightFadeOut:Stop()
		end
		-- Play fade-in
		self.HighlightFadeIn:Play()
	end)

	-- OnLeave: Play fade-out animation
	self:SetScript("OnLeave", function()
		-- Prevent OnLeave from firing if the mouse is still over the row or any of its children
		if isMouseOverSelfOrChildren(self) or not self.hasMouseOver then
			return
		end
		self.hasMouseOver = false
		-- Stop fade-in if it’s playing
		if self.HighlightFadeIn:IsPlaying() then
			self.HighlightFadeIn:Stop()
		end
		-- Play fade-out
		self.HighlightFadeOut:Play()
	end)
end

function LootDisplayRowMixin:HighlightIcon()
	RunNextFrame(function()
		-- Show the glow texture and play the animation
		self.glowTexture:Show()
		self.glowAnimationGroup:Play()
	end)
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
	self.isHistoryMode = true
	self.key = data.key
	self.amount = data.amount
	self.link = data.link
	self.quality = data.quality
	self.unit = data.unit
	self.PrimaryText:SetText(data.rowText)
	self.PrimaryText:SetTextColor(unpack(data.textColor))
	if self.unit and data.secondaryText and G_RLF.db.global.enabledSecondaryRowText then
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
