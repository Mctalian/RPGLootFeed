---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

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
