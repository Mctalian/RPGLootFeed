local addonName, G_RLF = ...

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

local acr = LibStub("AceConfigRegistry-3.0")
function G_RLF:NotifyChange(...)
	acr:NotifyChange(...)
end

function G_RLF:SendMessage(...)
	local args = {...}
	RunNextFrame(function()
		G_RLF.RLF:SendMessage(unpack(args))
	end)
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

local function log(...)
	G_RLF:SendMessage("RLF_LOG", {...})
end

function G_RLF:LogDebug(...)
	log(G_RLF.LogLevel.debug , ...)
end

function G_RLF:LogInfo(...)
	log(G_RLF.LogLevel.info , ...)
end

function G_RLF:LogWarn(...)
	log(G_RLF.LogLevel.warn , ...)
end

function G_RLF:LogError(...)
	log(G_RLF.LogLevel.error , ...)
end
