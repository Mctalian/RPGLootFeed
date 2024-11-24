local common_stubs = require("spec/common_stubs")

describe("Logger module", function()
    local ns, Logger

    before_each(function()
        -- Define the global G_RLF
        ns = ns or common_stubs.setup_G_RLF(spy)
        ns.db.global.logger = {
            sessionsLogged = 0,
            logs = { },
        }

        -- Load the module before each test
        Logger = assert(loadfile("utils/Logger.lua"))("TestAddon", ns)
    end)

		describe("addon initialization", function()
			it("initializes the logger", function()
					spy.on(Logger, "RegisterEvent")
					spy.on(Logger, "RegisterBucketMessage")
					spy.on(Logger, "InitializeFrame")
					Logger:OnInitialize()
					assert.spy(Logger.RegisterEvent).was.called_with(Logger, "PLAYER_ENTERING_WORLD")
					assert.spy(Logger.RegisterBucketMessage).was.called_with(Logger, "RLF_LOG", 0.5, "ProcessLogs")
					assert.spy(Logger.InitializeFrame).was.called()
			end)

			it("increments sessionsLogged on PLAYER_ENTERING_WORLD event", function()
					Logger:PLAYER_ENTERING_WORLD(nil, true, false)
					assert.are.equal(ns.db.global.logger.sessionsLogged, 1)
			end)
		end)

		describe("logging functionality", function()
			before_each(function()
				Logger:OnInitialize()
				Logger:PLAYER_ENTERING_WORLD(nil, true, false)
			end)

			it("adds a log entry", function()
					local logEntry = {
							timestamp = "2023-01-01 12:00:00",
							level = "INFO",
							source = "TestAddon",
							type = "General",
							id = "",
							content = "",
							amount = "",
							new = true,
							message = "Test log entry",
					}
					Logger:ProcessLogs({ [{ logEntry.level, logEntry.message, logEntry.source, logEntry.type, logEntry.id, logEntry.content, logEntry.amount, logEntry.new }] = 1 })
					assert.are.equal(#ns.db.global.logger.logs[1], 1)
					assert.are.same(ns.db.global.logger.logs[1][1], logEntry)
			end)

			it("formats log entries correctly", function()
					local logEntry = {
							timestamp = "2023-01-01 12:00:00",
							level = "INFO",
							source = "TestAddon",
							type = "General",
							id = "",
							content = "",
							amount = "",
							new = true,
							message = "Test log entry",
					}
					local formattedEntry = Logger:FormatLogEntry(logEntry)
					assert.are.equal(formattedEntry, "[|cFF80808012:00:00|r]|cFFADD8E6{I}|r(TestAddon): Test log entry\n")
			end)

			it("hides the frame if it is already shown", function()
					Logger:Show()
					spy.on(Logger, "Hide")
					Logger:Show()
					assert.spy(Logger.Hide).was.called(1)
			end)
		end)
end)
