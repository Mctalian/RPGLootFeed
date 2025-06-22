---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

---@class HistoryService
G_RLF.HistoryService = {
	---@type boolean
	historyShown = false,
}

function G_RLF.HistoryService:ToggleHistoryFrame()
	if not G_RLF.db.global.lootHistory.enabled then
		return
	end

	local show = not self.historyShown
	self.historyShown = show

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
	if self.historyShown then
		self.historyShown = false
		G_RLF.RLF_MainLootFrame:HideHistoryFrame()
		local partyFrame = G_RLF.RLF_PartyLootFrame
		if partyFrame then
			partyFrame:HideHistoryFrame()
		end
	end
end
