local addonName, G_RLF = ...

function G_RLF:fn(func, ...)
	local s = self
	local function errorhandler(err)
		local suffix = "\n\n==== Addon Info " .. addonName .. " " .. G_RLF.addonVersion .. " ====\n\n"
		local status, trace = pcall(function()
			local logger = G_RLF.RLF:GetModule("Logger")
			if s.moduleName then
				return logger:Trace(s.moduleName)
			end
			return nil
		end)
		if status and trace then
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
	else
		error("fn: func is not a function")
	end
end

local acr = LibStub("AceConfigRegistry-3.0")
function G_RLF:NotifyChange(...)
	acr:NotifyChange(...)
end

function G_RLF:Print(...)
	G_RLF.RLF:Print(...)
end

function G_RLF:IsRetail()
	return WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
end

function G_RLF:IsClassic()
	return WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
end

function G_RLF:IsCataClassic()
	return WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC
end

function G_RLF:SendMessage(...)
	local args = { ... }
	RunNextFrame(function()
		G_RLF.RLF:SendMessage(unpack(args))
	end)
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
	local args = { ... }
	RunNextFrame(function()
		G_RLF:SendMessage("RLF_LOG", args)
	end)
end

function G_RLF:LogDebug(...)
	log(G_RLF.LogLevel.debug, ...)
end

function G_RLF:LogInfo(...)
	log(G_RLF.LogLevel.info, ...)
end

function G_RLF:LogWarn(...)
	log(G_RLF.LogLevel.warn, ...)
end

function G_RLF:LogError(...)
	log(G_RLF.LogLevel.error, ...)
end

function G_RLF:CreatePatternSegmentsForStringNumber(localeString)
	local preStart, preEnd = string.find(localeString, "%%s")
	local prePattern = string.sub(localeString, 1, preStart - 1)
	local midStart, midEnd = string.find(localeString, "%%d", preEnd + 1)
	local midPattern = string.sub(localeString, preEnd + 1, midStart - 1)
	local postPattern = string.sub(localeString, midEnd + 1)
	return { prePattern, midPattern, postPattern }
end

function G_RLF:ExtractDynamicsFromPattern(localeString, segments)
	local prePattern, midPattern, postPattern = unpack(segments)
	local preMatchStart, preMatchEnd = string.find(localeString, prePattern, 1, true)
	if preMatchStart then
		local msgLoop = localeString:sub(preMatchEnd + 1)
		local midMatchStart, midMatchEnd = string.find(msgLoop, midPattern, 1, true)
		if midMatchStart then
			local postMatchStart, postMatchEnd = string.find(msgLoop, postPattern, midMatchEnd, true)
			if postMatchStart then
				local str = msgLoop:sub(1, midMatchStart - 1)
				local num
				if midMatchEnd == postMatchStart then
					num = msgLoop:sub(midMatchEnd + 1)
				else
					num = msgLoop:sub(midMatchEnd + 1, postMatchStart - 1)
				end
				return str, tonumber(num)
			end
		end
	end

	return nil, nil
end
