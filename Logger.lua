local Logger = G_RLF.RLF:NewModule("Logger", "AceEvent-3.0")

local loggerName = G_RLF.addonName .. "Logger"
local defaults = {
	sessionsLogged = 0,
	logs = {},
}

function dump(o)
	if type(o) == "table" then
		local s = "{ "
		for k, v in pairs(o) do
			if type(k) ~= "number" then
				k = '"' .. k .. '"'
			end
			s = s .. "[" .. k .. "] = " .. dump(v) .. ","
		end
		return s .. "} "
	else
		return tostring(o)
	end
end

local frame, editBox

function Logger:OnInitialize()
	G_RLF:Print("Logger Initialized")
	frame = CreateFrame("Frame", "RPGLootFeedLogFrame", UIParent, "BasicFrameTemplateWithInset")
	frame:SetSize(500, 400) -- Width, Height
	frame:SetPoint("CENTER") -- Position on the screen
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

	local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
	scrollFrame:SetSize(475, 360)
	scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -25)

	local content = CreateFrame("Frame", nil, scrollFrame)
	content:SetSize(480, 370) -- Scrollable area
	scrollFrame:SetScrollChild(content)

	editBox = CreateFrame("EditBox", nil, content)
	editBox:SetMultiLine(true)
	editBox:SetFontObject("ChatFontNormal")
	editBox:SetSize(480, 300)
	editBox:SetPoint("TOPLEFT", 10, -15)
	editBox:SetAutoFocus(false)
	editBox:SetScript("OnEscapePressed", function()
		frame:Hide()
	end)
	frame:Hide()
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
	end
end

local function getLogger()
	return G_RLF.db.global.logger.logs[G_RLF.db.global.logger.sessionsLogged]
end

local function updateContent()
	local text = ""
	for i, logEntry in ipairs(getLogger()) do
		text = text .. format("[%s] %s: %s\n", logEntry.timestamp, logEntry.level, logEntry.content)
	end
	editBox:SetText(text)
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
		new = isNew or false,
		message = message,
	}
	table.insert(getLogger(), entry)
	updateContent()
end

function Logger:Info(message, source, type, id, content, amount, isNew)
	addLogEntry("INFO", message, source, type, id, content, amount, isNew)
end

function Logger:Debug(message, source, type, id, content, amount, isNew)
	addLogEntry("DEBUG", message, source, type, id, content, amount, isNew)
end

function Logger:Error(message, source, type, id, content, amount, isNew)
	addLogEntry("ERROR", message, source, type, id, content, amount, isNew)
end

function Logger:Warn(message, source, type, id, content, amount, isNew)
	addLogEntry("WARN", message, source, type, id, content, amount, isNew)
end

function Logger:Dump()
	G_RLF:Print(dump(getLogger()))
end

function Logger:Show()
	updateContent()
	frame:Show()
end
