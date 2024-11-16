local addonName, G_RLF = ...

local Logger = G_RLF.RLF:NewModule("Logger", "AceBucket-3.0", "AceEvent-3.0")
local gui = LibStub("AceGUI-3.0")

local loggerName = addonName .. "Logger"
local defaults = {
	sessionsLogged = 0,
	logs = {},
}

local updateContent
local function getLogger()
	if G_RLF.db.global.logger ~= nil and G_RLF.db.global.logger.sessionsLogged > 0 then
		return G_RLF.db.global.logger.logs[G_RLF.db.global.logger.sessionsLogged]
	end
end
local WOWEVENT = G_RLF.LogEventSource.WOWEVENT

local eventSource = {
	[G_RLF.LogEventSource.ADDON] = true,
	[WOWEVENT] = false,
}
local function OnEventSourceChange(_, _, k, v)
	eventSource[k] = v
	updateContent()
end

local debug = G_RLF.LogLevel.debug
local info = G_RLF.LogLevel.info
local warn = G_RLF.LogLevel.warn
local error = G_RLF.LogLevel.error
local eventLevel = {
	[debug] = false,
	[info] = true,
	[warn] = true,
	[error] = true,
}
local function OnEventLevelChange(_, _, k, v)
	eventLevel[k] = v
	updateContent()
end

local ItemLoot = G_RLF.FeatureModule.ItemLoot
local Currency = G_RLF.FeatureModule.Currency
local Money = G_RLF.FeatureModule.Money
local Reputation = G_RLF.FeatureModule.Reputation
local Experience = G_RLF.FeatureModule.Experience
local Profession = G_RLF.FeatureModule.Profession
local eventType = {
	[ItemLoot] = true,
	[Currency] = true,
	[Money] = true,
	[Reputation] = true,
	[Experience] = true,
	[Profession] = true,
}
local function OnEventTypeChange(_, _, k, v)
	eventType[k] = v
	updateContent()
end

local function OnClearLog()
	local count = #getLogger()
	for i = 0, count do
		getLogger()[i] = nil
	end
	updateContent()
end

local frame, contentBox
function Logger:InitializeFrame()
	if not frame then
		frame = gui:Create("Frame")
		frame:Hide()
		RunNextFrame(function()
			frame:SetTitle("Loot Log")
			frame:EnableResize(false)
			frame:SetCallback("OnClose", function(widget)
				gui:Release(widget)
				frame = nil
			end)
			frame:SetLayout("Flow")
		end)

		local filterBar = gui:Create("SimpleGroup")
		frame:AddChild(filterBar)
		RunNextFrame(function()
			filterBar:SetFullWidth(true)
			filterBar:SetLayout("Flow")
		end)

		contentBox = gui:Create("MultiLineEditBox")
		frame:AddChild(contentBox)
		RunNextFrame(function()
			contentBox:SetLabel("Logs")
			contentBox:DisableButton(true)
			contentBox:SetFullWidth(true)
			contentBox:SetNumLines(23)
		end)

		local logSources = gui:Create("Dropdown")
		filterBar:AddChild(logSources)
		RunNextFrame(function()
			logSources:SetLabel("Log Sources")
			logSources:SetMultiselect(true)
			logSources:SetList({
				[addonName] = addonName,
				[WOWEVENT] = WOWEVENT,
			}, {
				addonName,
				WOWEVENT,
			})
			logSources:SetCallback("OnValueChanged", OnEventSourceChange)
			for k, v in pairs(eventSource) do
				logSources:SetItemValue(k, v)
			end
		end)

		local logLevels = gui:Create("Dropdown")
		filterBar:AddChild(logLevels)
		RunNextFrame(function()
			logLevels:SetLabel("Log Levels")
			logLevels:SetMultiselect(true)
			logLevels:SetList({
				[debug] = debug,
				[info] = info,
				[warn] = warn,
				[error] = error,
			})
			logLevels:SetCallback("OnValueChanged", OnEventLevelChange)
			for k, v in pairs(eventLevel) do
				logLevels:SetItemValue(k, v)
			end
		end)

		local logTypes = gui:Create("Dropdown")
		filterBar:AddChild(logTypes)
		RunNextFrame(function()
			logTypes:SetLabel("Log Types")
			logTypes:SetMultiselect(true)
			logTypes:SetList({
				[ItemLoot] = ItemLoot,
				[Currency] = Currency,
				[Money] = Money,
				[Reputation] = Reputation,
				[Experience] = Experience,
				[Profession] = Profession,
			})
			logTypes:SetCallback("OnValueChanged", OnEventTypeChange)
			for k, v in pairs(eventType) do
				logTypes:SetItemValue(k, v)
			end
		end)

		local clearButton = gui:Create("Button")
		filterBar:AddChild(clearButton)
		RunNextFrame(function()
			clearButton:SetText("Clear Current Log")
			clearButton:SetCallback("OnClick", OnClearLog)
		end)

		RunNextFrame(function()
			frame:DoLayout()
		end)
	end
end

function Logger:OnInitialize()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterBucketMessage("RLF_LOG", 0.5, "ProcessLogs")
	RunNextFrame(function()
		self:InitializeFrame()
	end)
end

