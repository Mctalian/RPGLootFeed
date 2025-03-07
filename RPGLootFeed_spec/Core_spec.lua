local common_stubs = require("RPGLootFeed_spec/common_stubs")

describe("Core module", function()
	local ns, RLF
	local _ = match._

	before_each(function()
		ns = common_stubs.setup_G_RLF(spy)
		ns.L = {
			Welcome = "Welcome",
		}
		ns.LootDisplay = {
			SetBoundingBoxVisibility = function() end,
			HideLoot = function() end,
		}
		ns.DbMigrations = {
			Migrate = function() end,
		}
		RLF = assert(loadfile("RPGLootFeed/Core.lua"))("TestAddon", ns)
		RLF.GetModule = function(_, moduleName)
			if moduleName == "TestMode" then
				return {}
			end
		end
		RLF.Hook = spy.new(function() end)
		RLF.Unhook = spy.new(function() end)
		RLF.RegisterEvent = spy.new(function() end)
		RLF.UnregisterEvent = spy.new(function() end)
		RLF.RegisterChatCommand = spy.new(function() end)
		RLF.Print = spy.new(function() end)
		RLF.ScheduleTimer = function() end
	end)

	describe("addon initialization", function()
		it("should initialize correctly", function()
			spy.on(RLF, "OnInitialize")
			RLF:OnInitialize()
			assert.spy(RLF.OnInitialize).was.called(1)
		end)
	end)

	describe("OnSlashCommand", function()
		it("should handle test mode command correctly", function()
			local TestMode = {
				ToggleTestMode = function() end,
			}
			local spyToggleTestMode = spy.on(TestMode, "ToggleTestMode")
			RLF.GetModule = function(_, moduleName)
				if moduleName == "TestMode" then
					return TestMode
				end
			end

			RLF:OnInitialize()
			RLF:SlashCommand("test")
			assert.spy(spyToggleTestMode).was.called(1)
		end)

		it("should handle unknown command correctly", function()
			local acd = ns.LibStubReturn["AceConfigDialog-3.0"]
			spy.on(acd, "Open")
			RLF:OnInitialize()
			RLF:SlashCommand("unknown")
			assert.spy(acd.Open).was.called_with(_, "TestAddon")
		end)
	end)

	describe("PLAYER_ENTERING_WORLD", function()
		it("should handle PLAYER_ENTERING_WORLD event correctly", function()
			ns.db.global.blizzOverrides.enableAutoLoot = true
			spy.on(RLF, "PLAYER_ENTERING_WORLD")
			RLF:PLAYER_ENTERING_WORLD("PLAYER_ENTERING_WORLD", true, false)
			assert.spy(RLF.PLAYER_ENTERING_WORLD).was.called(1)
		end)
	end)

	describe("OnOptionsOpen/OnOptionsClose", function()
		it("shows the bounding box when the options are opened", function()
			local spyScheduleTimer = spy.on(RLF, "ScheduleTimer")
			local spySetBoundingBoxViz = spy.on(ns.LootDisplay, "SetBoundingBoxVisibility")
			RLF:OnOptionsOpen(nil, "TestAddon", nil, nil)
			assert.spy(spyScheduleTimer).was.called(1)
			assert.spy(spySetBoundingBoxViz).was.called_with(_, true)
		end)

		it("does nothing if the options are already open", function()
			local spyScheduleTimer = spy.on(RLF, "ScheduleTimer")
			local spySetBoundingBoxViz = spy.on(ns.LootDisplay, "SetBoundingBoxVisibility")
			RLF:OnOptionsOpen(nil, "TestAddon", nil, nil)
			RLF:OnOptionsOpen(nil, "TestAddon", nil, nil)
			assert.spy(spyScheduleTimer).was.called(1)
			assert.spy(spySetBoundingBoxViz).was.called(1)
		end)

		it("hides the bounding box when the options are closed", function()
			local spySetBoundingBoxViz = spy.on(ns.LootDisplay, "SetBoundingBoxVisibility")
			RLF:OnOptionsOpen(nil, "TestAddon", nil, nil)
			RLF:OnOptionsClose(nil, "TestAddon", nil, nil)
			assert.spy(spySetBoundingBoxViz).was.called_with(_, false)
		end)
	end)
end)
