---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

---@class ClassicToRetail
---@field ConvertFactionInfoByID fun(s: ClassicToRetail, id: number): table | nil
---@field ConvertFactionInfoByIndex fun(s: ClassicToRetail, index: number): table | nil
G_RLF.ClassicToRetail = {}

---Convert faction info from Classic to Retail format
---@param t table
---@return table | nil
local function convertFactionInfo(t)
	if not t[1] then
		return nil
	end
	return {
		name = t[1],
		description = t[2],
		reaction = t[3],
		currentReactionThreshold = t[4],
		nextReactionThreshold = t[5],
		currentStanding = t[6],
		atWarWith = t[7],
		canToggleAtWar = t[8],
		isHeader = t[9],
		isCollapsed = t[10],
		isHeaderWithRep = t[11],
		isWatched = t[12],
		isChild = t[13],
		factionID = t[14],
		canSetInactive = false,
		hasBonusRepGain = false,
		isAccountWide = false,
	}
end

function G_RLF.ClassicToRetail:ConvertFactionInfoByID(id)
	local legacyFactionData = { GetFactionInfoByID(id) }
	return convertFactionInfo(legacyFactionData)
end

function G_RLF.ClassicToRetail:ConvertFactionInfoByIndex(index)
	local legacyFactionData = { GetFactionInfo(index) }
	return convertFactionInfo(legacyFactionData)
end

if G_RLF:IsClassic() or G_RLF:IsCataClassic() then
	if not ClearItemButtonOverlay then
		function ClearItemButtonOverlay(button)
			-- Dummy function to avoid errors
		end
	end
end

return G_RLF.ClassicToRetail
