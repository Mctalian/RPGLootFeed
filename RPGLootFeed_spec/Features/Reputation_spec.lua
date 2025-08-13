local nsMocks = require("RPGLootFeed_spec._mocks.Internal.addonNamespace")
local assert = require("luassert")
local match = require("luassert.match")
local busted = require("busted")
local before_each = busted.before_each
local describe = busted.describe
local it = busted.it
local mock = busted.mock
local setup = busted.setup
local spy = busted.spy

describe("Reputation module", function()
	local _ = match._
	local RepModule, ns
	local reputationMocks, gossipInfoMocks, delvesUIMocks, majorFactionMocks, functionMocks

	setup(function()
		require("RPGLootFeed_spec._mocks.WoWGlobals")
		require("RPGLootFeed_spec._mocks.WoWGlobals.Enum")
		functionMocks = require("RPGLootFeed_spec._mocks.WoWGlobals.Functions")
		reputationMocks = require("RPGLootFeed_spec._mocks.WoWGlobals.namespaces.C_Reputation")
		majorFactionMocks = require("RPGLootFeed_spec._mocks.WoWGlobals.namespaces.C_MajorFactions")
		gossipInfoMocks = require("RPGLootFeed_spec._mocks.WoWGlobals.namespaces.C_GossipInfo")
		delvesUIMocks = require("RPGLootFeed_spec._mocks.WoWGlobals.namespaces.C_DelvesUI")
	end)

	before_each(function()
		ns = nsMocks:unitLoadedAfter(nsMocks.LoadSections.All)

		-- Load the LootDisplayProperties module to populate `ns`
		assert(loadfile("RPGLootFeed/Features/_Internals/LootDisplayProperties.lua"))("TestAddon", ns)

		-- Ensure `ns` has been populated correctly by LootDisplayProperties
		assert.is_not_nil(ns.InitializeLootDisplayProperties)
		nsMocks.RGBAToHexFormat.returns("COLORSTRING")
		nsMocks.CreatePatternSegmentsForStringNumber.returns({
			"Rep with ",
			" inc by ",
			".",
		})

		-- Load the list module before each test
		RepModule = assert(loadfile("RPGLootFeed/Features/Reputation.lua"))("TestAddon", ns)
		RepModule:OnInitialize()
		RepModule:PLAYER_ENTERING_WORLD("PLAYER_ENTERING_WORLD", true, false)
		nsMocks.SendMessage:clear()
		nsMocks.LogWarn:clear()
	end)

	it("RepModule is not nil", function()
		assert.is_not_nil(RepModule)
	end)

	it("does not show rep if the faction and/or repChange can't be determined from the message", function()
		ns.ExtractDynamicsFromPattern = function()
			return nil, nil
		end
		local success =
			RepModule:CHAT_MSG_COMBAT_FACTION_CHANGE("CHAT_MSG_COMBAT_FACTION_CHANGE", "10x Reputation with Faction A")

		assert.is_true(success)

		assert.spy(nsMocks.SendMessage).was.not_called()
	end)

	it("handles rep increases #only", function()
		local elementMock = mock(RepModule.Element, false)
		local timesCalled = 0
		nsMocks.ExtractDynamicsFromPattern.invokes(function()
			timesCalled = timesCalled + 1
			--- 3 Account-wide patterns, then to normal faction standing patterns
			if timesCalled == 4 then
				return "Faction A", 10
			end
			return nil, nil
		end)
		local success =
			RepModule:CHAT_MSG_COMBAT_FACTION_CHANGE("CHAT_MSG_COMBAT_FACTION_CHANGE", "Rep with Faction A inc by 10.")

		assert.is_true(success)
		assert.spy(elementMock.new).was.called_with(RepModule.Element, 10, "Faction A", 1, 0, 0, 1, _, 3)
		assert.spy(nsMocks.SendMessage).was.called(1)
		-- Successfully populates the locale cache
		assert.equal(ns.db.locale.factionMap["Faction A"], 1)
	end)

	it("handles rep increases despite locale cache miss", function()
		local elementMock = mock(RepModule.Element, false)
		local timesCalled = 0
		nsMocks.ExtractDynamicsFromPattern.invokes(function()
			timesCalled = timesCalled + 1
			--- 3 Account-wide patterns, then to normal faction standing patterns
			if timesCalled == 4 then
				return "Faction B", 100
			end
			return nil, nil
		end)
		local success =
			RepModule:CHAT_MSG_COMBAT_FACTION_CHANGE("CHAT_MSG_COMBAT_FACTION_CHANGE", "Rep with Faction B inc by 100.")

		assert.is_true(success)

		assert.spy(elementMock.new).was.called_with(RepModule.Element, 100, "Faction B", nil, nil, nil, nil, nil, nil)
		assert.spy(nsMocks.SendMessage).was.called(1)
		assert.spy(nsMocks.LogWarn).was.called(1)
		assert.spy(nsMocks.LogWarn).was.called_with(_, "Faction B is STILL not cached for enUS", _, _)
	end)

	it("handles delve companion experience gains", function()
		local newElement = spy.on(RepModule.Element, "new")
		functionMocks.GetExpansionLevel.returns(ns.Expansion.TWW)
		ns.ExtractDynamicsFromPattern = function()
			return nil, nil
		end
		gossipInfoMocks.GetFriendshipReputation.returns({
			standing = 10,
			reactionThreshold = 10,
			nextThreshold = 500,
		})
		gossipInfoMocks.GetFriendshipReputationRanks.returns({
			currentLevel = 1,
			maxLevel = 10,
		})
		reputationMocks.GetFactionDataByID.returns({
			name = "Brann Bronzebeard",
			factionID = 2640,
			reaction = 8,
			isAccountWide = true,
		})
		reputationMocks.GetFactionDataByIndex.returns({
			name = "Brann Bronzebeard",
			factionID = 2640,
			reaction = 8,
			isAccountWide = true,
		})
		RepModule:PLAYER_ENTERING_WORLD("PLAYER_ENTERING_WORLD", true, false)

		local success = RepModule:CHAT_MSG_COMBAT_FACTION_CHANGE(
			"CHAT_MSG_COMBAT_FACTION_CHANGE",
			"Brann Bronzebeard has gained 313 experience."
		)

		assert.is_true(success)

		assert.spy(newElement).was.called_with(RepModule.Element, 313, "Brann Bronzebeard", 0, 1, 0, 2640, _, 4)
		assert.spy(nsMocks.SendMessage).was.called(1)
		-- Successfully populates the locale cache
		assert.equal(ns.db.locale.accountWideFactionMap["Brann Bronzebeard"], 2640)
	end)

	it("handles delve companion experience when it causes companion to reach max level", function()
		local newElement = spy.on(RepModule.Element, "new")
		functionMocks.GetExpansionLevel.returns(ns.Expansion.TWW)
		ns.ExtractDynamicsFromPattern = function()
			return nil, nil
		end
		gossipInfoMocks.GetFriendshipReputation.returns({
			standing = 10,
			reactionThreshold = 10,
			nextThreshold = nil,
		})
		gossipInfoMocks.GetFriendshipReputationRanks.returns({
			currentLevel = 10,
			maxLevel = 10,
		})
		reputationMocks.GetFactionDataByID.returns({
			name = "Brann Bronzebeard",
			factionID = 2640,
			reaction = 8,
			isAccountWide = true,
		})
		reputationMocks.GetFactionDataByIndex.returns({
			name = "Brann Bronzebeard",
			factionID = 2640,
			reaction = 8,
			isAccountWide = true,
		})

		local expectedFactionData = {
			name = "Brann Bronzebeard",
			factionID = 2640,
			currentLevel = 10,
			currentXp = 0,
			reaction = 8,
			nextLevelAt = 0,
			maxLevel = 10,
			isAccountWide = true,
		}

		RepModule:PLAYER_ENTERING_WORLD("PLAYER_ENTERING_WORLD", true, false)

		local success = RepModule:CHAT_MSG_COMBAT_FACTION_CHANGE(
			"CHAT_MSG_COMBAT_FACTION_CHANGE",
			"Brann Bronzebeard has gained 313 experience."
		)

		assert.is_true(success)

		assert.spy(newElement).was.called_with(_, 313, "Brann Bronzebeard", 0, 1, 0, 2640, expectedFactionData, 4)
		assert.spy(nsMocks.SendMessage).was.called(1)
		-- Successfully populates the locale cache
		assert.equal(ns.db.locale.accountWideFactionMap["Brann Bronzebeard"], 2640)
	end)

	describe("element.textFn", function()
		it("handles positive rep gains", function()
			local element = RepModule.Element:new(10, "Faction A", 1, 0, 0, 1, _, 3)
			local text = element.textFn()

			assert.equal(text, "+10 Faction A")
		end)

		it("handles negative rep gains", function()
			local element = RepModule.Element:new(-10, "Faction A", 1, 0, 0, 1, _, 3)
			local text = element.textFn()

			assert.equal(text, "-10 Faction A")
		end)

		it("handles updated rep values", function()
			local element = RepModule.Element:new(10, "Faction A", 1, 0, 0, 1, _, 3)
			local text = element.textFn(20)

			assert.equal(text, "+30 Faction A")
		end)
	end)

	describe("element.secondaryTextFn", function()
		it("does not continue if factionId is missing", function()
			local element = RepModule.Element:new(10, "Faction A", 1, 0, 0, nil, _, 3)
			local text = element.secondaryTextFn()

			assert.equal(text, "")
		end)

		it("shows level percentage if delve companion experience gain (and not max level)", function()
			local factionData = {
				factionId = 2640,
				factionName = "Brann Bronzebeard",
				currentLevel = 1,
				maxLevel = 10,
				currentXp = 23,
				nextLevelAt = 100,
			}
			local element = RepModule.Element:new(10, "Brann Bronzebeard", 1, 0, 0, 2640, factionData, 4)
			local text = element.secondaryTextFn()
			assert.is_not_nil(string.match(text, "23.0%%"))
		end)

		it("does not show level percentage if delve companion experience gain (and max level)", function()
			local factionData = {
				factionId = 2640,
				factionName = "Brann Bronzebeard",
				currentLevel = 10,
				maxLevel = 10,
				currentXp = 23,
				nextLevelAt = 0,
			}
			local element = RepModule.Element:new(10, "Brann Bronzebeard", 1, 0, 0, 2640, factionData, 4)
			local text = element.secondaryTextFn()
			assert.equal(text, "")
		end)

		describe("normal factions", function()
			it("shows current standing and progress to next standing", function()
				local factionData = {
					factionId = 1,
					factionName = "Faction A",
					currentStanding = 20,
					currentReactionThreshold = 0,
					nextReactionThreshold = 3000,
				}
				local element = RepModule.Element:new(10, "Faction A", 1, 0, 0, 1, factionData, 3)
				local text = element.secondaryTextFn()

				-- assert that text containns "20/3000"
				assert.is_not_nil(string.match(text, "20/3000"))
			end)
		end)
	end)
end)
