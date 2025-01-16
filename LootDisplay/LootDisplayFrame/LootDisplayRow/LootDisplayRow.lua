local addonName, G_RLF = ...

LootDisplayRowMixin = {}

local defaultColor = { 1, 1, 1, 1 }
function LootDisplayRowMixin:Init()
	self.waiting = false
	if self:IsStaggeredEnter() then
		self.waiting = true
	end
	self.pendingUpdate = false

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

	self:SetSize(G_RLF.db.global.feedWidth, G_RLF.db.global.rowHeight)
	self:StyleBackground()
	self:StyleRowBorders()
	self:StyleEnterAnimation()
	self:StyleElementFadeIn()
	self:StyleFadeOutAnimation()
	self:StyleHighlightBorder()
	self:HandlerOnRightClick()
	RunNextFrame(function()
		self:SetUpHoverEffect()
	end)
end

function LootDisplayRowMixin:Reset()
	self:Hide()
	self:SetAlpha(1)
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
	self.highlight = nil
	self.isHistoryMode = false

	-- Reset UI elements that were part of the template
	self.TopBorder:SetAlpha(0)
	self.RightBorder:SetAlpha(0)
	self.BottomBorder:SetAlpha(0)
	self.LeftBorder:SetAlpha(0)

	self.Icon:Reset()
	self.Icon.NormalTexture:SetTexture(nil)
	self.Icon.HighlightTexture:SetTexture(nil)
	self.Icon.PushedTexture:SetTexture(nil)
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
	if self.EnterAnimation then
		self.EnterAnimation:Stop()
	end

	self.UnitPortrait:SetTexture(nil)
	self.PrimaryText:SetText(nil)
	self.SecondaryText:SetText(nil)
	self.SecondaryText:SetTextColor(unpack(defaultColor))
	self.SecondaryText:Hide()
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
	self.PrimaryText:SetTextColor(unpack(defaultColor))
end

