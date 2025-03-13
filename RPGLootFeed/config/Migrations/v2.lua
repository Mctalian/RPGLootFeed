---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

local version = 2

local migration = {}

function migration:run()
	if not G_RLF:ShouldRunMigration(version) then
		return
	end

	G_RLF.DbMigrations:Migrate(
		G_RLF.db,
		"global.styling.disableRowHighlight",
		"global.animations.update.disableHighlight"
	)
end

G_RLF.migrations[version] = migration

return migration
