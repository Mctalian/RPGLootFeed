---@diagnostic disable: inject-field
---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

---@class RLF_Reputation: RLF_Module, AceEvent, AceTimer
local Rep = G_RLF.RLF:NewModule("Reputation", "AceEvent-3.0", "AceTimer-3.0")

Rep.Element = {}

---@enum RepType
local RepType = {
	MajorFaction = 1,
	Paragon = 2,
	BaseFaction = 3,
	DelveCompanion = 4,
	Friendship = 5,
}

-- Precompute pattern segments to optimize runtime message parsing
local function precomputePatternSegments(patterns)
	local computedPatterns = {}
	for _, pattern in ipairs(patterns) do
		local segments = G_RLF:CreatePatternSegmentsForStringNumber(pattern)
		table.insert(computedPatterns, segments)
	end
	return computedPatterns
end

local locale
local function countMappedFactions()
	local count = 0
	for k, v in pairs(G_RLF.db.locale.factionMap) do
		if v then
			count = count + 1
		end
	end

	return count
end

local function buildFactionLocaleMap(findName)
	-- Classic:GetFactionInfo(factionIndex)
	local mappedFactions = countMappedFactions()
	local hasMoreFactions = false
	if G_RLF:IsRetail() then
		hasMoreFactions = C_Reputation.GetFactionDataByIndex(mappedFactions + 1) ~= nil
	elseif G_RLF:IsClassic() or G_RLF:IsCataClassic() then
		hasMoreFactions = GetFactionInfo(mappedFactions + 1) ~= nil
	end
	if not hasMoreFactions and not findName then
		return
	end
	local numFactions = mappedFactions + 5

	if not findName then
		local buckets = math.ceil(numFactions / 10) + 1
		local bucketSize = math.ceil(numFactions / buckets) + 1

		for bucket = 1, buckets do
			RunNextFrame(function()
				for i = 1 + (bucket - 1) * bucketSize, bucket * bucketSize do
					local factionData
					if G_RLF:IsRetail() then
						factionData = C_Reputation.GetFactionDataByIndex(i)
					elseif G_RLF:IsClassic() or G_RLF:IsCataClassic() then
						factionData = G_RLF.ClassicToRetail:ConvertFactionInfoByIndex(i)
					end
					if factionData and factionData.name then
						if not G_RLF.db.locale.factionMap[factionData.name] then
							G_RLF.db.locale.factionMap[factionData.name] = factionData.factionID
						end
					end
				end
			end)
		end

		return
	end

	for i = 1, numFactions do
		local factionData
		if G_RLF:IsRetail() then
			factionData = C_Reputation.GetFactionDataByIndex(i)
		elseif G_RLF:IsClassic() or G_RLF:IsCataClassic() then
			factionData = G_RLF.ClassicToRetail:ConvertFactionInfoByIndex(i)
		end

		if factionData then
			if not G_RLF.db.locale.factionMap[factionData.name] then
				G_RLF.db.locale.factionMap[factionData.name] = factionData.factionID
			end
			if findName and factionData.name == findName then
				break
			end
		end
	end
end

