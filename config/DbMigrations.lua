local addonName, G_RLF = ...

local DbMigrations = {}

-- Helper function to get or set a nested table value by path
local function getPath(db, path)
	local current = db
	for part in path:gmatch("[^.]+") do
		current = current[part]
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
		if current[part] == nil then
			current[part] = {}
		end
		current = current[part]
	end

	current[lastKey] = value
end

local function clearPath(db, path)
	local parts = {}
	for part in path:gmatch("[^.]+") do
		table.insert(parts, part)
	end

	local lastKey = table.remove(parts)
	local current = db

	for _, part in ipairs(parts) do
		current = current[part]
		if not current then
			return
		end
	end

	current[lastKey] = nil
end

-- Migrate function that takes paths as strings
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