function LootDisplayRowMixin:StyleElementFadeIn()
	-- Fade in all of the UI elements for the row
	-- Icon, PrimaryText, ItemCountText, SecondaryText, UnitPortrait
	local fadeInDuration = 0.2
	local fadeInSmoothing = "IN_OUT"

	if not self.ElementFadeInAnimation then
		self.ElementFadeInAnimation = self:CreateAnimationGroup()
		self.ElementFadeInAnimation:SetToFinalAlpha(true)
		self.ElementFadeInAnimation:SetScript("OnFinished", function()
			self:HighlightIcon()
			self:ResetFadeOut()
			if self.updatePending then
				self:UpdateQuantity()
			end
		end)
	end

	-- Icon
	if not self.Icon.elementFadeIn then
		self.Icon.elementFadeIn = {
			icon = self.ElementFadeInAnimation:CreateAnimation("Alpha"),
			IconBorder = self.ElementFadeInAnimation:CreateAnimation("Alpha"),
			IconOverlay = self.ElementFadeInAnimation:CreateAnimation("Alpha"),
			Stock = self.ElementFadeInAnimation:CreateAnimation("Alpha"),
			Count = self.ElementFadeInAnimation:CreateAnimation("Alpha"),
		}
		self.Icon.elementFadeIn.icon:SetTarget(self.Icon.icon)
		self.Icon.elementFadeIn.icon:SetFromAlpha(0)
		self.Icon.elementFadeIn.icon:SetToAlpha(1)
		self.Icon.elementFadeIn.icon:SetSmoothing(fadeInSmoothing)
		self.Icon.elementFadeIn.IconBorder:SetTarget(self.Icon.IconBorder)
		self.Icon.elementFadeIn.IconBorder:SetFromAlpha(0)
		self.Icon.elementFadeIn.IconBorder:SetToAlpha(1)
		self.Icon.elementFadeIn.IconBorder:SetSmoothing(fadeInSmoothing)
		self.Icon.elementFadeIn.IconOverlay:SetTarget(self.Icon.IconOverlay)
		self.Icon.elementFadeIn.IconOverlay:SetFromAlpha(0)
		self.Icon.elementFadeIn.IconOverlay:SetToAlpha(1)
		self.Icon.elementFadeIn.IconOverlay:SetSmoothing(fadeInSmoothing)
		self.Icon.elementFadeIn.Stock:SetTarget(self.Icon.Stock)
		self.Icon.elementFadeIn.Stock:SetFromAlpha(0)
		self.Icon.elementFadeIn.Stock:SetToAlpha(1)
		self.Icon.elementFadeIn.Stock:SetSmoothing(fadeInSmoothing)
		self.Icon.elementFadeIn.Count:SetTarget(self.Icon.Count)
		self.Icon.elementFadeIn.Count:SetFromAlpha(0)
		self.Icon.elementFadeIn.Count:SetToAlpha(1)
		self.Icon.elementFadeIn.Count:SetSmoothing(fadeInSmoothing)
	end
	self.Icon.elementFadeIn.icon:SetDuration(fadeInDuration)
	self.Icon.elementFadeIn.IconBorder:SetDuration(fadeInDuration)
	self.Icon.elementFadeIn.IconOverlay:SetDuration(fadeInDuration)
	self.Icon.elementFadeIn.Stock:SetDuration(fadeInDuration)
	self.Icon.elementFadeIn.Count:SetDuration(fadeInDuration)

	-- PrimaryText
	if not self.PrimaryText.elementFadeIn then
		self.PrimaryText.elementFadeIn = self.ElementFadeInAnimation:CreateAnimation("Alpha")
		self.PrimaryText.elementFadeIn:SetTarget(self.PrimaryText)
		self.PrimaryText.elementFadeIn:SetFromAlpha(0)
		self.PrimaryText.elementFadeIn:SetToAlpha(1)
		self.PrimaryText.elementFadeIn:SetSmoothing(fadeInSmoothing)
	end
	self.PrimaryText.elementFadeIn:SetDuration(fadeInDuration)

	-- ItemCountText
	if not self.ItemCountText.elementFadeIn then
		self.ItemCountText.elementFadeIn = self.ElementFadeInAnimation:CreateAnimation("Alpha")
		self.ItemCountText.elementFadeIn:SetTarget(self.ItemCountText)
		self.ItemCountText.elementFadeIn:SetFromAlpha(0)
		self.ItemCountText.elementFadeIn:SetToAlpha(1)
		self.ItemCountText.elementFadeIn:SetSmoothing(fadeInSmoothing)
	end
	self.ItemCountText.elementFadeIn:SetDuration(fadeInDuration)

	-- SecondaryText
	if not self.SecondaryText.elementFadeIn then
		self.SecondaryText.elementFadeIn = self.ElementFadeInAnimation:CreateAnimation("Alpha")
		self.SecondaryText.elementFadeIn:SetTarget(self.SecondaryText)
		self.SecondaryText.elementFadeIn:SetFromAlpha(0)
		self.SecondaryText.elementFadeIn:SetToAlpha(1)
		self.SecondaryText.elementFadeIn:SetSmoothing(fadeInSmoothing)
	end
	self.SecondaryText.elementFadeIn:SetDuration(fadeInDuration)

	-- UnitPortrait
	if not self.UnitPortrait.elementFadeIn then
		self.UnitPortrait.elementFadeIn = self.ElementFadeInAnimation:CreateAnimation("Alpha")
		self.UnitPortrait.elementFadeIn:SetTarget(self.UnitPortrait)
		self.UnitPortrait.elementFadeIn:SetFromAlpha(0)
		self.UnitPortrait.elementFadeIn:SetToAlpha(1)
		self.UnitPortrait.elementFadeIn:SetSmoothing(fadeInSmoothing)
	end
	self.UnitPortrait.elementFadeIn:SetDuration(fadeInDuration)
end

function LootDisplayRowMixin:StyleBackground()
	local changed = false

	local gradientStart = G_RLF.db.global.rowBackgroundGradientStart
	local gradientEnd = G_RLF.db.global.rowBackgroundGradientEnd
	local leftAlign = G_RLF.db.global.leftAlign

	if self.cachedGradientStart ~= gradientStart then
		self.cachedGradientStart = gradientStart
		changed = true
	end

	if self.cachedGradientEnd ~= gradientEnd then
		self.cachedGradientEnd = gradientEnd
		changed = true
	end

	if self.cachedBackgoundLeftAlign ~= leftAlign then
		self.cachedBackgoundLeftAlign = leftAlign
		changed = true
	end

	if changed then
		local leftColor = CreateColor(unpack(gradientStart))
		local rightColor = CreateColor(unpack(gradientEnd))
		if not leftAlign then
			leftColor, rightColor = rightColor, leftColor
		end
		self.Background:SetGradient("HORIZONTAL", leftColor, rightColor)
	end
end

function LootDisplayRowMixin:StyleIcon()
	local changed = false

	local iconSize = G_RLF.db.global.iconSize
	local leftAlign = G_RLF.db.global.leftAlign

	if self.cachedIconSize ~= iconSize then
		self.cachedIconSize = iconSize
		changed = true
	end

	if self.cachedIconLeftAlign ~= leftAlign then
		self.cachedIconLeftAlign = leftAlign
		changed = true
	end

	if changed then
		self.Icon:ClearAllPoints()
		self.Icon:SetSize(iconSize, iconSize)
		self.Icon.IconBorder:SetSize(iconSize, iconSize)
		local anchor, xOffset = "LEFT", iconSize / 4
		if not leftAlign then
			anchor, xOffset = "RIGHT", -xOffset
		end
		if G_RLF.Masque and G_RLF.iconGroup then
			G_RLF.iconGroup:AddButton(self.Icon)
		end
		self.Icon:SetPoint(anchor, xOffset, 0)
	end
	self.Icon:SetShown(self.icon ~= nil)
