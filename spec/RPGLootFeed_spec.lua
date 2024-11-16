local common_stubs = require("spec/common_stubs")

describe("RPGLootFeed module", function()
	local RLF, ns
	before_each(function()
		_G.LibStub = function()
			return {
				GetLocale = function() end,
				New = function()
					return { global = {} }
				end,
				RegisterOptionsTable = function() end,
				AddToBlizOptions = function() end,
			}
		end
		_G.C_CVar = {
			SetCVar = function() end,
		}
		_G.EventRegistry = {
			RegisterCallback = function() end,
		}

		ns = ns or common_stubs.setup_G_RLF(spy)
		ns.lsm = {
			Register = spy.new(),
			MediaType = {
				FONT = "font",
			},
		}
		ns.L = {
			Welcome = "Welcome",
		}
		ns.LootDisplay = {
			SetBoundingBoxVisibility = function() end,
			HideLoot = function() end,
		}
		-- Load the list module before each test
		RLF = assert(loadfile("RPGLootFeed.lua"))("TestAddon", ns)
		RLF.GetModule = function(_, moduleName)
			if moduleName == "TestMode" then
				return {}
			end
		end
		RLF.Hook = spy.new()
		RLF.Unhook = spy.new()
		RLF.RegisterEvent = spy.new()
		RLF.UnregisterEvent = spy.new()
		RLF.RegisterChatCommand = spy.new()
		RLF.Print = spy.new()
		RLF.ScheduleTimer = function() end
	end)

	it("should initialize correctly", function()
		spy.on(RLF, "OnInitialize")
		RLF:OnInitialize()
		assert.spy(RLF.OnInitialize).was.called()
	end)

	it("should handle slash commands correctly", function()
		local TestMode = {
			ToggleTestMode = function() end,
		}
		spy.on(TestMode, "ToggleTestMode")
		RLF.GetModule = function(_, moduleName)
			if moduleName == "TestMode" then
				return TestMode
			end
		end

		RLF:OnInitialize()
		RLF:SlashCommand("test")
		assert.spy(TestMode.ToggleTestMode).was.called()
	end)

	it("should handle PLAYER_ENTERING_WORLD event correctly", function()
		spy.on(RLF, "PLAYER_ENTERING_WORLD")
		RLF:PLAYER_ENTERING_WORLD("PLAYER_ENTERING_WORLD", true, false)
		assert.spy(RLF.PLAYER_ENTERING_WORLD).was.called()
	end)

	it("should open options correctly", function()
		spy.on(RLF, "OnOptionsOpen")
		RLF:OnOptionsOpen(nil, "TestAddon", nil, nil)
		assert.spy(RLF.OnOptionsOpen).was.called()
	end)

	it("should close options correctly", function()
		spy.on(RLF, "OnOptionsClose")
		RLF:OnOptionsClose()
		assert.spy(RLF.OnOptionsClose).was.called()
	end)
end)
