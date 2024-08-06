LootInfo = {}
LootInfo.__index = LootInfo

function isTable(arg)
    return type(arg) == "table"
end

-- Constructor
function LootInfo:new(data)
    if not isTable(data) then
        return
    end
    local instance = setmetatable({}, LootInfo)
    for key, value in pairs(data) do
        instance[key] = value
    end
    return instance
end

-- Example method to print all members
function LootInfo:printMembers()
    for key, value in pairs(self) do
        if key ~= "__index" then -- Skip the metatable index field
            print(key .. ": " .. tostring(value))
        end
    end
end

return LootInfo