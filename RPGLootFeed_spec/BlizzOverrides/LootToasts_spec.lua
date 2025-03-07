local common_stubs = require("RPGLootFeed_spec/common_stubs")

describe("LootToasts module", function()
	local ns, LootToastOverride
	before_each(function()
		ns = ns or common_stubs.setup_G_RLF(spy)
		_G.LootAlertSystem = {
			AddAlert = function() end,
		}

		LootToastOverride = assert(loadfile("RPGLootFeed/BlizzOverrides/LootToasts.lua"))("TestAddon", ns)
	end)

	describe("OnInitialize", function()
		it("registers PLAYER_ENTERING_WORLD event", function()
			spy.on(LootToastOverride, "RegisterEvent")
			LootToastOverride:OnInitialize()
			assert
				.spy(LootToastOverride.RegisterEvent).was
				.called_with(LootToastOverride, "PLAYER_ENTERING_WORLD", "LootToastHook")
		end)
	end)

	it("hooks LootAlertSystem AddAlert when available", function()
		spy.on(LootToastOverride, "RawHook")
		LootToastOverride:LootToastHook()
		assert
			.spy(LootToastOverride.RawHook).was
			.called_with(LootToastOverride, LootAlertSystem, "AddAlert", "InterceptAddAlert", true)
	end)

	it("does not hook LootAlertSystem AddAlert if already hooked", function()
		spy.on(LootToastOverride, "IsHooked")
		spy.on(LootToastOverride, "RawHook")
		LootToastOverride.IsHooked = function()
			return true
		end
		LootToastOverride:LootToastHook()
		assert.spy(LootToastOverride.RawHook).was_not_called()
	end)

	describe("InterceptAddAlert", function()
		before_each(function()
			LootToastOverride.hooks = { [LootAlertSystem] = { AddAlert = function() end } }
			spy.on(LootToastOverride.hooks[LootAlertSystem], "AddAlert")
		end)

		it("completely skips LootAlertSystem alert if disabled", function()
			ns.db.global.blizzOverrides.disableBlizzLootToasts = true
			LootToastOverride:InterceptAddAlert(nil)
			assert.spy(LootToastOverride.hooks[LootAlertSystem].AddAlert).was_not_called()
		end)

		it("calls the original AddAlert function if not disabled", function()
			ns.db.global.blizzOverrides.disableBlizzLootToasts = false
			LootToastOverride:InterceptAddAlert(nil)
			assert.spy(LootToastOverride.hooks[LootAlertSystem].AddAlert).was_called()
		end)
	end)
end)
