---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

---@class RLF_Communications: RLF_Module, AceEvent-3.0, AceComm-3.0
local Communications = G_RLF.RLF:NewModule("Communications", "AceEvent-3.0", "AceComm-3.0")

function Communications:OnInitialize()
	G_RLF:LogDebug("Communications:OnInitialize")
	self:Enable()
end

function Communications:OnEnable()
	G_RLF:LogDebug("Communications:OnEnable")
	self.lastVersionEncountered = G_RLF.addonVersion
	self:RegisterComm(addonName)
	self:RegisterEvent("GROUP_JOINED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function Communications:OnDisable()
	G_RLF:LogDebug("Communications:OnDisable")
	self:UnregisterAllComm()
	self:UnregisterAllEvents()
end

function Communications:TransmitSay(message)
	G_RLF:LogDebug("TransmitSay " .. message)
	self:SendCommMessage(addonName, message, "SAY", nil, "BULK")
end

function Communications:TransmitYell(message)
	G_RLF:LogDebug("TransmitYell " .. message)
	self:SendCommMessage(addonName, message, "YELL", nil, "BULK")
end

--- Transmit to a specific channel
--- @param message string The message to transmit
--- @param channelId? number The channel ID to transmit to, defaults to the general channel
function Communications:TransmitChannel(message, channelId)
	G_RLF:LogDebug("TransmitChannel " .. message)
	local channelId = channelId or C_ChatInfo.GetGeneralChannelID()
	self:SendCommMessage(addonName, message, "CHANNEL", tostring(channelId), "BULK")
end

function Communications:TransmitWhisper(message, target)
	G_RLF:LogDebug("TransmitWhisper " .. message .. " to " .. target)
	self:SendCommMessage(addonName, message, "WHISPER", target)
end

function Communications:TransmitParty(message)
	G_RLF:LogDebug("TransmitParty " .. message)
	self:SendCommMessage(addonName, message, "PARTY", nil, "BULK")
end

function Communications:TransmitRaid(message)
	G_RLF:LogDebug("TransmitRaid " .. message)
	self:SendCommMessage(addonName, message, "RAID", nil, "BULK")
end

function Communications:TransmitGuild(message)
	G_RLF:LogDebug("TransmitGuild " .. message)
	self:SendCommMessage(addonName, message, "GUILD", nil, "BULK")
end

function Communications:TransmitInstance(message)
	G_RLF:LogDebug("TransmitInstance " .. message)
	self:SendCommMessage(addonName, message, "INSTANCE_CHAT", nil, "BULK")
end

local playerName = UnitName("player")
local versionPayload = string.format(G_RLF.CommsMessages.VERSION, G_RLF.addonVersion)
function Communications:OnCommReceived(prefix, payload, distribution, sender)
	if prefix == addonName then
		if sender == playerName then
			return
		end

		G_RLF:LogDebug("OnCommReceived " .. prefix .. " " .. payload .. " " .. distribution .. " " .. sender)

		if string.sub(payload, 1, string.len(G_RLF.CommMessagePrefixes.VERSION)) then
			local versionFromPayload = payload:match(G_RLF.CommMessagePrefixes.VERSION .. " (%S+)")
			if not G_RLF:IsRLFStableRelease() then
				G_RLF:LogDebug("RLF is in alpha/beta, ignoring version check")
				return
			end

			if distribution ~= "WHISPER" then
				local versionCompare = G_RLF:CompareWithVersion(self.lastVersionEncountered, versionFromPayload)
				if versionCompare == G_RLF.VersionCompare.NEWER then
					self.lastVersionEncountered = versionFromPayload
					G_RLF.Notifications:AddNotification(
						G_RLF.NotificationKeys.VERSION,
						string.format(G_RLF.L["New version available"], versionFromPayload)
					)
				elseif versionCompare == G_RLF.VersionCompare.OLDER then
					self:TransmitWhisper(string.format(G_RLF.CommsMessages.VERSION, G_RLF.addonVersion), sender)
				end
			else
				local versionCompare = G_RLF:CompareWithVersion(self.lastVersionEncountered, versionFromPayload)
				if versionCompare == G_RLF.VersionCompare.NEWER then
					self.lastVersionEncountered = versionFromPayload
					G_RLF.Notifications:AddNotification(
						G_RLF.NotificationKeys.VERSION,
						string.format(G_RLF.L["New version available"], versionFromPayload)
					)
				end
			end
		end
	end
end

function Communications:QueryGroupVersion(versionPayload)
	if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and IsInInstance() then
		self:TransmitInstance(versionPayload)
	elseif IsInRaid() then
		self:TransmitRaid(versionPayload)
	elseif IsInGroup() then
		self:TransmitParty(versionPayload)
	end
end

function Communications:GROUP_JOINED(eventName, category, partyGUID)
	G_RLF:LogDebug(eventName, "WOWEVENT", self.moduleName, nil, eventName .. " " .. category .. " " .. partyGUID)

	local versionPayload = string.format(G_RLF.CommsMessages.VERSION, G_RLF.addonVersion)
	self:QueryGroupVersion(versionPayload)
end

function Communications:PLAYER_ENTERING_WORLD(eventName, isLogin, isReload)
	G_RLF:LogDebug(
		eventName,
		"WOWEVENT",
		self.moduleName,
		nil,
		eventName .. " " .. tostring(isLogin) .. " " .. tostring(isReload)
	)

	local versionPayload = string.format(G_RLF.CommsMessages.VERSION, G_RLF.addonVersion)
	self:QueryGroupVersion(versionPayload)
	if IsInGuild() then
		self:TransmitGuild(versionPayload)
	end
	if G_RLF:IsClassic() then
		self:TransmitYell(versionPayload)
	else
		self:TransmitChannel(versionPayload)
	end
end

return Communications
