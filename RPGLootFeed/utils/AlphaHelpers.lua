---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

function G_RLF.dump(o, depth)
	depth = depth or 0
	local indent = string.rep("  ", depth)

	if type(o) == "table" then
		local s = "{\n"
		-- Collect and sort keys
		local keys = {}
		for k in pairs(o) do
			table.insert(keys, k)
		end
		table.sort(keys, function(a, b)
			return tostring(a) < tostring(b)
		end)

		-- Iterate over sorted keys
		for _, k in ipairs(keys) do
			local key = type(k) == "number" and k or '"' .. k .. '"'
			s = s .. indent .. "  [" .. key .. "] = " .. G_RLF.dump(o[k], depth + 1) .. ",\n"
		end
		return s .. indent .. "}"
	elseif type(o) == "string" then
		return '"' .. o .. '"' -- Wrap strings in quotes
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
		local durationThreshold = 0.8 -- in milliseconds
		if G_RLF:IsCataClassic() then
			--- Cata seems to be slower to process than Retail
			durationThreshold = 10 -- in milliseconds
		end
		if G_RLF:IsMoPClassic() then
			--- MoP seems to be slightly slower to process than Retail
			durationThreshold = 5 -- in milliseconds
		end
		if duration > durationThreshold then
			G_RLF:Print(string.format("%s took %.2f ms", funcName, endTime - startTime))
		end

		return unpack(result)
	end
end

--@alpha@
_G.G_RLF = G_RLF
--@end-alpha@
