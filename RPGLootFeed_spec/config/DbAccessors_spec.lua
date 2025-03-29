local nsMocks = require("RPGLootFeed_spec._mocks.Internal.addonNamespace")
local assert = require("luassert")
local busted = require("busted")
local before_each = busted.before_each
local describe = busted.describe
local it = busted.it
local spy = require("luassert.spy")

describe("DbAccessors module", function()
	local ns, DbAccessor, mockDb

	before_each(function()
		-- Setup the namespace and mock database
		ns = nsMocks:unitLoadedAfter(nsMocks.LoadSections.All)

		-- Create mock database structure
		mockDb = {
			global = {
				sizing = { mockSizing = true },
				positioning = { mockPositioning = true },
				styling = { mockStyling = true },
				partyLoot = {
					sizing = { mockPartySizing = true },
					positioning = { mockPartyPositioning = true },
					styling = { mockPartyStyling = true },
				},
			},
		}

		-- Attach mock db to namespace
		ns.db = mockDb

		-- Define frame types
		ns.Frames = {
			PARTY = "PARTY",
			MAIN = "MAIN",
		}

		-- Load the module being tested
		assert(loadfile("RPGLootFeed/config/DbAccessors.lua"))("TestAddon", ns)
		DbAccessor = ns.DbAccessor
	end)

	describe("Sizing", function()
		it("returns party loot sizing when frame is PARTY", function()
			local result = DbAccessor:Sizing(ns.Frames.PARTY)
			assert.are.same(mockDb.global.partyLoot.sizing, result)
			assert.is_true(result.mockPartySizing)
		end)

		it("returns global sizing when frame is not PARTY", function()
			local result = DbAccessor:Sizing(ns.Frames.MAIN)
			assert.are.same(mockDb.global.sizing, result)
			assert.is_true(result.mockSizing)
		end)

		it("returns global sizing when frame is nil", function()
			local result = DbAccessor:Sizing(nil)
			assert.are.same(mockDb.global.sizing, result)
			assert.is_true(result.mockSizing)
		end)
	end)

	describe("Positioning", function()
		it("returns party loot positioning when frame is PARTY", function()
			local result = DbAccessor:Positioning(ns.Frames.PARTY)
			assert.are.same(mockDb.global.partyLoot.positioning, result)
			assert.is_true(result.mockPartyPositioning)
		end)

		it("returns global positioning when frame is not PARTY", function()
			local result = DbAccessor:Positioning(ns.Frames.MAIN)
			assert.are.same(mockDb.global.positioning, result)
			assert.is_true(result.mockPositioning)
		end)

		it("returns global positioning when frame is nil", function()
			local result = DbAccessor:Positioning(nil)
			assert.are.same(mockDb.global.positioning, result)
			assert.is_true(result.mockPositioning)
		end)
	end)

	describe("Styling", function()
		it("returns party loot styling when frame is PARTY", function()
			local result = DbAccessor:Styling(ns.Frames.PARTY)
			assert.are.same(mockDb.global.partyLoot.styling, result)
			assert.is_true(result.mockPartyStyling)
		end)

		it("returns global styling when frame is not PARTY", function()
			local result = DbAccessor:Styling(ns.Frames.MAIN)
			assert.are.same(mockDb.global.styling, result)
			assert.is_true(result.mockStyling)
		end)

		it("returns global styling when frame is nil", function()
			local result = DbAccessor:Styling(nil)
			assert.are.same(mockDb.global.styling, result)
			assert.is_true(result.mockStyling)
		end)
	end)
end)
