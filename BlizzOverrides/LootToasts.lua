local addonName, G_RLF = ...

local RLF = G_RLF.RLF

local lootAlertAttempts = 0
function RLF:LootToastHook()
	if RLF:IsHooked(LootAlertSystem, "AddAlert") then
		return
	end
	if LootAlertSystem and LootAlertSystem.AddAlert then
		RLF:RawHook(LootAlertSystem, "AddAlert", "InterceptAddAlert", true)
	else
		if lootAlertAttempts <= 30 then
			lootAlertAttempts = lootAlertAttempts + 1
			-- Keep checking until it's available
			RLF:ScheduleTimer("LootToastHook", 1)
		else
			RLF:Print(G_RLF.L["AddLootAlertUnavailable"])
			RLF:Print(G_RLF.L["Issues"])
		end
	end
end

function RLF:InterceptAddAlert(frame, ...)
	if G_RLF.db.global.disableBlizzLootToasts then
		return
	end
	-- Call the original AddAlert function if not blocked
	RLF.hooks[LootAlertSystem].AddAlert(frame, ...)
end
