---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

---Determines if a migration should be run based on the current DB version
---@param version number
---@return boolean
function G_RLF:ShouldRunMigration(version)
	local lastMigration = G_RLF.db.global.migrationVersion
	if lastMigration >= version then
		G_RLF:LogDebug("Skipping DB migration from version " .. lastMigration .. " to " .. version)
		return false
	end

	G_RLF:LogDebug("Migrating DB from version " .. lastMigration .. " to " .. version)
	return true
end
