local Logger = G_RLF.RLF:NewModule("Logger", "AceEvent-3.0")
local gui = LibStub("AceGUI-3.0")

local loggerName = G_RLF.addonName .. "Logger"
local defaults = {
	sessionsLogged = 0,
	logs = {},
}

local updateContent
local getLogger
local WOWEVENT = "WOWEVENT"

local eventSource = {
	[G_RLF.addonName] = true,
	[WOWEVENT] = false,
}
local function OnEventSourceChange(_, _, k, v)
	eventSource[k] = v
	updateContent()
end

local debug = "DEBUG"
local info = "INFO"
local warn = "WARN"
local error = "ERROR"
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

local ItemLoot = "ItemLoot"
local Currency = "Currency"
local Money = "Money"
local Reputation = "Reputation"
local Experience = "Experience"
local eventType = {
	[ItemLoot] = true,
	[Currency] = true,
	[Money] = true,
	[Reputation] = true,
	[Experience] = true,
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
local function initializeFrame()
	if not frame then
		frame = gui:Create("Frame")
		frame:SetTitle("Loot Log")
		frame:EnableResize(false)
		frame:SetCallback("OnClose", function(widget)
			gui:Release(widget)
			frame = nil
		end)
		frame:SetLayout("Flow")

		local filterBar = gui:Create("SimpleGroup")
		filterBar:SetFullWidth(true)
		filterBar:SetLayout("Flow")
		frame:AddChild(filterBar)

		contentBox = gui:Create("MultiLineEditBox")
		contentBox:SetLabel("Logs")
		contentBox:DisableButton(true)
		contentBox:SetFullWidth(true)
		contentBox:SetNumLines(23)
		frame:AddChild(contentBox)

		local logSources = gui:Create("Dropdown")
		logSources:SetLabel("Log Sources")
		logSources:SetMultiselect(true)
		logSources:SetList({
			[G_RLF.addonName] = G_RLF.addonName,
			[WOWEVENT] = WOWEVENT,
		}, {
			G_RLF.addonName,
			WOWEVENT,
		})
		logSources:SetCallback("OnValueChanged", OnEventSourceChange)
		for k, v in pairs(eventSource) do
			logSources:SetItemValue(k, v)
		end
		filterBar:AddChild(logSources)

		local logLevels = gui:Create("Dropdown")
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
		filterBar:AddChild(logLevels)

		local logTypes = gui:Create("Dropdown")
		logTypes:SetLabel("Log Types")
		logTypes:SetMultiselect(true)
		logTypes:SetList({
			[ItemLoot] = ItemLoot,
			[Currency] = Currency,
			[Money] = Money,
			[Reputation] = Reputation,
			[Experience] = Experience,
		})
		logTypes:SetCallback("OnValueChanged", OnEventTypeChange)
		for k, v in pairs(eventType) do
			logTypes:SetItemValue(k, v)
		end
		filterBar:AddChild(logTypes)

		local clearButton = gui:Create("Button")
		clearButton:SetText("Clear Current Log")
		clearButton:SetCallback("OnClick", OnClearLog)
		filterBar:AddChild(clearButton)

		frame:DoLayout()
	end
end

getLogger = function()
	if G_RLF.db then
		return G_RLF.db.global.logger.logs[G_RLF.db.global.logger.sessionsLogged]
	end
end

function Logger:OnInitialize()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function Logger:PLAYER_ENTERING_WORLD(_, isLogin, isReload)
	if isLogin then
		G_RLF.db.global.logger = G_RLF.db.global.logger or defaults
		G_RLF.db.global.logger.sessionsLogged = (G_RLF.db.global.logger.sessionsLogged or 0) + 1
		G_RLF.db.global.logger.logs = G_RLF.db.global.logger.logs or {}
		G_RLF.db.global.logger.logs[G_RLF.db.global.logger.sessionsLogged] = {}
		while G_RLF.db.global.logger.sessionsLogged > 3 do
			tremove(G_RLF.db.global.logger.logs, 1)
			G_RLF.db.global.logger.sessionsLogged = G_RLF.db.global.logger.sessionsLogged - 1
		end
		self:Debug("Logger is ready", G_RLF.addonName)
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
		[ItemLoot] = "|cFF00FF00[ITEM]|r ", -- Green for item loot
		[Currency] = "|cFFFFD700[CURR]|r ", -- Gold for currency
		[Money] = "|cFFC0C0C0[GOLD]|r ", -- Silver/Gray for money
		[Reputation] = "|cFF1E90FF[REPU]|r ", -- Blue for reputation
		[Experience] = "|cFF9932CC[EXPR]|r ", -- Purple for experience
	}

	-- Return an empty string for "General" and the corresponding value for others
	return typeColors[type] or ""
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
	return format(" x%s", logEntry.amount)
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

local function formatLogEntry(logEntry)
	return format(
		"[%s] %s: %s%s%s%s%s\n",
		getTimestamp(logEntry),
		getLevel(logEntry),
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
		text = formatLogEntry(logEntry) .. text
	end

	for i, logEntry in ipairs(getLogger()) do
		if eventSource[logEntry.source] then
			if eventLevel[logEntry.level] then
				if eventType[logEntry.type] then
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
		source = source or G_RLF.addonName,
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
	if frame and frame:IsShown() then
		updateContent()
	end
end

function Logger:Debug(message, source, type, id, content, amount, isNew)
	addLogEntry(debug, message, source, type, id, content, amount, isNew)
end

function Logger:Info(message, source, type, id, content, amount, isNew)
	addLogEntry(info, message, source, type, id, content, amount, isNew)
end

function Logger:Warn(message, source, type, id, content, amount, isNew)
	addLogEntry(warn, message, source, type, id, content, amount, isNew)
end

function Logger:Error(message, source, type, id, content, amount, isNew)
	addLogEntry(error, message, source, type, id, content, amount, isNew)
end

function Logger:Trace(type, traceSize)
	local trace = ""
	traceSize = traceSize or 10
	local count = 0
	local logs = getLogger()
	for i = #logs, 1, -1 do
		if logs[i].type == type then
			count = count + 1
			trace = trace .. formatLogEntry(logs[i])
		end
		if count >= traceSize then
			break
		end
	end

	return trace
end

function Logger:Show()
	if frame then
		self:Hide()
	else
		initializeFrame()
		updateContent()
		frame:Show()
	end
end

function Logger:Hide()
	frame:Hide()
end