function Rep.Element:new(...)
	---@class Rep.Element: RLF_LootElement
	---@field public repType RepType
	local element = {}
	G_RLF.InitializeLootDisplayProperties(element)

	element.type = "Reputation"
	element.IsEnabled = function()
		return Rep:IsEnabled()
	end

	local factionName, factionData, rL, gL, bL
	element.quantity, factionName, rL, gL, bL, element.factionId, factionData, element.repType = ...
	local rDef, gDef, bDef = unpack(G_RLF.db.global.rep.defaultRepColor)
	element.r, element.g, element.b = rL or rDef, gL or gDef, bL or bDef
	element.a = 1
	element.key = "REP_" .. factionName
	element.textFn = function(existingRep)
		local sign = "+"
		local rep = (existingRep or 0) + element.quantity
		if rep < 0 then
			sign = "-"
		end
		return sign .. math.abs(rep) .. " " .. factionName
	end

	if factionData ~= nil and factionData.textureKit then
		local majorFactionIconFormat = "majorFactions_icons_%s512"
		local atlas = majorFactionIconFormat:format(factionData.textureKit)
		local atlasInfo = C_Texture.GetAtlasInfo(atlas)
		if atlasInfo and atlasInfo.file then
			element.icon = atlasInfo.file
			---@class RLF_TexCoords
			element.texCoords = {
				left = atlasInfo.leftTexCoord,
				right = atlasInfo.rightTexCoord,
				top = atlasInfo.topTexCoord,
				bottom = atlasInfo.bottomTexCoord,
			}
		else
			element.icon = G_RLF.DefaultIcons.REPUTATION
		end
		element.quality = Enum.ItemQuality.Heirloom
	else
		element.atlas = false
		element.icon = G_RLF.DefaultIcons.REPUTATION
		element.quality = Enum.ItemQuality.Rare
	end

	element.repLevel = nil
	if factionData then
		if factionData.renownLevel then
			element.repLevel = factionData.renownLevel
		elseif element.repType == RepType.DelveCompanion then
			element.repLevel = factionData.currentLevel
		end
	end

	element.secondaryTextFn = function()
		local str = ""

		if not element.factionId or not factionData then
			return str
		end

		local color = G_RLF:RGBAToHexFormat(element.r, element.g, element.b, G_RLF.db.global.rep.secondaryTextAlpha)

		if element.repType == RepType.DelveCompanion and factionData then
			if factionData.nextLevelAt > 0 then
				str = math.floor((factionData.currentXp / factionData.nextLevelAt) * 10000) / 100 .. "%"
				return "    " .. color .. str .. "|r"
			end
			return ""
		end

		if element.repType == RepType.MajorFaction then
			if
				factionData.renownReputationEarned ~= nil
				and factionData.renownLevelThreshold ~= nil
				and factionData.renownReputationEarned > 0
				and factionData.renownLevelThreshold > 0
			then
				str = str .. factionData.renownReputationEarned .. "/" .. factionData.renownLevelThreshold
			end
		elseif element.repType == RepType.Paragon then
			if factionData.hasRewardPending then
				local stylingDb = G_RLF.DbAccessor:Styling(G_RLF.Frames.MAIN)
				local bagSize = stylingDb.fontSize
				str = str .. CreateAtlasMarkup("ParagonReputation_Bag", bagSize, bagSize, 0, 0) .. "    "
			end
			if
				factionData.currentValue ~= nil
				and factionData.currentValue > 0
				and factionData.threshold ~= nil
				and factionData.threshold > 0
			then
				str = str .. (factionData.currentValue % factionData.threshold)
				str = str .. "/" .. factionData.threshold
			end
		elseif element.repType == RepType.Friendship then
			if factionData.repNumerator ~= nil and factionData.repNumerator > 0 then
				str = str .. factionData.repNumerator
				if factionData.repDenominator ~= nil and factionData.repDenominator > 0 then
					str = str .. "/" .. factionData.repDenominator
				end
			end
		else
			if
				factionData.currentStanding ~= 0
				or factionData.currentReactionThreshold ~= 0
				or factionData.nextReactionThreshold ~= 0
			then
				str = str
					.. (factionData.currentStanding - factionData.currentReactionThreshold)
					.. "/"
					.. (factionData.nextReactionThreshold - factionData.currentReactionThreshold)
			end
		end

		if str ~= "" then
			str = "    " .. color .. str .. "|r"
		end

		return str
	end

	return element
end

