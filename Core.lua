local addonName, G_RLF = ...

-- Define the global scope early so that the whole addon can use it
local dbName = addonName .. "DB"
local localeName = addonName .. "Locale"

local xpcall = xpcall

local function errorhandler(err)
	local suffix = "\n\n==== Addon Info " .. addonName .. " " .. G_RLF.addonVersion .. " ====\n\n"
	suffix = suffix .. G_RLF.L["Issues"] .. "\n\n"

	return geterrorhandler()(err .. suffix)
end

function G_RLF:fn(func, ...)
	-- Borrowed from AceAddon-3.0
	if type(func) == "function" then
		return xpcall(func, errorhandler, ...)
	end
end

G_RLF.RLF = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")
G_RLF.RLF:SetDefaultModuleState(true)
G_RLF.RLF:SetDefaultModulePrototype({
	getLogger = function(self)
		return G_RLF.RLF:GetModule("Logger")
	end,
	fn = function(s, func, ...)
		local function errorhandler(err)
			local suffix = "\n\n==== Addon Info " .. addonName .. " " .. G_RLF.addonVersion .. " ====\n\n"
			local status, trace = pcall(function()
				return s:getLogger():Trace(s.moduleName)
			end)
			if status then
				suffix = suffix .. "Log traces related to " .. s.moduleName .. "\n"
				suffix = suffix .. "-------------------------------------------------\n"
				suffix = suffix .. trace
				suffix = suffix .. "-------------------------------------------------\n\n"
			end
			suffix = suffix .. G_RLF.L["Issues"] .. "\n\n"

			return geterrorhandler()(err .. suffix)
		end

		-- Borrowed from AceAddon-3.0
		if type(func) == "function" then
			return xpcall(func, errorhandler, ...)
		end
	end,
})
G_RLF.dbName = dbName
G_RLF.localeName = localeName
G_RLF.addonVersion = "@project-version@-@project-revision@-@project-abbreviated-hash@"
G_RLF.DisableBossBanner = {
	ENABLED = 0,
	FULLY_DISABLE = 1,
	DISABLE_LOOT = 2,
	DISABLE_MY_LOOT = 3,
	DISABLE_GROUP_LOOT = 4,
}

G_RLF.lsm = LibStub("LibSharedMedia-3.0")
G_RLF.Masque = LibStub and LibStub("Masque", true)
G_RLF.iconGroup = Masque and Masque:Group(addonName)

local acr = LibStub("AceConfigRegistry-3.0")

function G_RLF:NotifyChange(...)
	acr:NotifyChange(...)
end

function G_RLF:SendMessage(...)
	G_RLF.RLF:SendMessage(...)
end

function G_RLF:Print(...)
	G_RLF.RLF:Print(...)
end

--@alpha@
function G_RLF:ProfileFunction(func, funcName)
	return function(...)
		local startTime = debugprofilestop()
		local result = { func(...) }
		local endTime = debugprofilestop()
		local duration = endTime - startTime
		if duration > 0.3 then
			G_RLF:Print(string.format("%s took %.2f ms", funcName, endTime - startTime))
		end

		return unpack(result)
	end
end
--@end-alpha@
