local addonName, G_RLF = ...

G_RLF.retryHook = function(module, previousAttempts, hookFunctionName, localeKey)
	local attempts = previousAttempts

	if attempts < 30 then
		attempts = attempts + 1
		-- Keep checking until it's available
		module:ScheduleTimer(hookFunctionName, 1)
	else
		G_RLF:Print(G_RLF.L[localeKey])
		G_RLF:Print(G_RLF.L["Issues"])
	end

	return attempts
end
