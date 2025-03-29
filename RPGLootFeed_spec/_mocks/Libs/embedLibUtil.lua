local busted = require("busted")
local stub = busted.stub
return function(addonOrModule, ...)
	for _, lib in ipairs({ ... }) do
		if lib == "AceBucket-3.0" then
			stub(addonOrModule, "RegisterBucketMessage")
			stub(addonOrModule, "UnregisterBucket")
		end
		if lib == "AceEvent-3.0" then
			stub(addonOrModule, "RegisterEvent")
			stub(addonOrModule, "UnregisterEvent")
			stub(addonOrModule, "RegisterMessage")
			stub(addonOrModule, "SendMessage")
			stub(addonOrModule, "UnregisterMessage")
		end
		if lib == "AceHook-3.0" then
			stub(addonOrModule, "Hook")
			stub(addonOrModule, "HookScript")
			stub(addonOrModule, "IsHooked")
			stub(addonOrModule, "RawHook")
			stub(addonOrModule, "RawHookScript")
			stub(addonOrModule, "SecureHook")
			stub(addonOrModule, "SecureHookScript")
			stub(addonOrModule, "Unhook")
			stub(addonOrModule, "UnhookAll")
			addonOrModule.hooks = {}
		end
	end
end
