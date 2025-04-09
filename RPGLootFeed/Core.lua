---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

G_RLF.addonVersion = "@project-version@"

---@class RPGLootFeed: AceAddon, AceConsole, AceEvent, AceHook, AceTimer
---@field public GetModule fun(self: RPGLootFeed, name: string): RLF_Module
---@field public NewModule fun(self: RPGLootFeed, name: string, ...: string): RLF_Module
local RLF = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")
RLF:SetDefaultModuleState(true)
RLF:SetDefaultModulePrototype({
	fn = function(s, func, ...)
		return G_RLF.fn(s, func, ...)
	end,
})

---@class RLF_Module: AceModule
---@field protected fn fun(self: RLF_Module, func: function, ...?: any): any

local function DbMigrations()
	for _, migration in ipairs(G_RLF.migrations) do
		migration:run()
	end
end

G_RLF.localeName = addonName .. "Locale"
G_RLF.lsm = LibStub("LibSharedMedia-3.0")
G_RLF.Masque = LibStub and LibStub("Masque", true)
G_RLF.iconGroup = G_RLF.Masque and G_RLF.Masque:Group(addonName)
local dbName = addonName .. "DB"
G_RLF.acd = LibStub("AceConfigDialog-3.0") --[[@as AceConfigDialog]]
G_RLF.DBIcon = LibStub("LibDBIcon-1.0")

local TestMode
function RLF:OnInitialize()
	---@class RLF_DB : AceDBObject-3.0
	---@field global RLF_DBGlobal
	---@field locale RLF_DBLocale
	---@field profile RLF_DBProfile
	G_RLF.db = LibStub("AceDB-3.0"):New(dbName, G_RLF.defaults, true)
	if G_RLF.db.global.guid == nil then
		-- This is not an identifier associated with your character, but a way
		-- to identify a unique installation of the addon. It cannot be used to
		-- identify a specific character or account.
		G_RLF.db.global.guid = G_RLF:GenerateGUID()
	end
	DbMigrations()
	LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, G_RLF.options)
	local rlfLDB = LibStub("LibDataBroker-1.1"):NewDataObject(addonName, {
		type = "launcher",
		icon = "Interface\\AddOns\\RPGLootFeed\\Icons\\logo.blp",
		OnClick = function(og_frame, button)
			G_RLF:OpenOptions(button)
		end,
		OnTooltipShow = function(tooltip)
			tooltip:AddLine(
				G_RLF:RGBAToHexFormat(1, 0.5, 0, 1)
					.. addonName
					.. "|r "
					.. G_RLF:RGBAToHexFormat(0.2, 0.5, 0.4, 1)
					.. G_RLF.addonVersion
					.. "|r"
			)
			tooltip:AddLine(" ")
			local unseenNotifications = G_RLF.Notifications:GetNumUnseenNotifications()
			if unseenNotifications > 0 then
				local notifStr = string.format(G_RLF.L["You have Notifications"], unseenNotifications)
				tooltip:AddLine(notifStr, 1, 1, 1, 1)
				tooltip:AddLine(" ")
			end
			tooltip:AddLine(G_RLF.L["LauncherLeftClick"], 1, 1, 1, 1)
			if G_RLF.db.global.lootHistory.enabled or unseenNotifications > 0 then
				tooltip:AddLine(G_RLF.L["LauncherRightClick"], 1, 1, 1, 1)
			end
		end,
	})

	local lsm = G_RLF.lsm
	lsm:Register(lsm.MediaType.FONT, "BAR SADY Regular", "Interface\\AddOns\\RPGLootFeed\\Fonts\\BAR_SADY_Variable.ttf")
	lsm:Register(
		lsm.MediaType.SOUND,
		"LittleRobotSoundFactory - Pickup_Gold_04",
		"Interface\\AddOns\\RPGLootFeed\\Sounds\\Pickup_Gold_04.ogg"
	)
	G_RLF.DBIcon:Register(addonName, rlfLDB, G_RLF.db.global.minimap)
	G_RLF.DBIcon:AddButtonToCompartment(addonName)
	self:Hook(G_RLF.acd, "Open", "OnOptionsOpen")
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

	TestMode = self:GetModule("TestMode") --[[@as RLF_TestMode]]
end

function RLF:SlashCommand(msg, editBox)
	G_RLF:fn(function()
		--@alpha@
		local start, stop = msg:find("test ")
		--@end-alpha@
		if msg == "test" then
			TestMode:ToggleTestMode()
		--@alpha@
		-- Quick testing of item links
		elseif start then
			local itemLink = msg:sub(stop + 1)
			local itemModule = G_RLF.RLF:GetModule("ItemLoot") --[[@as RLF_ItemLoot]]
			itemModule:CHAT_MSG_LOOT("CHAT_MSG_LOOT", itemLink, "", "", "", "", "", "", "", "", "", "", GetPlayerGuid())
		elseif msg == "i" then
			TestMode:IntegrationTest()
		elseif msg == "notif" then
			G_RLF.Notifications:AddNotification("TEST_NOTIF", "Test Notification")
		--@end-alpha@
		elseif msg == "clear" then
			G_RLF.LootDisplay:HideLoot()
		elseif msg == "log" then
			---@type RLF_Logger
			local loggerModule = self:GetModule("Logger") --[[@as RLF_Logger]]
			loggerModule:Show()
		elseif msg == "history" and G_RLF.db.global.lootHistory.enabled then
			---@type RLF_LootDisplayFrame
			local frame = G_RLF.RLF_MainLootFrame
			frame:ToggleHistoryFrame()
			local partyFrame = G_RLF.RLF_PartyLootFrame
			if partyFrame then
				partyFrame:ToggleHistoryFrame()
			end
		else
			G_RLF.acd:Open(addonName)
		end
	end)
end

local currentVersion = "@project-version@"
function RLF:PLAYER_ENTERING_WORLD(event, isLogin, isReload)
	if self.optionsFrame == nil then
		self.optionsFrame = G_RLF.acd:AddToBlizOptions(addonName, addonName)
	end

	local isNewVersion = currentVersion ~= G_RLF.db.global.lastVersionLoaded
	if isLogin and isReload == false and isNewVersion then
		G_RLF.db.global.lastVersionLoaded = currentVersion
		self:Print(G_RLF.L["Welcome"] .. " (" .. currentVersion .. ")")
		if G_RLF.db.global.blizzOverrides.enableAutoLoot then
			C_CVar.SetCVar("autoLootDefault", "1")
		end
	end
	G_RLF.AuctionIntegrations:Init()
	if G_RLF.db.global.money.overrideMoneyLootSound then
		MuteSoundFile(G_RLF.GameSounds.LOOT_SMALL_COIN)
	else
		UnmuteSoundFile(G_RLF.GameSounds.LOOT_SMALL_COIN)
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
				optionsFrame = G_RLF.acd.OpenFrames[name]
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

G_RLF.RLF = RLF

return RLF
