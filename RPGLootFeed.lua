local addonName = G_RLF.addonName
local acd = LibStub("AceConfigDialog-3.0")
RLF = G_RLF.RLF

function RLF:OnInitialize()
	G_RLF.db = LibStub("AceDB-3.0"):New(G_RLF.dbName, G_RLF.defaults, true)
	LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, G_RLF.options)
	self:Hook(acd, "Open", "OnOptionsOpen")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterChatCommand("rlf", "SlashCommand")
	self:RegisterChatCommand("RLF", "SlashCommand")
	self:RegisterChatCommand("rpglootfeed", "SlashCommand")
	self:RegisterChatCommand("rpgLootFeed", "SlashCommand")

	if EditModeManagerFrame then
		EventRegistry:RegisterCallback("EditMode.Enter", function()
			G_RLF.LootDisplay:SetBoundingBoxVisibility(true)
		end)
		EventRegistry:RegisterCallback("EditMode.Exit", function()
			G_RLF.LootDisplay:SetBoundingBoxVisibility(false)
		end)
	end
end

function RLF:SlashCommand(msg, editBox)
	G_RLF:fn(function()
		if msg == "test" then
			G_RLF.TestMode:ToggleTestMode()
		elseif msg == "clear" then
			G_RLF.LootDisplay:HideLoot()
		elseif msg == "log" then
			self:GetModule("Logger"):Show()
		else
			acd:Open(addonName)
		end
	end)
end

local currentVersion = "@project-version@"
function RLF:PLAYER_ENTERING_WORLD(event, isLogin, isReload)
	if self.optionsFrame == nil then
		self.optionsFrame = acd:AddToBlizOptions(addonName, addonName)
	end
	G_RLF:fn(function()
		self:LootToastHook()
		self:BossBannerHook()
	end)
	local isNewVersion = currentVersion ~= G_RLF.db.global.lastVersionLoaded
	if isLogin and isReload == false and isNewVersion then
		G_RLF.db.global.lastVersionLoaded = currentVersion
		self:Print(G_RLF.L["Welcome"] .. " (" .. currentVersion .. ")")
		if G_RLF.db.global.enableAutoLoot then
			C_CVar.SetCVar("autoLootDefault", "1")
		end
	end
end

local optionsFrame
local isOpen = false
function RLF:OnOptionsOpen(...)
	local _, name, container, path = ...
	G_RLF:fn(function()
		if container then
			return
		end
		if name == addonName and not isOpen then
			isOpen = true
			G_RLF.LootDisplay:SetBoundingBoxVisibility(true)
			self:ScheduleTimer(function()
				optionsFrame = acd.OpenFrames[name]
				if self:IsHooked(optionsFrame, "Hide") then
					self:Unhook(optionsFrame, "Hide")
				end
				if optionsFrame and optionsFrame.Hide then
					self:Hook(optionsFrame, "Hide", "OnOptionsClose", true)
				end
			end, 0.25)
		end
	end)
end

function RLF:OnOptionsClose(...)
	G_RLF:fn(function()
		isOpen = false
		G_RLF.LootDisplay:SetBoundingBoxVisibility(false)
		self:Unhook(optionsFrame, "Hide")
		optionsFrame = nil
	end)
end
