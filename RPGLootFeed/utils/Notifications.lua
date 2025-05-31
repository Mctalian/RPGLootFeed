---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

---@class RLF_Notification
---@field key string
---@field text string
---@field time number
---@field seen boolean

local unseen = 0

G_RLF.Notifications = {}

function G_RLF.Notifications:CheckForNotifications()
	if #G_RLF.db.global.notifications > 0 then
		for _, notification in ipairs(G_RLF.db.global.notifications) do
			if not notification.seen then
				G_RLF.Notifications:NotifyGlow()
				break
			end
		end

		unseen = G_RLF.Notifications:GetNumUnseenNotifications()
	end
end

function G_RLF.Notifications:AddNotification(key, text, secondaryText)
	local notification = {
		key = key,
		text = text,
		secondaryText = secondaryText or "",
		time = GetTime(),
		seen = false,
	}
	for i, v in ipairs(G_RLF.db.global.notifications) do
		if v.key == key then
			-- If the notification already exists, update it
			if v.seen then
				unseen = unseen + 1
			end
			G_RLF.db.global.notifications[i] = notification
			G_RLF.Notifications:NotifyGlow()
			return
		end
	end

	table.insert(G_RLF.db.global.notifications, notification)
	unseen = unseen + 1

	G_RLF.Notifications:NotifyGlow()
end

function G_RLF.Notifications:AckAllNotifications()
	if G_RLF.db.global.notifications then
		for i = #G_RLF.db.global.notifications, 1, -1 do
			if not G_RLF.db.global.notifications[i].seen then
				G_RLF.db.global.notifications[i].seen = true
				unseen = unseen - 1
			end
		end
	end

	G_RLF.Notifications:StopNotifyGlow()
end

function G_RLF.Notifications:AckNotification(index)
	if G_RLF.db.global.notifications and G_RLF.db.global.notifications[index] then
		G_RLF.db.global.notifications[index].seen = true
		unseen = unseen - 1
	end
	if unseen == 0 then
		G_RLF.Notifications:StopNotifyGlow()
	end
end

function G_RLF.Notifications:GetNumUnseenNotifications()
	local count = 0
	if G_RLF.db.global.notifications then
		for _, notification in ipairs(G_RLF.db.global.notifications) do
			if not notification.seen then
				count = count + 1
			end
		end
	end
	unseen = count
	return unseen
end

function G_RLF.Notifications:RemoveSeenNotifications()
	if G_RLF.db.global.notifications then
		for i = #G_RLF.db.global.notifications, 1, -1 do
			if G_RLF.db.global.notifications[i].seen then
				table.remove(G_RLF.db.global.notifications, i)
			end
		end
	end

	if unseen == 0 then
		G_RLF.Notifications:StopNotifyGlow()
	end
end

function G_RLF.Notifications.GetButton()
	---@class RLF_MinimapButton: LibDBIcon.button, nil
	local button = nil

	if G_RLF.db.global.minimap.hide then
		if G_RLF.DBIcon:IsButtonCompartmentAvailable() and G_RLF.DBIcon:IsButtonInCompartment(addonName) then
			-- TODO: Figure out how to show notifications in an non-intrusive way when minimap button is hidden
		end
		G_RLF.DBIcon:Show(addonName)
	end

	button = G_RLF.DBIcon:GetMinimapButton(addonName) --[[@as RLF_MinimapButton]]

	return button
end

function G_RLF.Notifications:NotifyGlow()
	---@class RLF_MinimapButton
	local button = self:GetButton()

	if button == nil then
		local notifModule = G_RLF.RLF:GetModule("Notifications") --[[@as RLF_Notifications]]
		notifModule:ViewAllNotifications()
		return
	end

	if button and button.customGlow and button.customGlow.animGroup and button.customGlow.animGroup:IsPlaying() then
		-- If the glow animation is already playing, do nothing.
		return
	end

	if button then
		-- Check if a custom glow already exists
		if not button.customGlow then
			---@class RLF_MinimapButtonGlow: Texture
			button.customGlow = button:CreateTexture(nil, "OVERLAY")
			-- Set a custom circular glow texture; update the path if needed.
			button.customGlow:SetTexture("Interface/Glues/Models/UI_vulpera/Glow_gold_high")
			button.customGlow:SetBlendMode("ADD")
			-- Center the glow on the button and make it a bit larger.
			button.customGlow:SetPoint("CENTER", button, "CENTER", 0, 0)
			local size = button:GetWidth() * 2
			button.customGlow:SetSize(size, size)
		end

		-- Add a pulsing animation if it doesn't already exist.
		if not button.customGlow.animGroup then
			local ag = button.customGlow:CreateAnimationGroup()
			local anim = ag:CreateAnimation("Alpha")
			anim:SetFromAlpha(1)
			anim:SetToAlpha(0.5)
			anim:SetDuration(1)
			anim:SetOrder(1)
			ag:SetLooping("BOUNCE")
			button.customGlow.animGroup = ag
		end

		button.customGlow.animGroup:Play()
	end
end

function G_RLF.Notifications:StopNotifyGlow()
	---@class RLF_MinimapButton
	local button = self:GetButton()
	if button and button.customGlow then
		button.customGlow:Hide()
		button.customGlow.animGroup:Stop()
	end
	if G_RLF.db.global.minimap.hide then
		G_RLF.DBIcon:Hide(addonName)
	end
end