local increasePatterns, decreasePatterns
function Rep:OnInitialize()
	locale = GetLocale()

	local increase_consts = {
		FACTION_STANDING_INCREASED,
		FACTION_STANDING_INCREASED_ACH_BONUS,
		FACTION_STANDING_INCREASED_BONUS,
		FACTION_STANDING_INCREASED_DOUBLE_BONUS,
	}

	local decrease_consts = {
		FACTION_STANDING_DECREASED,
	}

	if G_RLF:IsRetail() then
		table.insert(increase_consts, FACTION_STANDING_INCREASED_ACCOUNT_WIDE)
		table.insert(increase_consts, FACTION_STANDING_INCREASED_ACH_BONUS_ACCOUNT_WIDE)
		table.insert(decrease_consts, FACTION_STANDING_DECREASED_ACCOUNT_WIDE)
	end

	increasePatterns = precomputePatternSegments(increase_consts)
	decreasePatterns = precomputePatternSegments(decrease_consts)

	RunNextFrame(function()
		buildFactionLocaleMap()
	end)

	if G_RLF.db.global.rep.enabled then
		self:Enable()
	else
		self:Disable()
	end
end

-- Function to extract faction and reputation change using precomputed patterns
local function extractFactionAndRep(message, patterns)
	for _, segments in ipairs(patterns) do
		local faction, rep = G_RLF:ExtractDynamicsFromPattern(message, segments)
		if faction and rep then
			return faction, rep
		end
	end
	return nil, nil
end

local function extractFactionAndRepForDelves(message, companionFactionName)
	if not companionFactionName then
		return nil, nil
	end

	local factionStart, factionEnd = string.find(message, companionFactionName, 1, true)
	if factionStart then
		local repStart, repEnd = string.find(message, "%d+", factionEnd + 1)
		if repStart then
			local rep = string.sub(message, repStart, repEnd)
			return companionFactionName, tonumber(rep)
		end
	end

	return nil, nil
end

function Rep:OnDisable()
	self:UnregisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function Rep:OnEnable()
	self:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	G_RLF:LogDebug("OnEnable", addonName, self.moduleName)
end

function Rep:ParseFactionChangeMessage(message)
	local isDelveCompanion = false
	local faction, repChange = extractFactionAndRep(message, increasePatterns)
	if not faction then
		faction, repChange = extractFactionAndRep(message, decreasePatterns)
		if repChange then
			repChange = -repChange
		end
	end
	if not faction then
		G_RLF:LogDebug(
			"Checking for " .. self.companionFactionName .. " in message " .. message,
			addonName,
			self.moduleName
		)
		faction, repChange = extractFactionAndRepForDelves(message, self.companionFactionName)
		if faction then
			isDelveCompanion = true
		end
	end
	return faction, repChange, isDelveCompanion
end

function Rep:PLAYER_ENTERING_WORLD(eventName, isLogin, isReload)
	if GetExpansionLevel() >= G_RLF.Expansion.TWW then
		if not self.companionFactionId or not self.companionFactionName then
			self.companionFactionId = C_DelvesUI.GetFactionForCompanion(BRANN_COMPANION_INFO_ID)
			local factionData = C_Reputation.GetFactionDataByID(self.companionFactionId)
			if factionData then
				self.companionFactionName = factionData.name
			end
		end
	end
end