end

function LootDisplayRowMixin:StyleUnitPortrait()
	local sizeChanged = false

	local iconSize = G_RLF.db.global.iconSize
	local leftAlign = G_RLF.db.global.leftAlign

	if self.cachedUnitIconSize ~= iconSize or self.cachedUnitLeftAlign ~= leftAlign then
		self.cachedUnitIconSize = iconSize
		self.cachedUnitLeftAlign = leftAlign
		sizeChanged = true
	end

	if sizeChanged then
		local portraitSize = iconSize * 0.8
		self.UnitPortrait:SetSize(portraitSize, portraitSize)
		self.UnitPortrait:ClearAllPoints()

		local anchor, iconAnchor, xOffset = "LEFT", "RIGHT", iconSize / 4
		if not leftAlign then
			anchor, iconAnchor, xOffset = "RIGHT", "LEFT", -xOffset
		end

		self.UnitPortrait:SetPoint(anchor, self.Icon, iconAnchor, xOffset, 0)
	end

	if self.unit then
		RunNextFrame(function()
			if self.unit then
				SetPortraitTexture(self.UnitPortrait, self.unit)
			end
		end)
		self.UnitPortrait:Show()
	else
		self.UnitPortrait:Hide()
	end
end

function LootDisplayRowMixin:StyleText()
	local fontChanged = false

	local fontFace = G_RLF.db.global.fontFace
	local useFontObjects = G_RLF.db.global.useFontObjects
	local font = G_RLF.db.global.font
	local fontFlags = G_RLF.db.global.fontFlags
	local fontSize = G_RLF.db.global.fontSize
	local secondaryFontSize = G_RLF.db.global.secondaryFontSize

	if
		self.cachedFontFace ~= fontFace
		or self.cachedFontSize ~= fontSize
		or self.cachedSecondaryFontSize ~= secondaryFontSize
		or self.cachedFontFlags ~= fontFlags
	then
		self.cachedFontFace = fontFace
		self.cachedFontSize = fontSize
		self.cachedSecondaryFontSize = secondaryFontSize
		self.cachedFontFlags = fontFlags
		fontChanged = true
	end

	if self.cachedUseFontObject ~= useFontObjects then
		self.cachedUseFontObject = useFontObjects
		fontChanged = true
	end

	if fontChanged then
		if useFontObjects or not fontFace then
			self.PrimaryText:SetFontObject(font)
			self.ItemCountText:SetFontObject(font)
			self.SecondaryText:SetFontObject(font)
		else
			local fontPath = G_RLF.lsm:Fetch(G_RLF.lsm.MediaType.FONT, fontFace)
			self.PrimaryText:SetFont(fontPath, fontSize, fontFlags)
			self.ItemCountText:SetFont(fontPath, fontSize, fontFlags)
			self.SecondaryText:SetFont(fontPath, secondaryFontSize, fontFlags)
		end
	end

	local leftAlign = G_RLF.db.global.leftAlign
	local padding = G_RLF.db.global.padding
	local iconSize = G_RLF.db.global.iconSize
	local enabledSecondaryRowText = G_RLF.db.global.enabledSecondaryRowText

	if
		self.cachedRowTextLeftAlign ~= leftAlign
		or self.cachedRowTextXOffset ~= iconSize / 4
		or self.cachedRowTextIcon ~= self.icon
		or self.cachedEnabledSecondaryText ~= enabledSecondaryRowText
		or self.cachedSecondaryText ~= self.secondaryText
		or self.cachedUnitText ~= self.unit
		or self.cachedPaddingText ~= padding
	then
		self.cachedRowTextLeftAlign = leftAlign
		self.cachedRowTextXOffset = iconSize / 4
		self.cachedRowTextIcon = self.icon
		self.cachedEnabledSecondaryText = enabledSecondaryRowText
		self.cachedSecondaryText = self.secondaryText
		self.cachedUnitText = self.unit
		self.cachedPaddingText = padding

		local anchor = "LEFT"
		local iconAnchor = "RIGHT"
		local xOffset = iconSize / 4
		if not leftAlign then
			anchor = "RIGHT"
			iconAnchor = "LEFT"
			xOffset = xOffset * -1
		end
		self.PrimaryText:ClearAllPoints()
		self.ItemCountText:ClearAllPoints()
		self.PrimaryText:SetJustifyH(anchor)
		if self.icon then
			if self.unit then
				self.PrimaryText:SetPoint(anchor, self.UnitPortrait, iconAnchor, xOffset, 0)
			else
				self.PrimaryText:SetPoint(anchor, self.Icon, iconAnchor, xOffset, 0)
			end
		else
			self.PrimaryText:SetPoint(anchor, self.Icon, anchor, 0, 0)
		end

		if enabledSecondaryRowText and self.secondaryText ~= nil and self.secondaryText ~= "" then
			self.SecondaryText:ClearAllPoints()
			self.SecondaryText:SetJustifyH(anchor)
			if self.icon then
				if self.unit then
					self.SecondaryText:SetPoint(anchor, self.UnitPortrait, iconAnchor, xOffset, 0)
					local classColor
					if GetExpansionLevel() >= G_RLF.Expansion.BFA then
						classColor = C_ClassColor.GetClassColor(select(2, UnitClass(self.unit)))
					else
						classColor = RAID_CLASS_COLORS[select(2, UnitClass(self.unit))]
					end
					self.SecondaryText:SetTextColor(classColor.r, classColor.g, classColor.b, 1)
				else
					self.SecondaryText:SetPoint(anchor, self.Icon, iconAnchor, xOffset, 0)
				end
			else
				self.SecondaryText:SetPoint(anchor, self.Icon, anchor, 0, 0)
			end
			self.PrimaryText:SetPoint("BOTTOM", self, "CENTER", 0, padding)
			self.SecondaryText:SetPoint("TOP", self, "CENTER", 0, -padding)
			self.SecondaryText:SetShown(true)
		end

		self.ItemCountText:SetPoint(anchor, self.PrimaryText, iconAnchor, xOffset, 0)
	end
