---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

local version = 3

local migration = {}

function migration:run()
	if not G_RLF:ShouldRunMigration(version) then
		return
	end

	G_RLF.DbMigrations:Migrate(G_RLF.db, "global.sizing.feedWidthedWidth", "global.sizing.feedWidth")
end

G_RLF.migrations[version] = migration

return migration
