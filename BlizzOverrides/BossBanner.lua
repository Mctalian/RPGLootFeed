local addonName, G_RLF = ...

local RLF = G_RLF.RLF

local bossBannerAttempts = 0

function RLF:BossBannerHook()
	if self:IsHooked(BossBanner, "OnEvent") then
		return
	end
	if BossBanner then
		self:RawHookScript(BossBanner, "OnEvent", "InterceptBossBannerAlert", true)
	else
		if bossBannerAttempts <= 30 then
			bossBannerAttempts = bossBannerAttempts + 1
			-- Keep checking until it's available
			self:ScheduleTimer("BossBannerHook", 1)
		else
			self:Print(G_RLF.L["BossBannerAlertUnavailable"])
			self:Print(G_RLF.L["Issues"])
		end
	end
end

function RLF:InterceptBossBannerAlert(s, event, ...)
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