end

function LootDisplayRowMixin:StyleRowBorders()
	local enableRowBorder = G_RLF.db.global.enableRowBorder
	if not enableRowBorder then
		self.StaticTopBorder:Hide()
		self.StaticRightBorder:Hide()
		self.StaticBottomBorder:Hide()
		self.StaticLeftBorder:Hide()
		return
	end

	local borderSize = G_RLF.db.global.rowBorderSize
	local classColors = G_RLF.db.global.rowBorderClassColors
	local borderColor = G_RLF.db.global.rowBorderColor

	if self.cachedBorderSize ~= borderSize then
		self.cachedBorderSize = borderSize
		self.StaticTopBorder:SetHeight(borderSize)
		self.StaticRightBorder:SetWidth(borderSize)
		self.StaticBottomBorder:SetHeight(borderSize)
		self.StaticLeftBorder:SetWidth(borderSize)
	end

	if self.cacheBorderColor ~= borderColor or self.cacheClassColors ~= classColors then
		self.cacheBorderColor = borderColor
		self.cacheClassColors = classColors
		if classColors then
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
			local r, g, b, a = unpack(borderColor)
			self.StaticTopBorder:SetColorTexture(r, g, b, a)
			self.StaticRightBorder:SetColorTexture(r, g, b, a)
			self.StaticBottomBorder:SetColorTexture(r, g, b, a)
			self.StaticLeftBorder:SetColorTexture(r, g, b, a)
		end
	end

	if enableRowBorder then
		self.StaticTopBorder:Show()
		self.StaticRightBorder:Show()
		self.StaticBottomBorder:Show()
		self.StaticLeftBorder:Show()
	end
end

function LootDisplayRowMixin:StyleHighlightBorder()
	if not self.HighlightAnimation then
		self.HighlightAnimation = self:CreateAnimationGroup()
		self.HighlightAnimation:SetToFinalAlpha(true)
		local borders = {
			self.TopBorder,
			self.RightBorder,
			self.BottomBorder,
			self.LeftBorder,
		}

		for _, b in ipairs(borders) do
			if not b.fadeIn then
				b.fadeIn = self.HighlightAnimation:CreateAnimation("Alpha")
				b.fadeIn:SetTarget(b)
				b.fadeIn:SetOrder(1)
				b.fadeIn:SetFromAlpha(0)
				b.fadeIn:SetToAlpha(1)
				b.fadeIn:SetDuration(0.2)
				b.fadeIn:SetSmoothing("IN_OUT")
			end

			if not b.fadeOut then
				b.fadeOut = self.HighlightAnimation:CreateAnimation("Alpha")
				b.fadeOut:SetTarget(b)
				b.fadeOut:SetOrder(2)
				b.fadeOut:SetFromAlpha(1)
				b.fadeOut:SetToAlpha(0)
				b.fadeOut:SetDuration(0.2)
				b.fadeOut:SetStartDelay(0.1)
				b.fadeOut:SetSmoothing("IN_OUT")
			end
		end
	end
end

