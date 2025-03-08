local addonName, G_RLF = ...

local Logger = G_RLF.RLF:NewModule("Logger", "AceBucket-3.0", "AceEvent-3.0")
local gui = LibStub("AceGUI-3.0")

local updateContent
local logger = nil
local initialized = false
local function getLogger()
	if not initialized then
		initialized = true
		G_RLF.db.global.logger = {}
	end
	if logger == nil then
		logger = G_RLF.db.global.logger or {}
	end

	return logger
end
local WOWEVENT = G_RLF.LogEventSource.WOWEVENT

local eventSource = {
	[G_RLF.LogEventSource.ADDON] = true,
	[WOWEVENT] = true,
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
	[debug] = true,
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
	logger = {}
	updateContent()
end

local createLoggerFrames
local createFilterBar
local createContentBox
local createFilterBarComponents

createLoggerFrames = function(l)
	if not l.frame then
		l.frame = gui:Create("Frame")
		l.frame:Hide()
		l.frame:SetLayout("Flow")
		l.frame:SetTitle("Loot Log")
		l.frame:EnableResize(false)
	end

	RunNextFrame(function()
		createFilterBar(l.frame)
		createContentBox(l.frame)
	end)
end

createContentBox = function(f)
	if not f.contentBox then
		f.contentBox = gui:Create("MultiLineEditBox")
		f:AddChild(f.contentBox)
		f.contentBox:SetLabel("Logs")
		f.contentBox:DisableButton(true)
		f.contentBox:SetFullWidth(true)
		f.contentBox:SetNumLines(23)
	end
end

createFilterBar = function(f)
	if not f.filterBar then
		f.filterBar = gui:Create("SimpleGroup")
		f:AddChild(f.filterBar)
		f.filterBar:SetFullWidth(true)
		f.filterBar:SetLayout("Flow")
	end
	RunNextFrame(function()
		createFilterBarComponents(f.filterBar)
	end)
end

createFilterBarComponents = function(fB)
	if not fB.logSources then
		fB.logSources = gui:Create("Dropdown")
		fB:AddChild(fB.logSources)
		RunNextFrame(function()
			fB.logSources:SetLabel("Log Sources")
			fB.logSources:SetMultiselect(true)
			fB.logSources:SetList({
				[addonName] = addonName,
				[WOWEVENT] = WOWEVENT,
			}, {
				addonName,
				WOWEVENT,
			})
			fB.logSources:SetCallback("OnValueChanged", OnEventSourceChange)
			for k, v in pairs(eventSource) do
				fB.logSources:SetItemValue(k, v)
			end
		end)
	end

	if not fB.logLevels then
		fB.logLevels = gui:Create("Dropdown")
		fB:AddChild(fB.logLevels)
		RunNextFrame(function()
			fB.logLevels:SetLabel("Log Levels")
			fB.logLevels:SetMultiselect(true)
			fB.logLevels:SetList({
				[debug] = debug,
				[info] = info,
				[warn] = warn,
				[error] = error,
			})
			fB.logLevels:SetCallback("OnValueChanged", OnEventLevelChange)
			for k, v in pairs(eventLevel) do
				fB.logLevels:SetItemValue(k, v)
			end
		end)
	end

	if not fB.logTypes then
		fB.logTypes = gui:Create("Dropdown")
		fB:AddChild(fB.logTypes)
		RunNextFrame(function()
			fB.logTypes:SetLabel("Log Types")
			fB.logTypes:SetMultiselect(true)
			fB.logTypes:SetList({
				[ItemLoot] = ItemLoot,
				[Currency] = Currency,
				[Money] = Money,
				[Reputation] = Reputation,
				[Experience] = Experience,
				[Profession] = Profession,
			})
			fB.logTypes:SetCallback("OnValueChanged", OnEventTypeChange)
			for k, v in pairs(eventType) do
				fB.logTypes:SetItemValue(k, v)
			end
		end)
	end

	if not fB.clearButton then
		fB.clearButton = gui:Create("Button")
		fB:AddChild(fB.clearButton)
		RunNextFrame(function()
			fB.clearButton:SetText("Clear Current Log")
			fB.clearButton:SetCallback("OnClick", OnClearLog)
		end)
	end

	RunNextFrame(function()
		Logger.frame:DoLayout()
	end)
end

--@alpha@
createLoggerFrames = G_RLF:ProfileFunction(createLoggerFrames, "createLoggerFrames")
createContentBox = G_RLF:ProfileFunction(createContentBox, "createContentBox")
createFilterBar = G_RLF:ProfileFunction(createFilterBar, "createFilterBar")
createFilterBarComponents = G_RLF:ProfileFunction(createFilterBarComponents, "createFilterBarComponents")
--@end-alpha@

function Logger:InitializeFrame()
	if not self.frame then
		RunNextFrame(function()
			createLoggerFrames(self)
		end)
	end
end

function Logger:OnInitialize()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_LEAVING_WORLD")
	self:RegisterBucketMessage("RLF_LOG", 0.5, "ProcessLogs")
	RunNextFrame(function()
		self:InitializeFrame()
	end)
end

function Logger:PLAYER_ENTERING_WORLD(_, isLogin, isReload)
	if isLogin then
		if not initialized then
			initialized = true
			G_RLF.db.global.logger = {}
		end
	else
		logger = G_RLF.db.global.logger or {}
	end
end

function Logger:PLAYER_LEAVING_WORLD()
	G_RLF.db.global.logger = logger
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
	return logEntry.content .. " MSG: " .. logEntry.message
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
	RunNextFrame(function()
		Logger.frame.contentBox:SetText(text)
	end)
end

function Logger:addLogEntry(level, message, source, type, id, content, amount, isNew)
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
	if self.frame and self.frame:IsShown() then
		updateContent()
	end
end

function Logger:ProcessLogs(logs)
	for log, _ in pairs(logs) do
		RunNextFrame(function()
			self:addLogEntry(unpack(log))
		end)
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
	if self.frame:IsShown() then
		self:Hide()
	else
		updateContent()
		RunNextFrame(function()
			self.frame:Show()
		end)
	end
end

function Logger:Hide()
	self.frame:Hide()
end

return Logger
