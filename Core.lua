local addonName, G_RLF = ...

G_RLF.addonVersion = "@project-version@-@project-revision@-@project-abbreviated-hash@"

local RLF = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")
RLF:SetDefaultModuleState(true)
RLF:SetDefaultModulePrototype({
	fn = function(s, func, ...)
		return G_RLF.fn(s, func, ...)
	end,
})

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
G_RLF.acd = LibStub("AceConfigDialog-3.0")

local TestMode
function RLF:OnInitialize()
	G_RLF.db = LibStub("AceDB-3.0"):New(dbName, G_RLF.defaults, true)
	LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, G_RLF.options)
	local rlfLDB = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject(addonName, {
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
			tooltip:AddLine(G_RLF.L["LauncherLeftClick"], 1, 1, 1, 1)
			if G_RLF.db.global.lootHistory.enabled then
				tooltip:AddLine(G_RLF.L["LauncherRightClick"], 1, 1, 1, 1)
			end
		end,
	})
	G_RLF.DBIcon = LibStub("LibDBIcon-1.0")
	local lsm = G_RLF.lsm
	lsm:Register(lsm.MediaType.FONT, "BAR SADY Regular", "Interface\\AddOns\\RPGLootFeed\\Fonts\\BAR_SADY_Variable.ttf")
	lsm:Register(
		lsm.MediaType.SOUND,
		"LittleRobotSoundFactory - Pickup_Gold_04",
		"Interface\\AddOns\\RPGLootFeed\\Sounds\\Pickup_Gold_04.ogg"
	)
	G_RLF.DBIcon:Register(addonName, rlfLDB, G_RLF.db.global.minimap)
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

	TestMode = self:GetModule("TestMode")
	DbMigrations()
end

function RLF:SlashCommand(msg, editBox)
	G_RLF:fn(function()
		if msg == "test" then
			TestMode:ToggleTestMode()
		--@alpha@
		elseif msg == "i" then
			TestMode:IntegrationTest()
		--@end-alpha@
		elseif msg == "clear" then
			G_RLF.LootDisplay:HideLoot()
		elseif msg == "log" then
			self:GetModule("Logger"):Show()
		elseif msg == "history" and G_RLF.db.global.lootHistory.enabled then
			LootDisplayFrame:ToggleHistoryFrame()
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