function LootDisplayRowMixin:StyleFadeOutAnimation()
	if not self.FadeOutAnimation then
		self.FadeOutAnimation = self:CreateAnimationGroup()
		self.FadeOutAnimation:SetToFinalAlpha(true)
	end
	if not self.FadeOutAnimation.fadeOut then
		self.FadeOutAnimation.fadeOut = self.FadeOutAnimation:CreateAnimation("Alpha")
		self.FadeOutAnimation.fadeOut:SetFromAlpha(1)
		self.FadeOutAnimation.fadeOut:SetToAlpha(0)
		self.FadeOutAnimation.fadeOut:SetScript("OnUpdate", function()
			if self.glowTexture and self.glowTexture:IsShown() then
				self.glowTexture:SetAlpha(0.75 * (1 - self.FadeOutAnimation.fadeOut:GetProgress()))
			end
		end)
		self.FadeOutAnimation.fadeOut:SetScript("OnFinished", function()
			self:Hide()
			local frame = LootDisplayFrame
			frame:ReleaseRow(self)
		end)
	end

	self.FadeOutAnimation.fadeOut:SetDuration(G_RLF.db.global.animations.exit.duration)
	self.FadeOutAnimation.fadeOut:SetStartDelay(G_RLF.db.global.fadeOutDelay)
end

function LootDisplayRowMixin:StyleEnterAnimation()
	local animationChanged = false

	local enterAnimationType = G_RLF.db.global.animations.enter.type
	local slideDirection = G_RLF.db.global.animations.enter.slide.direction
	local enterDuration = G_RLF.db.global.animations.enter.duration
	local feedWidth = G_RLF.db.global.feedWidth
	local rowHeight = G_RLF.db.global.rowHeight

	if
		self.cachedEnterAnimationType ~= enterAnimationType
		or self.cachedEnterAnimationSlideDirection ~= slideDirection
		or self.cachedEnterAnimationDuration ~= enterDuration
		or self.cachedEnterAnimationFeedWidth ~= feedWidth
		or self.cachedEnterAnimationRowHeight ~= rowHeight
	then
		self.cachedEnterAnimationType = enterAnimationType
		self.cachedEnterAnimationSlideDirection = slideDirection
		self.cachedEnterAnimationDuration = enterDuration
		self.cachedEnterAnimationFeedWidth = feedWidth
		self.cachedEnterAnimationRowHeight = rowHeight
		animationChanged = true
	end

	if not self.EnterAnimation then
		self.EnterAnimation = self:CreateAnimationGroup()
	end

	if animationChanged then
		self.EnterAnimation:Stop()
		self.EnterAnimation:RemoveAnimations()
		self.EnterAnimation:SetToFinalAlpha(true)
		self.EnterAnimation:SetScript("OnPlay", function()
			self.waiting = false
			self:ElementsVisible()
		end)
		self.EnterAnimation:SetScript("OnFinished", function()
			self:HighlightIcon()
			self:ResetFadeOut()
			if self.updatePending then
				self:UpdateQuantity()
			end
			if self:IsStaggeredEnter() then
				if self._next then
					self._next.waiting = false
					self._next:Enter()
				end
			end
		end)

		if enterAnimationType == G_RLF.EnterAnimationType.NONE then
			self.EnterAnimation.noop = self.EnterAnimation:CreateAnimation()
			self.EnterAnimation.fadeIn = nil
			self.EnterAnimation.slideIn = nil
			self:SetAlpha(1)
			return
		end

		-- Fade In unless explicitly disabled
		if enterAnimationType ~= G_RLF.EnterAnimationType.NONE then
			self.EnterAnimation.noop = nil
			self.EnterAnimation.slideIn = nil
			self.EnterAnimation.fadeIn = self.EnterAnimation:CreateAnimation("Alpha")
			self.EnterAnimation.fadeIn:SetFromAlpha(0)
			self.EnterAnimation.fadeIn:SetToAlpha(1)
			self.EnterAnimation.fadeIn:SetDuration(enterDuration)
			self.EnterAnimation.fadeIn:SetSmoothing("IN_OUT")
			self.EnterAnimation.fadeIn:SetScript("OnFinished", function()
				self:SetAlpha(1)
			end)
		end

		if enterAnimationType == G_RLF.EnterAnimationType.SLIDE then
			self.EnterAnimation:SetScript("OnPlay", function()
				self:ElementsInvisible()
			end)
			self.EnterAnimation:SetScript("OnFinished", function()
				self:FadeInElements()
				if self:IsStaggeredEnter() then
					if self._next then
						self._next.waiting = false
						self._next:Enter()
					end
				end
			end)

			self.EnterAnimation.slideIn = self.EnterAnimation:CreateAnimation("Translation")

			local initialOffsetX, initialOffsetY = 0, 0

			-- Determine the initial offset based on slide direction
			if slideDirection == G_RLF.SlideDirection.LEFT then
				initialOffsetX = feedWidth
			elseif slideDirection == G_RLF.SlideDirection.RIGHT then
				initialOffsetX = -feedWidth
			elseif slideDirection == G_RLF.SlideDirection.UP then
				initialOffsetY = -rowHeight
			elseif slideDirection == G_RLF.SlideDirection.DOWN then
				initialOffsetY = rowHeight
			end

			self.EnterAnimation.slideIn:SetOffset(-initialOffsetX, -initialOffsetY) -- Opposite of initial to slide to the final position
			self.EnterAnimation.slideIn:SetDuration(enterDuration)
			self.EnterAnimation.slideIn:SetSmoothing("OUT")

			-- Set the starting position before the animation begins
			self.EnterAnimation.slideIn:SetScript("OnPlay", function()
				if slideDirection == G_RLF.SlideDirection.LEFT or slideDirection == G_RLF.SlideDirection.RIGHT then
					self:SetPoint(slideDirection == G_RLF.SlideDirection.LEFT and "LEFT" or "RIGHT", initialOffsetX, 0)
				elseif slideDirection == G_RLF.SlideDirection.UP or slideDirection == G_RLF.SlideDirection.DOWN then
					if self.opposite then
						self:SetPoint(self.anchorPoint, self.anchorTo, self.opposite, 0, initialOffsetY)
					else
						self:SetPoint(self.anchorPoint, self.anchorTo, self.anchorPoint, 0, initialOffsetY)
					end
				end
			end)

			-- Reset the final position after the animation completes
			self.EnterAnimation.slideIn:SetScript("OnFinished", function()
				self:ClearAllPoints()
				self:UpdatePosition(LootDisplayFrame)
				self.waiting = false
			end)
		end
	end
