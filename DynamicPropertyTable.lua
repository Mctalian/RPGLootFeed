function DynamicPropertyTable(globalTable, defaultsTable)
	local proxy = {}

	setmetatable(proxy, {
		__index = function(_, key)
			-- Check if the key exists in defaults, handle dynamically
			if defaultsTable[key] ~= nil then
				local globalValue = globalTable[key]
				if globalValue ~= nil then
					return globalValue
				else
					return defaultsTable[key]
				end
			else
				return rawget(_, key)
			end
		end,
		__newindex = function(_, key, value)
			-- Update globalTable for dynamic properties
			if defaultsTable[key] ~= nil then
				globalTable[key] = value
			else
				rawset(_, key, value)
			end
		end,
	})

	return proxy
end
