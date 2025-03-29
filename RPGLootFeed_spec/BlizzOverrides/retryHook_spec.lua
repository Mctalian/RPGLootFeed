local assert = require("luassert")
local match = require("luassert.match")
local busted = require("busted")
local before_each = busted.before_each
local describe = busted.describe
local it = busted.it
local spy = busted.spy

describe("retryHook function", function()
	local module, ns
	local _ = match._

	before_each(function()
		module = {
			ScheduleTimer = function() end,
		}
		ns = {
			Print = function() end,
			L = {
				["Issues"] = "There are issues.",
				["TestLocaleKey"] = "Test locale message.",
			},
		}
		assert(loadfile("RPGLootFeed/BlizzOverrides/retryHook.lua"))("TestAddon", ns)
	end)

	it("should schedule the hook function if attempts are less than or equal to 30", function()
		spy.on(module, "ScheduleTimer")
		local attempts = ns.retryHook(module, 0, "hookFunctionName", "TestLocaleKey")
		assert.are.equal(attempts, 1)
		assert.spy(module.ScheduleTimer).was.called_with(module, "hookFunctionName", 1)
	end)

	it("should print an error message if attempts exceed 30", function()
		spy.on(module, "ScheduleTimer")
		spy.on(ns, "Print")
		local attempts = ns.retryHook(module, 30, "hookFunctionName", "TestLocaleKey")
		assert.are.equal(attempts, 30)
		assert.spy(module.ScheduleTimer).was.not_called()
		assert.spy(ns.Print).was.called(2)
		assert.spy(ns.Print).was.called_with(_, ns.L["TestLocaleKey"])
		assert.spy(ns.Print).was.called_with(_, ns.L["Issues"])
	end)
end)
