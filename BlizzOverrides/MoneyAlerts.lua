local addonName, G_RLF = ...

local RLF = G_RLF.RLF

local moneyAlertAttempts = 0
function RLF:MoneyAlertHook()
	if RLF:IsHooked(MoneyWonAlertSystem, "AddAlert") then
		return
	end
	if MoneyWonAlertSystem and MoneyWonAlertSystem.AddAlert then
		RLF:RawHook(MoneyWonAlertSystem, "AddAlert", "InterceptMoneyAddAlert", true)
	else
		if moneyAlertAttempts <= 30 then
			moneyAlertAttempts = moneyAlertAttempts + 1
			-- Keep checking until it's available
			RLF:ScheduleTimer("MoneyAlertHook", 1)
		else
			RLF:Print(G_RLF.L["AddMoneyAlertUnavailable"])
			RLF:Print(G_RLF.L["Issues"])
		end
	end
end

function RLF:InterceptMoneyAddAlert(frame, ...)
	if G_RLF.db.global.disableBlizzMoneyAlerts then
		return
	end
	-- Call the original AddAlert function if not blocked
	RLF.hooks[MoneyWonAlertSystem].AddAlert(frame, ...)
end