function Logger:PLAYER_ENTERING_WORLD(_, isLogin, isReload)
	if isLogin then
		G_RLF.db.global.logger.sessionsLogged = (G_RLF.db.global.logger.sessionsLogged or 0) + 1
		G_RLF.db.global.logger.logs = G_RLF.db.global.logger.logs or {}
		G_RLF.db.global.logger.logs[G_RLF.db.global.logger.sessionsLogged] = {}
		while G_RLF.db.global.logger.sessionsLogged > 3 do
			tremove(G_RLF.db.global.logger.logs, 1)
			G_RLF.db.global.logger.sessionsLogged = G_RLF.db.global.logger.sessionsLogged - 1
		end
		G_RLF:LogDebug("Logger is ready", addonName)
	end
end

local function getLevel(logEntry)
	local level = logEntry.level
	local levelColors = {
		[debug] = "|cFF808080{D}|r", -- Gray for DEBUG
		[info] = "|cFFADD8E6{I}|r", -- Light blue for INFO (ADD8E6 in hex)
		[warn] = "|cFFFFD700{W}|r", -- Gold for WARN
		[error] = "|cFFFF0000{E}|r", -- Red for ERROR
	}

	-- Return the formatted level or an empty string if the level is not recognized
	return levelColors[level] or ""
end

local function getType(logEntry)
	local type = logEntry.type
	local typeColors = {
		[ItemLoot] = "|cFF00FF00[ITEM]|r", -- Green for item loot
		[Currency] = "|cFFFFD700[CURR]|r", -- Gold for currency
		[Money] = "|cFFC0C0C0[GOLD]|r", -- Silver/Gray for money
		[Reputation] = "|cFF1E90FF[REPU]|r", -- Blue for reputation
		[Experience] = "|cFF9932CC[EXPR]|r", -- Purple for experience
		[Profession] = "|cFF8B4513[PROF]|r", -- Brown for profession
	}

	-- Return an empty string for "General" and the corresponding value for others
	return typeColors[type] or ""
end

local function getSource(logEntry)
	local source = logEntry.source
	local sourceStrings = {
		[addonName] = "(" .. addonName .. ")",
		[WOWEVENT] = "(WOW)",
	}
	return sourceStrings[source] or ""
end

local function getTimestamp(logEntry)
	-- Extract the time portion from the timestamp using pattern matching
	local timeOnly = logEntry.timestamp:match("%d%d:%d%d:%d%d")

	-- Return the formatted timestamp with dark gray color
	return "|cFF808080" .. timeOnly .. "|r"
end

local function getContent(logEntry)
	if logEntry.content == "" then
		return logEntry.message
	end
	return logEntry.content
end

local function getAmount(logEntry)
	if logEntry.amount == "" then
		return ""
	end
	return format(" (tot: %s)", logEntry.amount)
end

local function isUpdatedRow(logEntry)
	if logEntry.new == false then
		return " ~UPDATE~"
	end
	return ""
end

local function getId(logEntry)
	if logEntry.id == "" then
		return ""
	end
	return format(" [%s]", logEntry.id)
end

function Logger:FormatLogEntry(logEntry)
	return format(
		"[%s]%s%s%s: %s%s%s%s\n",
		getTimestamp(logEntry),
		getLevel(logEntry),
		getSource(logEntry),
		getType(logEntry),
		getContent(logEntry),
		getAmount(logEntry),
		isUpdatedRow(logEntry),
		getId(logEntry)
	)
end

updateContent = function()
	local text = ""

	local function addText(logEntry)
		text = Logger:FormatLogEntry(logEntry) .. text
	end

	for i, logEntry in ipairs(getLogger()) do
		if eventSource[logEntry.source] then
			if eventLevel[logEntry.level] then
				if eventType[logEntry.type] or logEntry.type == "General" then
					addText(logEntry)
				end
			end
		end
	end
	contentBox:SetText(text)
end

local function addLogEntry(level, message, source, type, id, content, amount, isNew)
	local entry = {
		timestamp = date("%Y-%m-%d %H:%M:%S"),
		level = level,
		source = source or addonName,
		type = type or "General",
		id = id or "",
		content = content or "",
		amount = amount or "",
		new = isNew,
		message = message,
	}
	local logTable = getLogger()
	if not logTable then
		-- error("Log Table not ready")
		return
	end
	table.insert(logTable, entry)
	--[===[@non-alpha@
	while #logTable > 100 do
		table.remove(logTable, 1)
	end
	--@end-non-alpha@]===]
	if frame and frame:IsShown() then
		updateContent()
	end
end

function Logger:ProcessLogs(logs)
	for log, _ in pairs(logs) do
		addLogEntry(unpack(log))
	end
end

function Logger:Trace(type, traceSize)
	local trace = ""
	traceSize = traceSize or 10
	local count = 0
	local logs = getLogger()
	for i = #logs, 1, -1 do
		if logs[i].type == type then
			count = count + 1
			trace = trace .. self:FormatLogEntry(logs[i])
		end
		if count >= traceSize then
			break
		end
	end

	return trace
end

function Logger:Show()
	if frame:IsShown() then
		self:Hide()
	else
		updateContent()
		frame:Show()
	end
end

function Logger:Hide()
	frame:Hide()
end

return Logger
