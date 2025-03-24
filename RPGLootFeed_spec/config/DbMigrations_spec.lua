describe("DbMigrations module", function()
	local ns, dbMigrations
	before_each(function()
		-- Define the global G_RLF
		ns = {
			db = {
				char = {},
				realm = {},
				class = {},
				race = {},
				faction = {},
				factionrealm = {},
				global = {
					migrationVersion = 0,
				},
				locale = {},
				profile = {},
			},
		}

		-- Load the module before each test
		dbMigrations = assert(loadfile("RPGLootFeed/config/DbMigrations.lua"))("TestAddon", ns)
	end)

	it("migrates the old path to the new path", function()
		ns.db.global.oldValue = "old"
		ns.db.global.new = {}

		-- Pass paths as strings
		dbMigrations:Migrate(ns.db, "global.oldValue", "global.new.value", 1)

		assert.are.equal(ns.db.global.new.value, "old")
		assert.is_nil(ns.db.global.oldValue)
	end)

	it("migrates across db keys", function()
		local locale = "enUS"
		local faction = "fakeFaction"
		ns.db.global.factionMap = {}
		ns.db.global.factionMap[locale] = {}
		ns.db.global.factionMap[locale][faction] = 123
		ns.db.locale.factionMap = {}
		dbMigrations:Migrate(
			ns.db,
			"global.factionMap." .. locale .. "." .. faction,
			"locale.factionMap." .. faction,
			1
		)
		assert.are.equal(123, ns.db.locale.factionMap[faction])
		assert.is_nil(ns.db.global.factionMap[locale][faction])
		assert.are.equal(0, #ns.db.global.factionMap[locale])
	end)

	it("handles missing source values", function()
		ns.db.global.missingValue = nil
		ns.db.global.new = {}
		dbMigrations:Migrate(ns.db, "global.missingValue", "global.new.val", 1)
		assert.is_nil(ns.db.global.new.val)
		assert.is_nil(ns.db.global.missingValue)
	end)

	it("does not overwrite destination value with nil if source is missing", function()
		ns.db.global.missingValue = nil
		ns.db.global.new = {}
		ns.db.global.new.val = "something"
		dbMigrations:Migrate(ns.db, "global.missingValue", "global.new.val", 1)
		assert.are.equal(ns.db.global.new.val, "something")
		assert.is_nil(ns.db.global.missingValue)
	end)

	it("transfers false values", function()
		ns.db.global.oldValue = false
		ns.db.global.new = {}
		dbMigrations:Migrate(ns.db, "global.oldValue", "global.new.value", 1)
		assert.are.equal(false, ns.db.global.new.value)
		assert.is_nil(ns.db.global.oldValue)
	end)

	it("handles invalid paths", function()
		dbMigrations:Migrate(ns.db, "global.some.thing.old", "global.new.thing", 1)
		assert.is_nil(ns.db.global.some)
		assert.is_nil(ns.db.global.new)
	end)

	it("handles migrating tables", function()
		ns.db.global.oldTable = {
			value = "old",
			subTable = {
				value = "subOld",
			},
		}
		ns.db.global.new = {}
		dbMigrations:Migrate(ns.db, "global.oldTable", "global.new.table", 1)
		assert.are.equal(ns.db.global.new.table.value, "old")
		assert.are.equal(ns.db.global.new.table.subTable.value, "subOld")
		assert.is_nil(ns.db.global.oldTable)
	end)

	it("handles integer indices", function()
		ns.db.global.oldTable = {
			[1] = true,
			[2] = false,
		}
		ns.db.global.new = {}
		for k, v in pairs(ns.db.global.oldTable) do
			dbMigrations:Migrate(ns.db, "global.oldTable." .. k, "global.new." .. k .. ".enabled")
		end
		assert.are.equal(ns.db.global.new[1].enabled, true)
		assert.are.equal(ns.db.global.new[2].enabled, false)
		assert.is_nil(ns.db.global.oldTable[1])
		assert.is_nil(ns.db.global.oldTable[2])
	end)
end)
