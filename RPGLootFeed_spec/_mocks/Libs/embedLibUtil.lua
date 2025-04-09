local busted = require("busted")
local stub = busted.stub
local function embedLibs(addonOrModule, ...)
	for _, lib in ipairs({ ... }) do
		if lib == "AceAddon-3.0" then
			stub(addonOrModule, "Disable")
			stub(addonOrModule, "DisableModule")
			stub(addonOrModule, "Enable")
			stub(addonOrModule, "EnableModule")
			stub(addonOrModule, "GetModule").returns({})
			stub(addonOrModule, "GetName")
			stub(addonOrModule, "IsEnabled").returns(true)
			stub(addonOrModule, "IterateModules")
			stub(addonOrModule, "NewModule", function(self, name, ...)
				local module = {}
				embedLibs(module, "AceAddon-3.0", ...)
				module.moduleName = name
				module.fn = function(s, func, ...)
					if type(func) == "function" then
						return xpcall(func, _G.handledError, ...)
					end
				end
				return module
			end)
			stub(addonOrModule, "SetDefaultModuleLibraries")
			stub(addonOrModule, "SetDefaultModulePrototype")
			stub(addonOrModule, "SetDefaultModuleState")
			stub(addonOrModule, "SetEnabledState")
			stub(addonOrModule, "GetAddon")
			stub(addonOrModule, "IterateAddonStatus")
			stub(addonOrModule, "IterateAddons")
			stub(addonOrModule, "NewAddon", function(self, name, ...)
				local addon = {}
				embedLibs(addon, ...)
				return addon
			end)
		end
		if lib == "AceBucket-3.0" then
			stub(addonOrModule, "RegisterBucketEvent")
			stub(addonOrModule, "RegisterBucketMessage")
			stub(addonOrModule, "UnregisterAllBuckets")
			stub(addonOrModule, "UnregisterBucket")
		end
		if lib == "AceConsole-3.0" then
			stub(addonOrModule, "IterateChatCommands")
			stub(addonOrModule, "Print")
			stub(addonOrModule, "Printf")
			stub(addonOrModule, "RegisterChatCommand")
			stub(addonOrModule, "UnregisterChatCommand")
		end
		if lib == "AceComm-3.0" then
			stub(addonOrModule, "RegisterComm")
			stub(addonOrModule, "UnregisterComm")
			stub(addonOrModule, "UnregisterAllComm")
			stub(addonOrModule, "SendCommMessage")
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
		if lib == "AceLocale-3.0" then
			stub(addonOrModule, "GetLocale").returns({})
			stub(addonOrModule, "NewLocale").returns({})
		end
		if lib == "AceTimer-3.0" then
			stub(addonOrModule, "CancelAllTimers")
			stub(addonOrModule, "CancelTimer")
			stub(addonOrModule, "ScheduleRepeatingTimer")
			stub(addonOrModule, "ScheduleTimer")
			stub(addonOrModule, "TimeLeft")
		end
	end
end

return embedLibs
