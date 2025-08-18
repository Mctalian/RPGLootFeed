---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

---@class RLF_DbMigrations
local DbMigrations = {}

local getPath = G_RLF.ConfigCommon.DbUtils.getPath
local setPath = G_RLF.ConfigCommon.DbUtils.setPath
local clearPath = G_RLF.ConfigCommon.DbUtils.clearPath

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
