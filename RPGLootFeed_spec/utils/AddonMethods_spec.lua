local nsMocks = require("RPGLootFeed_spec._mocks.Internal.addonNamespace")
local assert = require("luassert")
local match = require("luassert.match")
local busted = require("busted")
local before_each = busted.before_each
local describe = busted.describe
local it = busted.it
local setup = busted.setup
local spy = busted.spy
local stub = busted.stub

local function contains_string(state, arguments)
	local expected = arguments[1]
	return function(value)
		return type(value) == "string" and string.find(value, expected, 1, true) ~= nil
	end
end

assert:register(
	"matcher",
	"contains_string",
	contains_string,
	"string contained expected value",
	"string did not contain expected value"
)

describe("AddonMethods", function()
	local _ = match._
	local ns
	describe("load order", function()
		it("loads the file correctly", function()
			-- Mocking the global environment
			require("RPGLootFeed_spec._mocks.WoWGlobals.namespaces.C_CVar")
			require("RPGLootFeed_spec._mocks.WoWGlobals.Functions")
			require("RPGLootFeed_spec._mocks.Libs.LibStub")
			ns = nsMocks:unitLoadedAfter(nsMocks.LoadSections.Locale)
			assert(loadfile("RPGLootFeed/utils/AddonMethods.lua"))("TestAddon", ns)
			assert.is_not_nil(ns.fn)
			assert.is_not_nil(ns.NotifyChange)
			assert.is_not_nil(ns.Print)
			assert.is_not_nil(ns.IsRetail)
			assert.is_not_nil(ns.IsClassic)
			assert.is_not_nil(ns.IsCataClassic)
			assert.is_not_nil(ns.SendMessage)
			assert.is_not_nil(ns.RGBAToHexFormat)
			assert.is_not_nil(ns.LogDebug)
			assert.is_not_nil(ns.LogInfo)
			assert.is_not_nil(ns.LogWarn)
			assert.is_not_nil(ns.LogError)
			assert.is_not_nil(ns.CreatePatternSegmentsForStringNumber)
			assert.is_not_nil(ns.ExtractDynamicsFromPattern)
			assert.is_not_nil(ns.OpenOptions)
			assert.is_not_nil(ns.TableToCommaSeparatedString)
			assert.is_not_nil(ns.FontFlagsToString)
		end)
	end)

	describe("functionality", function()
		local functionMocks, errorHandlerSpy
		setup(function()
			functionMocks = require("RPGLootFeed_spec._mocks.WoWGlobals.Functions")
			local libStubMocks = require("RPGLootFeed_spec._mocks.Libs.LibStub")
			errorHandlerSpy = functionMocks.errorhandlerSpy
			-- Define the global G_RLF
			ns = nsMocks:unitLoadedAfter(nsMocks.LoadSections.All)
			stub(ns.RLF, "GetModule", function(_, moduleName)
				if moduleName == "Logger" then
					local module = {
						moduleName = "Logger",
					}
					stub(module, "Trace").returns("Trace")
					return module
				end
			end)
			-- Load the module before each test
			assert(loadfile("RPGLootFeed/utils/AddonMethods.lua"))("TestAddon", ns)
		end)

		describe("fn", function()
			it("calls the function with xpcall and errorhandler", function()
				local funcSpy = spy.new(function() end)
				local func = function(...)
					funcSpy(...)
				end
				ns:fn(func, 1, 2, 3)
				assert.spy(funcSpy).was.called_with(1, 2, 3)
			end)

			it("calls the errorhandler when the function throws an error", function()
				local func = function()
					error("test error")
				end
				pcall(function()
					ns:fn(func)
				end)
				assert.stub(errorHandlerSpy).was.called(1)
				---@diagnostic disable-next-line: undefined-field
				assert.spy(errorHandlerSpy).was.not_called_with(match.contains_string("Trace"))
			end)

			it("calls the errorhandler with stack trace if the calling module function throws an error", function()
				local func = function()
					error("test error")
				end
				local module = { moduleName = "TestModule" }
				pcall(function()
					ns.fn(module, func)
				end)
				---@diagnostic disable-next-line: undefined-field
				assert.spy(errorHandlerSpy).was.called_with(match.contains_string("Trace"))
			end)
		end)

		describe("SendMessage", function()
			it("sends a message to the addon channel", function()
				ns.RLF.SendMessage = spy.new(function() end)
				ns:SendMessage("TEST_TOPIC", "test message", 1)
				assert.spy(ns.RLF.SendMessage).was.called_with(_, "TEST_TOPIC", "test message", 1)
			end)
		end)

		describe("logging", function()
			it("logs a debug message", function()
				ns.SendMessage = spy.new(function() end)
				ns:LogDebug("test debug message")
				assert.spy(ns.SendMessage).was.called_with(_, "RLF_LOG", { "DEBUG", "test debug message" })
			end)

			it("logs an info message", function()
				ns.SendMessage = spy.new(function() end)
				ns:LogInfo("test info message")
				assert.spy(ns.SendMessage).was.called_with(_, "RLF_LOG", { "INFO", "test info message" })
			end)

			it("logs a warning message", function()
				ns.SendMessage = spy.new(function() end)
				ns:LogWarn("test warning message")
				assert.spy(ns.SendMessage).was.called_with(_, "RLF_LOG", { "WARN", "test warning message" })
			end)

			it("logs an error message", function()
				ns.SendMessage = spy.new(function() end)
				ns:LogError("test error message")
				assert.spy(ns.SendMessage).was.called_with(_, "RLF_LOG", { "ERROR", "test error message" })
			end)
		end)

		describe("RGBAToHexFormat", function()
			it("converts RGBA01 to WoW's hex color format", function()
				local result = ns:RGBAToHexFormat(0.1, 0.2, 0.3, 0.4)
				assert.are.equal(result, "|c6619334C")
			end)
		end)

		describe("Print", function()
			it("prints a message using RLF's Print method", function()
				ns.RLF.Print = spy.new(function() end)
				ns:Print("test message")
				assert.spy(ns.RLF.Print).was.called_with(_, "test message")
			end)
		end)

		describe("CreatePatternSegmentsForStringNumber", function()
			it("creates pattern segments for a string with a number", function()
				local segments = ns:CreatePatternSegmentsForStringNumber("Hello %s, you have %d messages")
				assert.are.same(segments, { "Hello ", ", you have ", " messages" })
			end)
		end)

		describe("ExtractDynamicsFromPattern", function()
			it("extracts dynamic parts from a pattern", function()
				local segments = { "Hello ", ", you have ", " messages" }
				local str, num = ns:ExtractDynamicsFromPattern("Hello John, you have 5 messages", segments)
				assert.are.equal(str, "John")
				assert.are.equal(num, 5)
			end)

			it("extracts dynamic parts from a pattern that ends with a number", function()
				local segments = { "Hello ", ", you got ", "" }
				local str, num = ns:ExtractDynamicsFromPattern("Hello John, you got 5", segments)
				assert.are.equal(str, "John")
				assert.are.equal(num, 5)
			end)

			it("returns nil if the pattern does not match", function()
				local segments = { "Hello ", ", you have ", " messages" }
				local str, num = ns:ExtractDynamicsFromPattern("Goodbye John, you have 5 messages", segments)
				assert.is_nil(str)
				assert.is_nil(num)
			end)
		end)
	end)
end)
