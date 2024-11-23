local common_stubs = require("spec/common_stubs")

describe("Reputation module", function()
	local _ = match._
	local RepModule, ns

	before_each(function()
		ns = ns or common_stubs.setup_G_RLF(spy)
		common_stubs.stub_C_Reputation()
		common_stubs.stub_C_DelvesUI()

		-- Load the LootDisplayProperties module to populate `ns`
		assert(loadfile("Features/LootDisplayProperties.lua"))("TestAddon", ns)

		-- Ensure `ns` has been populated correctly by LootDisplayProperties
		assert.is_not_nil(ns.InitializeLootDisplayProperties)
		assert.is_not_nil(ns.LootDisplayProperties)

		-- Load the list module before each test
		RepModule = assert(loadfile("Features/Reputation.lua"))("TestAddon", ns)
		RepModule:OnInitialize()
	end)

	it("RepModule is not nil", function()
		assert.is_not_nil(RepModule)
	end)

	it("does not show rep if the faction and/or repChange can't be determined from the message", function()
		local success =
			RepModule:CHAT_MSG_COMBAT_FACTION_CHANGE("CHAT_MSG_COMBAT_FACTION_CHANGE", "10x Reputation with Faction A")

		assert.is_true(success)

		assert.stub(ns.SendMessage).was.not_called()
	end)

	it("handles rep increases", function()
		local newElement = spy.on(RepModule.Element, "new")
		local success =
			RepModule:CHAT_MSG_COMBAT_FACTION_CHANGE("CHAT_MSG_COMBAT_FACTION_CHANGE", "Rep with Faction A inc by 10.")

		assert.is_true(success)

		assert.spy(newElement).was.called_with(_, 10, "Faction A", 1, 0, 0, 1, _, 3)
		assert.stub(ns.SendMessage).was.called()
		-- Successfully populates the locale cache
		assert.equal(ns.db.global.factionMaps.enUS["Faction A"], 1)
	end)

	it("handles rep increases despite locale cache miss", function()
		local newElement = spy.on(RepModule.Element, "new")
		local success =
			RepModule:CHAT_MSG_COMBAT_FACTION_CHANGE("CHAT_MSG_COMBAT_FACTION_CHANGE", "Rep with Faction B inc by 100.")

		assert.is_true(success)

		assert.spy(newElement).was.called_with(_, 100, "Faction B", nil, nil, nil, nil, nil, nil)
		assert.stub(ns.SendMessage).was.called()
		assert.spy(ns.LogWarn).was.called()
		assert.spy(ns.LogWarn).was.called_with(_, "Faction B is STILL not cached for enUS", _, _)
	end)

	it("handles delve companion experience gains", function()
		local newElement = spy.on(RepModule.Element, "new")
		local success = RepModule:CHAT_MSG_COMBAT_FACTION_CHANGE(
			"CHAT_MSG_COMBAT_FACTION_CHANGE",
			"Brann Bronzebeard has gained 313 experience."
		)

		assert.is_true(success)

		assert.spy(newElement).was.called_with(_, 313, "Brann Bronzebeard", 0, 1, 0, 2640, _, 4)
		assert.stub(ns.SendMessage).was.called()
		-- Successfully populates the locale cache
		assert.equal(ns.db.global.factionMaps.enUS["Brann Bronzebeard"], 2640)
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

		it("does not continue if this is a delve companion experience gain", function()
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

		describe("normal factions", function()
			it("shows current standing and progress to next standing", function()
				local factionData = {
					factionId = 1,
					factionName = "Faction A",
					currentStanding = 20,
					currentReactionThreshold = 3000,
				}
				local element = RepModule.Element:new(10, "Faction A", 1, 0, 0, 1, factionData, 3)
				local text = element.secondaryTextFn()

				-- assert that text containns "20/3000"
				assert.is_not_nil(string.match(text, "20/3000"))
			end)
		end)
	end)
end)
