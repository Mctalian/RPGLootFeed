local addonName, G_RLF = ...

function G_RLF:ShouldRunMigration(version)
	if G_RLF.db.global.migrationVersion >= version then
		G_RLF:LogDebug("Skipping DB migration from version " .. G_RLF.db.global.migrationVersion .. " to " .. version)
		return false
	end

	G_RLF:LogDebug("Migrating DB from version " .. G_RLF.db.global.migrationVersion .. " to " .. version)
	return true
end
