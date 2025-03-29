local nsMocks = require("RPGLootFeed_spec._mocks.Internal.addonNamespace")
local assert = require("luassert")
local match = require("luassert.match")
local busted = require("busted")
local before_each = busted.before_each
local describe = busted.describe
local it = busted.it
local spy = busted.spy

describe("Professions Module", function()
	local _ = match._
	local Professions, ns

	before_each(function()
		require("RPGLootFeed_spec._mocks.WoWGlobals.Enum")
		require("RPGLootFeed_spec._mocks.WoWGlobals.Functions")
		ns = nsMocks:unitLoadedAfter(nsMocks.LoadSections.All)

		Professions = assert(loadfile("RPGLootFeed/Features/Professions.lua"))("TestAddon", ns)
		Professions:OnInitialize()
	end)

	it("should initialize professions correctly", function()
		Professions:InitializeProfessions()
		assert.are.same(Professions.profNameIconMap["Profession1"], "icon1")
	end)

	it("should handle PLAYER_ENTERING_WORLD event", function()
		spy.on(Professions, "RegisterEvent")
		Professions:PLAYER_ENTERING_WORLD()
		assert.equal(#Professions.profLocaleBaseNames, 5)
	end)

	describe("Element", function()
		it("creates a new element correctly", function()
			local element = Professions.Element:new(1, "Expansion1", "icon1", 10, 20, 5)
			assert.are.same(element.name, "Expansion1")
			assert.are.same(element.icon, "icon1")
			assert.are.same(element.level, 10)
			assert.are.same(element.maxLevel, 20)
			assert.are.same(element.quantity, 5)
			assert.are.same(element.key, "PROF_1")
		end)
	end)
end)
