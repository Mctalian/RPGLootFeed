---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

---@class HistoryService
G_RLF.HistoryService = {}

G_RLF.HistoryService.historyShown = false

function G_RLF.HistoryService:ToggleHistoryFrame()
	if not G_RLF.db.global.lootHistory.enabled then
		return
	end

	local show = not G_RLF.HistoryService.historyShown
	G_RLF.HistoryService.historyShown = show

	if show then
		G_RLF.RLF_MainLootFrame:ShowHistoryFrame()
		local partyFrame = G_RLF.RLF_PartyLootFrame
		if partyFrame then
			partyFrame:ShowHistoryFrame()
		end
	else
		G_RLF.RLF_MainLootFrame:HideHistoryFrame()
		local partyFrame = G_RLF.RLF_PartyLootFrame
		if partyFrame then
			partyFrame:HideHistoryFrame()
		end
	end
end

function G_RLF.HistoryService:HideHistoryFrame()
	if G_RLF.HistoryService.historyShown then
		G_RLF.HistoryService.historyShown = false
		G_RLF.RLF_MainLootFrame:HideHistoryFrame()
		local partyFrame = G_RLF.RLF_PartyLootFrame
		if partyFrame then
			partyFrame:HideHistoryFrame()
		end
	end
end
