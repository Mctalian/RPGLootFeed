---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

local version = 5

local migration = {}

function migration:run()
	if not G_RLF:ShouldRunMigration(version) then
		return
	end

	-- Clear the faction map to ensure it is rebuilt with the new account-wide support
	G_RLF.db.locale.factionMap = {}

	G_RLF.db.global.migrationVersion = version
end

G_RLF.migrations[version] = migration

return migration
