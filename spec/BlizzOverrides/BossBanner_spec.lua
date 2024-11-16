local common_stubs = require("spec/common_stubs")

describe("BossBanner module", function()
	local ns, BossBannerOverride
	before_each(function()
		ns = ns or common_stubs.setup_G_RLF(spy)
		ns.DisableBossBanner = {
			ENABLED = 0,
			FULLY_DISABLE = 1,
			DISABLE_LOOT = 2,
			DISABLE_MY_LOOT = 3,
			DISABLE_GROUP_LOOT = 4,
		}
		_G.BossBanner = {
			OnEvent = function() end,
		}

		BossBannerOverride = assert(loadfile("BlizzOverrides/BossBanner.lua"))("TestAddon", ns)
	end)

	describe("OnInitialize", function()
		it("registers PLAYER_ENTERING_WORLD event", function()
			spy.on(BossBannerOverride, "RegisterEvent")
			BossBannerOverride:OnInitialize()
			assert
				.spy(BossBannerOverride.RegisterEvent).was
				.called_with(BossBannerOverride, "PLAYER_ENTERING_WORLD", "BossBannerHook")
		end)
	end)

	it("hooks BossBanner OnEvent when available", function()
		_G.BossBanner = {}
		spy.on(BossBannerOverride, "RawHookScript")
		BossBannerOverride:BossBannerHook()
		assert
			.spy(BossBannerOverride.RawHookScript).was
			.called_with(BossBannerOverride, BossBanner, "OnEvent", "InterceptBossBannerAlert", true)
	end)

	it("does not hook BossBanner OnEvent if already hooked", function()
		_G.BossBanner = {}
		spy.on(BossBannerOverride, "IsHooked")
		spy.on(BossBannerOverride, "RawHookScript")
		BossBannerOverride.IsHooked = function()
			return true
		end
		BossBannerOverride:BossBannerHook()
		assert.spy(BossBannerOverride.RawHookScript).was_not_called()
	end)

	describe("InterceptBossBannerAlert", function()
		before_each(function()
			BossBannerOverride.hooks = { [BossBanner] = { OnEvent = function() end } }
			spy.on(BossBannerOverride.hooks[BossBanner], "OnEvent")
		end)

		it("completely skips BossBanner alert if fully disabled", function()
			local event = "ANYTHING"
			ns.db.global.bossBannerConfig = ns.DisableBossBanner.FULLY_DISABLE
			BossBannerOverride:InterceptBossBannerAlert(nil, event, nil, nil, nil, nil, nil, nil)
			assert.spy(BossBannerOverride.hooks[BossBanner].OnEvent).was_not_called()
		end)

		it("does not show any loot if loot is disabled", function()
			local event = "ENCOUNTER_LOOT_RECEIVED"
			local myName = "MyPlayer"
			local playerName = "TestPlayer"
			ns.db.global.bossBannerConfig = ns.DisableBossBanner.DISABLE_LOOT
			BossBannerOverride:InterceptBossBannerAlert(nil, event, nil, nil, nil, nil, playerName, nil)
			BossBannerOverride:InterceptBossBannerAlert(nil, event, nil, nil, nil, nil, myName, nil)
			assert.spy(BossBannerOverride.hooks[BossBanner].OnEvent).was_not_called()
		end)

		it("does not show my loot if my loot is disabled", function()
			local event = "ENCOUNTER_LOOT_RECEIVED"
			local playerName = "TestPlayer"
			local myName = "MyPlayer"
			local myGuid = "Player-1234-5678"
			_G.GetPlayerGuid = function()
				return myGuid
			end
			_G.GetNameAndServerNameFromGUID = function()
				return myName, nil
			end

			ns.db.global.bossBannerConfig = ns.DisableBossBanner.DISABLE_MY_LOOT
			BossBannerOverride:InterceptBossBannerAlert(nil, event, nil, nil, nil, nil, myName, nil)
			assert.spy(BossBannerOverride.hooks[BossBanner].OnEvent).was_not_called()
		end)

		it("does not show group loot if group loot is disabled", function()
			local event = "ENCOUNTER_LOOT_RECEIVED"
			local playerName = "TestPlayer"
			local myName = "MyPlayer"
			local myGuid = "Player-1234-5678"
			_G.GetPlayerGuid = function()
				return myGuid
			end
			_G.GetNameAndServerNameFromGUID = function()
				return myName, nil
			end

			ns.db.global.bossBannerConfig = ns.DisableBossBanner.DISABLE_GROUP_LOOT
			BossBannerOverride:InterceptBossBannerAlert(nil, event, nil, nil, nil, nil, playerName, nil)
			assert.spy(BossBannerOverride.hooks[BossBanner].OnEvent).was_not_called()
			BossBannerOverride:InterceptBossBannerAlert(nil, event, nil, nil, nil, nil, myName, nil)
			assert.spy(BossBannerOverride.hooks[BossBanner].OnEvent).was_called()
		end)
	end)
end)