end

function LootDisplayRowMixin:StyleIconHighlight()
	if not self.glowTexture then
		-- Create the glow texture
		self.glowTexture = self.Icon:CreateTexture(nil, "OVERLAY")
		self.glowTexture:SetDrawLayer("OVERLAY", 7)
		self.glowTexture:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
		self.glowTexture:SetPoint("CENTER", self.Icon, "CENTER", 0, 0)
		self.glowTexture:SetBlendMode("ADD") -- "ADD" is often better for glow effects
		self.glowTexture:SetAlpha(0.75)
		self.glowTexture:SetTexCoord(0.00781250, 0.50781250, 0.27734375, 0.52734375)
	end

	self.glowTexture:SetSize(self.Icon:GetWidth() * 1.75, self.Icon:GetHeight() * 1.75)
	self.glowTexture:Hide()

	-- Create the animation group if it doesn't exist
	if not self.glowAnimationGroup then
		self.glowAnimationGroup = self.glowTexture:CreateAnimationGroup()
		self.glowAnimationGroup:SetLooping("BOUNCE")
	end

	if not self.glowAnimationGroup.scaleUp then
		-- -- Scale up animation
		self.glowAnimationGroup.scaleUp = self.glowAnimationGroup:CreateAnimation("Scale")
		local factor = 1.1
		self.glowAnimationGroup.scaleUp:SetScaleFrom(1 / factor, 1 / factor)
		self.glowAnimationGroup.scaleUp:SetScaleTo(factor, factor)
		self.glowAnimationGroup.scaleUp:SetDuration(0.5)
		self.glowAnimationGroup.scaleUp:SetSmoothing("OUT_IN")
	end
end

function LootDisplayRowMixin:Styles()
	self:StyleIcon()
	RunNextFrame(function()
		self:StyleIconHighlight()
	end)
	self:StyleUnitPortrait()
	self:StyleText()
end

function LootDisplayRowMixin:BootstrapFromElement(element)
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
		self.unit = unit
	end

	self.id = key
	self.amount = quantity
	self.type = element.type

	if isLink then
		local extraWidthStr = " x" .. self.amount
		if itemCount then
			extraWidthStr = extraWidthStr .. " (" .. itemCount .. ")"
		end

		local extraWidth = G_RLF:CalculateTextWidth(extraWidthStr)
		if self.unit then
			local portraitSize = G_RLF.db.global.iconSize * 0.8
			extraWidth = extraWidth + portraitSize - (portraitSize / 2)
		end
		self.link = G_RLF:TruncateItemLink(textFn(), extraWidth)
		self.quality = quality
		text = textFn(0, self.link)
		self:SetupTooltip()
	else
		text = textFn()
	end

	if icon then
		self:UpdateIcon(key, icon, quality)
	end

	self:UpdateSecondaryText(secondaryTextFn)
	self:UpdateStyles()
	self:ShowText(text, r, g, b, a)
	self.highlight = highlight
	RunNextFrame(function()
		self:Enter()
	end)
	self:LogRow(logFn, text, true)
