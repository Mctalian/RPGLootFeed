local assert = require("luassert")
local busted = require("busted")
local before_each = busted.before_each
local describe = busted.describe
local it = busted.it

describe("DbUtils module", function()
	local ns, dbUtils
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
					styling = {},
					partyLoot = {
						styling = {},
					},
				},
				locale = {},
				profile = {},
			},
		}

		assert(loadfile("RPGLootFeed/config/common/common.lua"))("TestAddon", ns)
		dbUtils = assert(loadfile("RPGLootFeed/config/common/db.utils.lua"))("TestAddon", ns)
	end)

	it("handles nested values", function()
		local sampleDb = {
			rowBackgroundTextureColor = { 0, 0, 0, 1 },
			backdropInsets = {
				left = 0,
				right = 0,
				top = 0,
				bottom = 0,
			},
		}

		dbUtils.setPath(ns.db, "global.styling", sampleDb)

		assert.are.equal(ns.db.global.styling.rowBackgroundTextureColor[1], 0)
		assert.are.equal(ns.db.global.styling.rowBackgroundTextureColor[2], 0)
		assert.are.equal(ns.db.global.styling.rowBackgroundTextureColor[3], 0)
		assert.are.equal(ns.db.global.styling.rowBackgroundTextureColor[4], 1)
		assert.are.equal(ns.db.global.styling.backdropInsets.left, 0)
		assert.are.equal(ns.db.global.styling.backdropInsets.right, 0)
		assert.are.equal(ns.db.global.styling.backdropInsets.top, 0)
		assert.are.equal(ns.db.global.styling.backdropInsets.bottom, 0)
	end)
end)
