local addonName, G_RLF = ...

function dump(o)
	if type(o) == "table" then
		local s = "{ "
		for k, v in pairs(o) do
			if type(k) ~= "number" then
				k = '"' .. k .. '"'
			end
			s = s .. "[" .. k .. "] = " .. dump(v) .. ","
		end
		return s .. "} "
	else
		return tostring(o)
	end
end

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
