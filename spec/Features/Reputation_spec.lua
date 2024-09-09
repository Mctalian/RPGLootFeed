local common_stubs = require("spec/common_stubs")

describe("Reputation module", function()
	local _ = match._
	local RepModule

	before_each(function()
		common_stubs.setup_G_RLF(spy, assert)
		common_stubs.stub_C_Reputation()
		-- Load the list module before each test
		RepModule = require("Features/Reputation")
		RepModule:OnInitialize()
	end)

	it("RepModule is not nil", function()
		assert.is_not_nil(RepModule)
	end)

	it("does not show rep if the faction and/or repChange can't be determined from the message", function()
		local success =
			RepModule:CHAT_MSG_COMBAT_FACTION_CHANGE("CHAT_MSG_COMBAT_FACTION_CHANGE", "10x Reputation with Faction A")

		assert.is_true(success)

		assert.stub(_G.G_RLF.LootDisplay.ShowLoot).was.not_called()
	end)

	it("handles rep increases", function()
		local success =
			RepModule:CHAT_MSG_COMBAT_FACTION_CHANGE("CHAT_MSG_COMBAT_FACTION_CHANGE", "Rep with Faction A inc by 10.")

		assert.is_true(success)

		assert.stub(_G.G_RLF.LootDisplay.ShowLoot).was.called()
		assert.stub(_G.G_RLF.LootDisplay.ShowLoot).was.called_with(_, "Reputation", 10, "Faction A", 1, 0, 0)
		-- Successfully populates the locale cache
		assert.equal(_G.G_RLF.db.global.factionMaps.enUS["Faction A"], 1)
	end)

	it("handles rep increases despite locale cache miss", function()
		local success =
			RepModule:CHAT_MSG_COMBAT_FACTION_CHANGE("CHAT_MSG_COMBAT_FACTION_CHANGE", "Rep with Faction B inc by 100.")

		assert.is_true(success)

		assert.stub(_G.G_RLF.LootDisplay.ShowLoot).was.called()
		assert.stub(_G.G_RLF.LootDisplay.ShowLoot).was.called_with(_, "Reputation", 100, "Faction B", nil, nil, nil)
		assert.spy(RepModule:getLogger().Warn).was.called()
		assert.spy(RepModule:getLogger().Warn).was.called_with(_, "Faction B is STILL not cached for enUS", _, _)
	end)
end)
