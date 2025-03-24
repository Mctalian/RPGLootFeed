---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

---@class RLF_DbMigrations
local DbMigrations = {}

-- Helper function to interpret a key part (convert to number if numeric)
local function interpretKey(key)
	local num = tonumber(key)
	return num ~= nil and num or key -- Return number if key is numeric, otherwise string
end

-- Helper function to get or set a nested table value by path
local function getPath(db, path)
	local current = db
	for part in path:gmatch("[^.]+") do
		current = current[interpretKey(part)]
		if current == nil then
			return nil
		end
	end
	return current
end

local function setPath(db, path, value)
	local parts = {}
	for part in path:gmatch("[^.]+") do
		table.insert(parts, part)
	end

	local lastKey = table.remove(parts)
	local current = db

	for _, part in ipairs(parts) do
		local key = interpretKey(part)
		if current[key] == nil then
			current[key] = {}
		end
		current = current[key]
	end

	current[interpretKey(lastKey)] = value
end

local function clearPath(db, path)
	local parts = {}
	for part in path:gmatch("[^.]+") do
		table.insert(parts, part)
	end

	local lastKey = table.remove(parts)
	local current = db

	for _, part in ipairs(parts) do
		current = current[interpretKey(part)]
		if not current then
			return
		end
	end

	current[interpretKey(lastKey)] = nil
end

--- Migrate function that takes paths as strings
--- @param db RLF_DB
--- @param oldPath string
--- @param newPath string
function DbMigrations:Migrate(db, oldPath, newPath)
	local oldValue = getPath(db, oldPath)
	if oldValue ~= nil then
		setPath(db, newPath, oldValue)
		clearPath(db, oldPath)
	end
end

G_RLF.DbMigrations = DbMigrations
G_RLF.migrations = {}

return DbMigrations
