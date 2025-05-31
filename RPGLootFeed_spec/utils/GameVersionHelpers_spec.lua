local nsMocks = require("RPGLootFeed_spec._mocks.Internal.addonNamespace")
local assert = require("luassert")
local busted = require("busted")
local after_each = busted.after_each
local before_each = busted.before_each
local describe = busted.describe
local it = busted.it
local setup = busted.setup
local spy = busted.spy
local stub = busted.stub

describe("GameVersionHelpers", function()
	describe("load order", function()
		local stubClearIBO, ns, stubIsClassic, stubIsCataClassic, stubIsMopClassic, stubIsRetail
		before_each(function()
			ns = nsMocks:unitLoadedAfter(nsMocks.LoadSections.UtilsEnums)
			stubIsClassic = nsMocks.IsClassic.returns(false)
			stubIsCataClassic = nsMocks.IsCataClassic.returns(false)
			stubIsMopClassic = nsMocks.IsMoPClassic.returns(false)
			stubIsRetail = nsMocks.IsRetail.returns(true)
		end)

		after_each(function()
			stubIsClassic:revert()
			stubIsCataClassic:revert()
			stubIsMopClassic:revert()
			stubIsRetail:revert()
			_G.ClearItemButtonOverlay = nil
		end)

		it("initializes properly", function()
			assert.is_nil(ns.ClassicToRetail)
			assert(loadfile("RPGLootFeed/utils/GameVersionHelpers.lua"))("TestAddon", ns)
			assert.is_not_nil(ns.ClassicToRetail)
		end)

		it("stubs ClearItemButtonOverlay in classic version", function()
			stubIsClassic.returns(true)
			stubIsCataClassic.returns(false)
			stubIsRetail.returns(false)

			assert.is_nil(ClearItemButtonOverlay)
			assert(loadfile("RPGLootFeed/utils/GameVersionHelpers.lua"))("TestAddon", ns)
			assert.is_not_nil(ClearItemButtonOverlay)
			assert.is_function(ClearItemButtonOverlay)
			assert.is_nil(ClearItemButtonOverlay())
		end)

		it("does not stub ClearItemButtonOverlay if it already exists", function()
			stubIsCataClassic.returns(true)
			stubIsClassic.returns(false)
			stubIsRetail.returns(false)

			ClearItemButtonOverlay = function()
				return "test"
			end
			assert.is_not_nil(ClearItemButtonOverlay)

			assert(loadfile("RPGLootFeed/utils/GameVersionHelpers.lua"))("TestAddon", ns)
			assert.is_function(ClearItemButtonOverlay)
			assert.are.equal("test", ClearItemButtonOverlay())
		end)

		it("does not attempt to stub ClearItemButtonOverlay in retail version", function()
			stubIsClassic.returns(false)
			stubIsCataClassic.returns(false)
			stubIsRetail.returns(true)

			assert.is_nil(ClearItemButtonOverlay)
			assert(loadfile("RPGLootFeed/utils/GameVersionHelpers.lua"))("TestAddon", ns)
			assert.is_nil(ClearItemButtonOverlay)
		end)
	end)

	describe("functionality", function()
		local ns, mockFunctions

		setup(function()
			mockFunctions = require("RPGLootFeed_spec._mocks.WoWGlobals.Functions")
		end)

		before_each(function()
			ns = nsMocks:unitLoadedAfter(nsMocks.LoadSections.All)
			assert(loadfile("RPGLootFeed/utils/GameVersionHelpers.lua"))("TestAddon", ns)
		end)

		it("calls ConvertFactionInfoByID", function()
			local id = 1

			local info = ns.ClassicToRetail:ConvertFactionInfoByID(id)

			assert.spy(mockFunctions.GetFactionInfoByID).was.called_with(id)
			assert.equal("Faction" .. id, info.name)
			assert.equal("Description" .. id, info.description)
			assert.equal(1, info.reaction)
			assert.equal(2, info.currentReactionThreshold)
			assert.equal(3, info.nextReactionThreshold)
			assert.equal(4, info.currentStanding)
			assert.equal(5, info.atWarWith)
			assert.equal(6, info.canToggleAtWar)
			assert.equal(7, info.isHeader)
			assert.equal(8, info.isCollapsed)
			assert.equal(9, info.isHeaderWithRep)
			assert.equal(10, info.isWatched)
			assert.equal(11, info.isChild)
			assert.equal(12, info.factionID)
			assert.equal(false, info.canSetInactive)
			assert.equal(false, info.hasBonusRepGain)
			assert.equal(false, info.isAccountWide)
		end)

		it("calls ConvertFactionInfoByIndex", function()
			local index = 1

			local info = ns.ClassicToRetail:ConvertFactionInfoByIndex(index)

			assert.spy(mockFunctions.GetFactionInfo).was.called_with(index)
			assert.equal("Faction" .. index, info.name)
			assert.equal("Description" .. index, info.description)
			assert.equal(1, info.reaction)
			assert.equal(2, info.currentReactionThreshold)
			assert.equal(3, info.nextReactionThreshold)
			assert.equal(4, info.currentStanding)
			assert.equal(5, info.atWarWith)
			assert.equal(6, info.canToggleAtWar)
			assert.equal(7, info.isHeader)
			assert.equal(8, info.isCollapsed)
			assert.equal(9, info.isHeaderWithRep)
			assert.equal(10, info.isWatched)
			assert.equal(11, info.isChild)
			assert.equal(12, info.factionID)
			assert.equal(false, info.canSetInactive)
			assert.equal(false, info.hasBonusRepGain)
			assert.equal(false, info.isAccountWide)
		end)
	end)
end)
