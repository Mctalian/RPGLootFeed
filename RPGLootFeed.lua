local addonName = G_RLF.addonName
RLF = G_RLF.RLF
G_RLF.L = LibStub("AceLocale-3.0"):GetLocale(G_RLF.localeName)

function RLF:OnInitialize()
	G_RLF.db = LibStub("AceDB-3.0"):New(G_RLF.dbName, G_RLF.defaults, true)
	LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, G_RLF.options)
	G_RLF.LootDisplay:Initialize()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
	self:RegisterEvent("CHAT_MSG_LOOT")
	self:RegisterEvent("CHAT_MSG_MONEY")
	self:RegisterEvent("LOOT_READY")
	self:RegisterEvent("PLAYER_XP_UPDATE")
	self:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
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
	G_RLF.Rep:RefreshRepData()
	G_RLF.Xp:Snapshot()
	if isLogin and isReload == false then
		self:Print(G_RLF.L["Welcome"])
		if G_RLF.db.global.enableAutoLoot then
			C_CVar.SetCVar("autoLootDefault", "1")
		end
	end
end

function RLF:CHAT_MSG_COMBAT_FACTION_CHANGE(event, text)
	G_RLF.Rep:FindDelta()
end

function RLF:CURRENCY_DISPLAY_UPDATE(eventName, ...)
	G_RLF.Currency:OnUpdate(...)
end

function RLF:CHAT_MSG_LOOT(eventName, ...)
	G_RLF.Loot:OnItemLooted(...)
end

function RLF:LOOT_READY(eventName)
	G_RLF.Money:Snapshot()
end

function RLF:CHAT_MSG_MONEY(eventName, msg)
	G_RLF.Money:OnMoneyLooted(msg)
end

function RLF:PLAYER_XP_UPDATE(eventName, unitTarget)
	G_RLF.Xp:OnXpChange(unitTarget)
end