function Rep:CHAT_MSG_COMBAT_FACTION_CHANGE(eventName, message)
	G_RLF:LogInfo(eventName .. " " .. message, "WOWEVENT", self.moduleName)
	return self:fn(function()
		local faction, repChange, isDelveCompanion = self:ParseFactionChangeMessage(message)

		if not faction or not repChange then
			G_RLF:LogError(
				"Could not determine faction and/or rep change from message",
				addonName,
				self.moduleName,
				faction,
				nil,
				repChange
			)
			return
		end

		local r, g, b, color
		local factionMapEntry = G_RLF.db.locale.factionMap[faction]
		if factionMapEntry == nil then
			-- attempt to find the missing faction's ID
			G_RLF:LogDebug(faction .. " not cached for " .. locale, addonName, self.moduleName)
			buildFactionLocaleMap(faction)
		end

		local repType, fId, factionData
		if factionMapEntry then
			fId = factionMapEntry
			if G_RLF:IsRetail() and C_Reputation.IsMajorFaction(fId) then
				color = ACCOUNT_WIDE_FONT_COLOR
				repType = RepType.MajorFaction
				local renownInfo = C_MajorFactions.GetMajorFactionRenownInfo(fId)
				factionData = C_MajorFactions.GetMajorFactionData(fId)
				factionData.renownLevel = renownInfo and renownInfo.renownLevel or 0
				factionData.renownReputationEarned = renownInfo and renownInfo.renownReputationEarned or 0
				factionData.renownLevelThreshold = renownInfo and renownInfo.renownLevelThreshold or 0
			elseif G_RLF:IsRetail() and isDelveCompanion then
				factionData = C_Reputation.GetFactionDataByID(fId)
				if not factionData then
					G_RLF:LogWarn(
						faction .. " (supposed companion) faction data could not be retrieved by ID",
						addonName,
						self.moduleName
					)
					return
				end
				local ranks = C_GossipInfo.GetFriendshipReputationRanks(fId)
				local info = C_GossipInfo.GetFriendshipReputation(fId)
				if factionData.reaction then
					color = FACTION_BAR_COLORS[factionData.reaction]
				end
				factionData.currentLevel = ranks and ranks.currentLevel or 0
				factionData.maxLevel = ranks and ranks.maxLevel or 0
				factionData.currentXp = info.standing - info.reactionThreshold
				if info.nextThreshold and info.nextThreshold > 1 then
					factionData.nextLevelAt = info.nextThreshold - info.reactionThreshold
				else
					factionData.nextLevelAt = 0
				end
				repType = RepType.DelveCompanion
			else
				local friendInfo = C_GossipInfo.GetFriendshipReputation(fId)
				if G_RLF:IsRetail() then
					factionData = C_Reputation.GetFactionDataByID(fId)
				elseif G_RLF:IsClassic() or G_RLF:IsCataClassic() then
					factionData = G_RLF.ClassicToRetail:ConvertFactionInfoByID(fId)
				end
				if not factionData then
					G_RLF:LogWarn(faction .. " faction data could not be retrieved by ID", addonName, self.moduleName)
					return
				end
				if factionData.reaction then
					color = FACTION_BAR_COLORS[factionData.reaction]
				end
				if
					friendInfo
					and friendInfo.friendshipFactionID
					and friendInfo.friendshipFactionID > 0
					and friendInfo.nextThreshold
					and friendInfo.nextThreshold > 1
				then
					local ranks = C_GossipInfo.GetFriendshipReputationRanks(fId)
					factionData.currentLevel = ranks and ranks.currentLevel or 0
					factionData.maxLevel = ranks and ranks.maxLevel or 0
					factionData.repNumerator = friendInfo.standing - friendInfo.reactionThreshold
					factionData.repDenominator = friendInfo.nextThreshold - friendInfo.reactionThreshold
					repType = RepType.Friendship
				else
					repType = RepType.BaseFaction
				end
			end

			if GetExpansionLevel() >= G_RLF.Expansion.LEGION and C_Reputation.IsFactionParagon(fId) then
				color = color or FACTION_GREEN_COLOR
				repType = RepType.Paragon
				factionData = factionData or {}
				factionData.currentValue, factionData.threshold, factionData.rewardQuestId, factionData.hasRewardPending, factionData.tooLowLevelForParagon =
					C_Reputation.GetFactionParagonInfo(fId)
			end
		else
			G_RLF:LogWarn(faction .. " is STILL not cached for " .. locale, addonName, self.moduleName)
		end

		if color then
			r, g, b = color.r, color.g, color.b
		end

		local e = self.Element:new(repChange, faction, r, g, b, fId, factionData, repType)
		e:Show()
	end)
end

return Rep
