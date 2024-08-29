local addonName = G_RLF.addonName
RLF = G_RLF.RLF
G_RLF.L = LibStub("AceLocale-3.0"):GetLocale(G_RLF.localeName)

function RLF:OnInitialize()
	G_RLF.db = LibStub("AceDB-3.0"):New(G_RLF.dbName, G_RLF.defaults, true)
	LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, G_RLF.options)
	G_RLF.LootDisplay:Initialize()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterChatCommand("rlf", "SlashCommand")
	self:RegisterChatCommand("RLF", "SlashCommand")
	self:RegisterChatCommand("rpglootfeed", "SlashCommand")
	self:RegisterChatCommand("rpgLootFeed", "SlashCommand")
end

function RLF:SlashCommand(msg, editBox)
	if msg == "test" then
		G_RLF.TestMode:ToggleTestMode()
	elseif msg == "clear" then
		G_RLF.LootDisplay:HideLoot()
	else
		LibStub("AceConfigDialog-3.0"):Open(addonName)
	end
end

function RLF:PLAYER_ENTERING_WORLD(event, isLogin, isReload)
	if self.optionsFrame == nil then
		self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, addonName)
	end
	self:LootToastHook()
	self:BossBannerHook()
	if isLogin and isReload == false then
		self:Print(G_RLF.L["Welcome"])
		if G_RLF.db.global.enableAutoLoot then
			C_CVar.SetCVar("autoLootDefault", "1")
		end
	end
end