end

function LootDisplayRowMixin:LogRow(logFn, text, new)
	if logFn then
		RunNextFrame(function()
			logFn(text, self.amount, new)
		end)
	end
end

function LootDisplayRowMixin:ElementsVisible()
	self.Icon:SetAlpha(1)
	self.PrimaryText:SetAlpha(1)
	self.ItemCountText:SetAlpha(1)
	self.SecondaryText:SetAlpha(1)
	self.UnitPortrait:SetAlpha(1)
end

function LootDisplayRowMixin:ElementsInvisible()
	self.Icon:SetAlpha(0)
	self.PrimaryText:SetAlpha(0)
	self.ItemCountText:SetAlpha(0)
	self.SecondaryText:SetAlpha(0)
	self.UnitPortrait:SetAlpha(0)
end

function LootDisplayRowMixin:FadeInElements()
	self.ElementFadeInAnimation:Play()
end

function LootDisplayRowMixin:IsStaggeredEnter()
	local enterAnimationType = G_RLF.db.global.animations.enter.type
	local slideDirection = G_RLF.db.global.animations.enter.slide.direction

	if
		enterAnimationType == G_RLF.EnterAnimationType.SLIDE
		and (slideDirection == G_RLF.SlideDirection.UP or slideDirection == G_RLF.SlideDirection.DOWN)
	then
		return true
	end
end

function LootDisplayRowMixin:IsPreviousRowEntering()
	if not self._prev then
		return false
	end

	if not self._prev.waiting then
		if not self._prev.EnterAnimation then
			return false
		end
		if not self._prev.EnterAnimation:IsPlaying() then
			return false
		end
	end

	return true
end

function LootDisplayRowMixin:Enter()
	self.EnterAnimation:Stop()
	self.ElementFadeInAnimation:Stop()
	self.FadeOutAnimation:Stop()
	if not self:IsStaggeredEnter() or not self.waiting then
		RunNextFrame(function()
			self:Show()
			self.EnterAnimation:Play()
		end)
		return
	end
	if self:IsPreviousRowEntering() then
		self:Hide()
		return
	end
	RunNextFrame(function()
		self:Show()
		self.EnterAnimation:Play()
	end)
end

function LootDisplayRowMixin:HandlerOnRightClick()
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
	self:Styles()
	if self.icon and G_RLF.iconGroup then
		G_RLF.iconGroup:ReSkin(self.Icon)
	end
end

function LootDisplayRowMixin:UpdateEnterAnimation()
	self:StyleEnterAnimation()
end

function LootDisplayRowMixin:UpdateFadeoutDelay()
	self:StyleFadeOutAnimation()
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

function LootDisplayRowMixin:UpdateQuantity(element)
	-- Update existing entry
	local text = element.textFn(self.amount, self.link)
	self.amount = self.amount + element.quantity
	local r, g, b, a = element.r, element.g, element.b, element.a

	self:UpdateSecondaryText(element.secondaryTextFn)
	self:UpdateItemCount(element)
	self:ShowText(text, r, g, b, a)

	if self.PrimaryText:GetAlpha() < 1 then
		self.updatePending = true
		return
	end
	if self.EnterAnimation and self.EnterAnimation:IsPlaying() then
		self.pendingUpdate = true
		return
	end
	if self.ElementFadeInAnimation and self.ElementFadeInAnimation:IsPlaying() then
		self.pendingUpdate = true
		return
	end
	self.pendingUpdate = false
	if not G_RLF.db.global.disableRowHighlight then
		self.HighlightAnimation:Stop()
		self.HighlightAnimation:Play()
	end
	if self.FadeOutAnimation:IsPlaying() then
		self.FadeOutAnimation:Stop()
		self.FadeOutAnimation:Play()
	end

	self:LogRow(logFn, text, false)
end

