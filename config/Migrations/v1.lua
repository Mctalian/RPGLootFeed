local addonName, G_RLF = ...

local version = 1

local migration = {}

function migration:run()
	if not G_RLF:ShouldRunMigration(version) then
		return
	end

	G_RLF.DbMigrations:Migrate(G_RLF.db, "global.fadeOutDelay", "global.animations.exit.fadeOutDelay")
	G_RLF.DbMigrations:Migrate(G_RLF.db, "global.enableAutoLoot", "global.blizzOverrides.enableAutoLoot")
	G_RLF.DbMigrations:Migrate(
		G_RLF.db,
		"global.disableBlizzLootToasts",
		"global.blizzOverrides.disableBlizzLootToasts"
	)
	G_RLF.DbMigrations:Migrate(
		G_RLF.db,
		"global.disableBlizzMoneyAlerts",
		"global.blizzOverrides.disableBlizzMoneyAlerts"
	)
	G_RLF.DbMigrations:Migrate(G_RLF.db, "global.bossBannerConfig", "global.blizzOverrides.bossBannerConfig")
	G_RLF.DbMigrations:Migrate(G_RLF.db, "global.relativePoint", "global.positioning.relativePoint")
	G_RLF.DbMigrations:Migrate(G_RLF.db, "global.anchorPoint", "global.positioning.anchorPoint")
	G_RLF.DbMigrations:Migrate(G_RLF.db, "global.xOffset", "global.positioning.xOffset")
	G_RLF.DbMigrations:Migrate(G_RLF.db, "global.yOffset", "global.positioning.yOffset")
	G_RLF.DbMigrations:Migrate(G_RLF.db, "global.frameStrata", "global.positioning.frameStrata")
	G_RLF.DbMigrations:Migrate(G_RLF.db, "global.feedWidth", "global.sizing.feedWidth")
	G_RLF.DbMigrations:Migrate(G_RLF.db, "global.maxRows", "global.sizing.maxRows")
	G_RLF.DbMigrations:Migrate(G_RLF.db, "global.rowHeight", "global.sizing.rowHeight")
	G_RLF.DbMigrations:Migrate(G_RLF.db, "global.padding", "global.sizing.padding")
	G_RLF.DbMigrations:Migrate(G_RLF.db, "global.iconSize", "global.sizing.iconSize")
	G_RLF.DbMigrations:Migrate(G_RLF.db, "global.enabledSecondaryRowText", "global.styling.enabledSecondaryRowText")
	G_RLF.DbMigrations:Migrate(G_RLF.db, "global.leftAlign", "global.styling.leftAlign")
	G_RLF.DbMigrations:Migrate(G_RLF.db, "global.growUp", "global.styling.growUp")
	G_RLF.DbMigrations:Migrate(
		G_RLF.db,
		"global.rowBackgroundGradientStart",
		"global.styling.rowBackgroundGradientStart"
	)
	G_RLF.DbMigrations:Migrate(G_RLF.db, "global.rowBackgroundGradientEnd", "global.styling.rowBackgroundGradientEnd")
	G_RLF.DbMigrations:Migrate(G_RLF.db, "global.disableRowHighlight", "global.styling.disableRowHighlight")
	G_RLF.DbMigrations:Migrate(G_RLF.db, "global.enableRowBorder", "global.styling.enableRowBorder")
	G_RLF.DbMigrations:Migrate(G_RLF.db, "global.rowBorderSize", "global.styling.rowBorderSize")
	G_RLF.DbMigrations:Migrate(G_RLF.db, "global.rowBorderColor", "global.styling.rowBorderColor")
	G_RLF.DbMigrations:Migrate(G_RLF.db, "global.rowBorderClassColors", "global.styling.rowBorderClassColors")
	G_RLF.DbMigrations:Migrate(G_RLF.db, "global.useFontObjects", "global.styling.useFontObjects")
	G_RLF.DbMigrations:Migrate(G_RLF.db, "global.font", "global.styling.font")
	G_RLF.DbMigrations:Migrate(G_RLF.db, "global.fontFace", "global.styling.fontFace")
	G_RLF.DbMigrations:Migrate(G_RLF.db, "global.fontSize", "global.styling.fontSize")
	G_RLF.DbMigrations:Migrate(G_RLF.db, "global.secondaryFontSize", "global.styling.secondaryFontSize")
	G_RLF.DbMigrations:Migrate(G_RLF.db, "global.fontFlags", "global.styling.fontFlags")

	G_RLF.db.global.migrationVersion = version
end

G_RLF.migrations[version] = migration

return migration
