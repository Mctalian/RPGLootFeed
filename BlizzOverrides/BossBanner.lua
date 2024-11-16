local addonName, G_RLF = ...

local BossBannerOverride = G_RLF.RLF:NewModule("BossBanner", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")

function BossBannerOverride:OnInitialize()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "BossBannerHook")
end

local bossBannerAttempts = 0
function BossBannerOverride:BossBannerHook()
	if self:IsHooked(BossBanner, "OnEvent") then
		return
	end
	if BossBanner then
		self:RawHookScript(BossBanner, "OnEvent", "InterceptBossBannerAlert", true)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	else
		bossBannerAttempts = G_RLF.retryHook(self, "BossBannerHook", bossBannerAttempts, "BossBannerAlertUnavailable")
	end
end

function BossBannerOverride:InterceptBossBannerAlert(s, event, ...)
	if G_RLF.db.global.bossBannerConfig == G_RLF.DisableBossBanner.FULLY_DISABLE then
		return
	end

	if
		G_RLF.db.global.bossBannerConfig == G_RLF.DisableBossBanner.DISABLE_LOOT
		and event == "ENCOUNTER_LOOT_RECEIVED"
	then
		return
	end

	local _, _, _, _, playerName, _ = ...
	local myGuid = GetPlayerGuid()
	local myName, _ = GetNameAndServerNameFromGUID(myGuid)
	if
		G_RLF.db.global.bossBannerConfig == G_RLF.DisableBossBanner.DISABLE_MY_LOOT
		and event == "ENCOUNTER_LOOT_RECEIVED"
		and playerName == myName
	then
		return
	end

	if
		G_RLF.db.global.bossBannerConfig == G_RLF.DisableBossBanner.DISABLE_GROUP_LOOT
		and event == "ENCOUNTER_LOOT_RECEIVED"
		and playerName ~= myName
	then
		return
	end
	-- Call the original AddAlert function if not blocked
	self.hooks[BossBanner].OnEvent(s, event, ...)
end

return BossBannerOverride
