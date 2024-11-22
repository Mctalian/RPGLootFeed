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

local ItemInfo = {}
ItemInfo.__index = ItemInfo
function ItemInfo:new(...)
	local self = {}
	setmetatable(self, ItemInfo)
	self.itemId, self.itemName, self.itemLink, self.itemQuality, self.itemLevel, self.itemMinLevel, self.itemType, self.itemSubType, self.itemStackCount, self.itemEquipLoc, self.itemTexture, self.sellPrice, self.classID, self.subclassID, self.bindType, self.expansionID, self.setID, self.isCraftingReagent =
		...
	if not self.itemName then
		return nil
	end
	if not self.itemId then
		self.itemId = C_Item.GetItemIDForItemInfo(self.itemLink)
	end
	return self
end

G_RLF.ItemInfo = ItemInfo

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

G_RLF.WrapCharEnum = {
	DEFAULT = 0,
	SPACE = 1,
	PARENTHESIS = 2,
	BRACKET = 3,
	BRACE = 4,
	ANGLE = 5,
}

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

function G_RLF:RGBAToHexFormat(r, g, b, a)
	local red = string.format("%02X", math.floor(r * 255))
	local green = string.format("%02X", math.floor(g * 255))
	local blue = string.format("%02X", math.floor(b * 255))
	local alpha = string.format("%02X", math.floor((a or 1) * 255)) -- Default alpha to 1 if not provided

	-- Return in WoW format with |c prefix
	return "|c" .. alpha .. red .. green .. blue
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
