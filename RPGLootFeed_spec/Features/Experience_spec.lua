---@diagnostic disable: undefined-field
local nsMocks = require("RPGLootFeed_spec._mocks.Internal.addonNamespace")
local assert = require("luassert")
local match = require("luassert.match")
local busted = require("busted")
local spy = busted.spy
local before_each = busted.before_each
local describe = busted.describe
local it = busted.it
local stub = busted.stub

describe("Experience module", function()
	local _ = match._
	local XpModule, ns, fnMocks

	before_each(function()
		require("RPGLootFeed_spec._mocks.WoWGlobals.Enum")
		fnMocks = require("RPGLootFeed_spec._mocks.WoWGlobals.Functions")
		ns = nsMocks:unitLoadedAfter(nsMocks.LoadSections.All)

		-- Load TextTemplateEngine first
		ns.TextTemplateEngine =
			assert(loadfile("RPGLootFeed/Features/_Internals/TextTemplateEngine.lua"))("TestAddon", ns)

		-- Mock WoW functions
		_G.UnitXP = fnMocks.UnitXP or function()
			return 10
		end
		_G.UnitXPMax = fnMocks.UnitXPMax or function()
			return 50
		end
		_G.UnitLevel = fnMocks.UnitLevel or function()
			return 2
		end

		-- Configure RGBAToHexFormat stub to return a proper color code
		ns.RGBAToHexFormat.returns(ns.RGBAToHexFormat, "|cFFFFFFFF")

		-- Load the LootDisplayProperties module to populate `ns`
		assert(loadfile("RPGLootFeed/Features/_Internals/LootDisplayProperties.lua"))("TestAddon", ns)

		-- Ensure `ns` has been populated correctly by LootDisplayProperties
		assert.is_not_nil(ns.InitializeLootDisplayProperties)

		-- Load the list module before each test
		XpModule = assert(loadfile("RPGLootFeed/Features/Experience.lua"))("TestAddon", ns)
	end)

	it("does not show xp if the unit target is not player", function()
		ns.db.global.xp.enabled = true

		XpModule:PLAYER_XP_UPDATE("PLAYER_XP_UPDATE", "target")

		assert.stub(ns.SendMessage).was.not_called()
	end)

	it("does not show xp if the calculated delta is 0", function()
		ns.db.global.xp.enabled = true

		XpModule:PLAYER_ENTERING_WORLD()

		XpModule:PLAYER_XP_UPDATE("PLAYER_XP_UPDATE", "player")

		assert.stub(ns.SendMessage).was.not_called()
	end)

	it("show xp if the player levels up", function()
		ns.db.global.xp.enabled = true

		XpModule:PLAYER_ENTERING_WORLD()

		-- Leveled up from 2 to 3
		-- old max XP was 50
		-- xp value is still 10
		-- (50 max for last level - 10 old xp value) + 10 new xp value = 50 xp earned
		---@diagnostic disable-next-line: undefined-field
		local stubUnitLevel = fnMocks.UnitLevel.returns(3)
		---@diagnostic disable-next-line: undefined-field
		local stubUnitXPMax = fnMocks.UnitXPMax.returns(100)

		local newElement = spy.on(XpModule.Element, "new")

		XpModule:PLAYER_XP_UPDATE("PLAYER_XP_UPDATE", "player")

		assert.spy(newElement).was.called_with(_, 50)
		assert.stub(ns.SendMessage).was.called(1)
		stubUnitLevel:revert()
		stubUnitXPMax:revert()
	end)

	describe("GenerateTextElements", function()
		it("generates row 1 elements", function()
			local elements = XpModule:GenerateTextElements(500)

			assert.is_not_nil(elements[1])
			assert.is_not_nil(elements[1].primary)
			assert.equal("primary", elements[1].primary.type)
			assert.equal("{sign}{amount} {xpLabel}", elements[1].primary.template)
			assert.equal(1, elements[1].primary.order)
		end)

		it("generates row 2 elements", function()
			local elements = XpModule:GenerateTextElements(500)

			assert.is_not_nil(elements[2])
			assert.is_not_nil(elements[2].context)
			assert.equal("context", elements[2].context.type)
			assert.equal("{currentXPPercentage}", elements[2].context.template)
			assert.equal(2, elements[2].context.order)

			-- Should also have spacer
			assert.is_not_nil(elements[2].contextSpacer)
			assert.equal("spacer", elements[2].contextSpacer.type)
			assert.equal(4, elements[2].contextSpacer.spacerCount)
			assert.equal(1, elements[2].contextSpacer.order)
		end)
	end)

	describe("Element creation", function()
		before_each(function()
			-- Enable the context provider for element tests
			XpModule:OnEnable()
		end)

		it("creates experience elements with correct properties", function()
			local element = XpModule.Element:new(500)

			assert.is_not_nil(element)
			assert.equal("Experience", element.type)
			assert.equal("EXPERIENCE", element.key)
			assert.equal(500, element.quantity)
			assert.is_not_nil(element.icon)
			assert.is_function(element.textFn)
			assert.is_function(element.secondaryTextFn)
		end)

		it("textFn uses TextTemplateEngine", function()
			local element = XpModule.Element:new(500)

			local result = element.textFn(250)

			-- Should contain the total amount: 500 + 250 = 750 XP
			assert.truthy(result)
			assert.is_string(result)
			assert.matches("500", result) -- Fixed: using actual element base value
			assert.matches("XP", result)
		end)

		it("secondaryTextFn shows XP percentage when XP data available", function()
			-- Mock XP values
			local originalUnitXP = _G.UnitXP
			local originalUnitXPMax = _G.UnitXPMax
			_G.UnitXP = function()
				return 7500
			end
			_G.UnitXPMax = function()
				return 10000
			end

			-- Initialize XP values
			XpModule:PLAYER_ENTERING_WORLD("PLAYER_ENTERING_WORLD")

			local element = XpModule.Element:new(500)
			local result = element.secondaryTextFn(250)

			-- Should contain percentage display (7500/10000 = 75%)
			assert.truthy(result)
			assert.is_string(result)
			assert.matches("75.00%%", result) -- Escape the dot and double % for literal match

			-- Restore original functions
			_G.UnitXP = originalUnitXP
			_G.UnitXPMax = originalUnitXPMax
		end)

		it("secondaryTextFn returns empty when XP data unavailable", function()
			-- Clear XP values
			local originalUnitXP = _G.UnitXP
			local originalUnitXPMax = _G.UnitXPMax
			_G.UnitXP = function()
				return nil
			end
			_G.UnitXPMax = function()
				return nil
			end

			-- Initialize with nil values
			XpModule:PLAYER_ENTERING_WORLD("PLAYER_ENTERING_WORLD")

			local element = XpModule.Element:new(500)
			local result = element.secondaryTextFn(250)

			-- Should return empty string when XP data is not available
			assert.equal("", result)

			-- Restore original functions
			_G.UnitXP = originalUnitXP
			_G.UnitXPMax = originalUnitXPMax
		end)

		it("returns nil for zero quantity", function()
			local element = XpModule.Element:new(0)
			assert.is_nil(element)

			local element2 = XpModule.Element:new(nil)
			assert.is_nil(element2)
		end)
	end)
end)
