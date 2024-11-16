local addonName, G_RLF = ...

local LootToastOverride = G_RLF.RLF:NewModule("LootToasts", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")

function LootToastOverride:OnInitialize()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "LootToastHook")
end

local lootAlertAttempts = 0
function LootToastOverride:LootToastHook()
	if self:IsHooked(LootAlertSystem, "AddAlert") then
		return
	end
	if LootAlertSystem and LootAlertSystem.AddAlert then
		self:RawHook(LootAlertSystem, "AddAlert", "InterceptAddAlert", true)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	else
		lootAlertAttempts = G_RLF.retryHook(self, "LootToastHook", lootAlertAttempts, "AddLootAlertUnavailable")
	end
end

function LootToastOverride:InterceptAddAlert(frame, ...)
	if G_RLF.db.global.disableBlizzLootToasts then
		return
	end
	-- Call the original AddAlert function if not blocked
	self.hooks[LootAlertSystem].AddAlert(frame, ...)
end

return LootToastOverride