function LootDisplayRowMixin:UpdateItemCount(element)
	if element.type == "ItemLoot" and not element.unit then
		local itemDb = G_RLF.db.global.item
		if not itemDb.itemCountTextEnabled then
			return
		end

		RunNextFrame(function()
			local itemCount = C_Item.GetItemCount(element.key, true, false, true, true)
			row:ShowItemCountText(itemCount, {
				color = G_RLF:RGBAToHexFormat(unpack(itemDb.itemCountTextColor)),
				wrapChar = itemDb.itemCountTextWrapChar,
			})
		end)
		return
	end

	if element.type == "Currency" then
		local currencyDb = G_RLF.db.global.currency
		if not currencyDb.currencyTotalTextEnabled then
			return
		end
		RunNextFrame(function()
			row:ShowItemCountText(element.totalCount, {
				color = G_RLF:RGBAToHexFormat(unpack(currencyDb.currencyTotalTextColor)),
				wrapChar = currencyDb.currencyTotalTextWrapChar,
			})
		end)
		return
	end

	if element.type == "Reputation" and element.repLevel then
		local repDb = G_RLF.db.global.rep
		if not repDb.repLevelTextEnabled then
			return
		end
		RunNextFrame(function()
			row:ShowItemCountText(element.repLevel, {
				color = G_RLF:RGBAToHexFormat(unpack(repDb.repLevelColor)),
				wrapChar = repDb.repLevelTextWrapChar,
			})
		end)
		return
	end

	if element.type == "Experience" and element.currentLevel then
		local xpDb = G_RLF.db.global.xp
		if not xpDb.currentLevelTextEnabled then
			return
		end
		RunNextFrame(function()
			row:ShowItemCountText(element.currentLevel, {
				color = G_RLF:RGBAToHexFormat(unpack(xpDb.currentLevelColor)),
				wrapChar = xpDb.currentLevelTextWrapChar,
			})
		end)
		return
	end

	if element.type == "Professions" then
		local profDb = G_RLF.db.global.prof
		if not profDb.skillTextEnabled then
			return
		end
		RunNextFrame(function()
			row:ShowItemCountText(row.amount, {
				color = G_RLF:RGBAToHexFormat(unpack(profDb.skillColor)),
				wrapChar = profDb.skillTextWrapChar,
				showSign = true,
			})
		end)
		return
	end
end

function LootDisplayRowMixin:UpdatePosition(frame)
	-- Position the new row at the bottom (or top if growing down)
	local vertDir, opposite, yOffset = frame.vertDir, frame.opposite, frame.yOffset
	self:ClearAllPoints()
	if self._prev then
		self:SetPoint(vertDir, self._prev, opposite, 0, yOffset)
		self.anchorPoint = vertDir
		self.opposite = opposite
		self.yOffset = yOffset
		self.anchorTo = self._prev
		self:SetFrameLevel(self._prev:GetFrameLevel() - 1)
	else
		self:SetPoint(vertDir, frame, vertDir)
		self.anchorPoint = vertDir
		self.opposite = nil
		self.yOffset = nil
		self.anchorTo = frame
		self:SetFrameLevel(10000)
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
			_next.anchorPoint = vertDir
			_next.opposite = opposite
			_next.yOffset = yOffset
			_next.anchorTo = _prev
			_next:SetFrameLevel(_prev:GetFrameLevel() - 1)
		else
			_next:SetPoint(vertDir, frame, vertDir)
			_next.anchorPoint = vertDir
			_next.opposite = nil
			_next.yOffset = nil
			_next.anchorTo = frame
			_next:SetFrameLevel(10000)
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
				self:ShowItemCountText(itemCount, { wrapChar = G_RLF.db.global.item.itemCountTextWrapChar })
			end
		end
	end)
end

function LootDisplayRowMixin:ShowItemCountText(itemCount, options)
	local WrapChar = G_RLF.WrapCharEnum
	options = options or {}
	local color = options.color or G_RLF:RGBAToHexFormat(unpack({ 0.737, 0.737, 0.737, 1 }))
	local wrapChar = options.wrapChar or WrapChar.DEFAULT
	local showSign = options.showSign or false

	local sChar, eChar
	if wrapChar == WrapChar.SPACE then
		sChar, eChar = " ", " "
	elseif wrapChar == WrapChar.PARENTHESIS then
		sChar, eChar = "(", ")"
	elseif wrapChar == WrapChar.BRACKET then
		sChar, eChar = "[", "]"
	elseif wrapChar == WrapChar.BRACE then
		sChar, eChar = "{", "}"
	elseif wrapChar == WrapChar.ANGLE then
		sChar, eChar = "<", ">"
	elseif wrapChar == WrapChar.BAR then
		sChar, eChar = "|", "|"
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
			local iconSize = G_RLF.db.global.iconSize
			-- Handle quality logic
			if not quality then
				self.Icon:SetItem(self.link)
			else
				self.Icon:SetItemButtonTexture(icon)
				self.Icon:SetItemButtonQuality(quality, self.link)
			end

			if self.Icon.IconOverlay then
				self.Icon.IconOverlay:SetSize(iconSize, iconSize)
			end
			if self.Icon.ProfessionQualityOverlay then
				self.Icon.ProfessionQualityOverlay:SetSize(iconSize, iconSize)
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
	if self.highlight then
		RunNextFrame(function()
			-- Show the glow texture and play the animation
			self.glowTexture:SetAlpha(0.75)
			self.glowTexture:Show()
			self.glowAnimationGroup:Play()
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
