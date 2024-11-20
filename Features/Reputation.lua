local addonName, G_RLF = ...

local Rep = G_RLF.RLF:NewModule("Reputation", "AceEvent-3.0", "AceTimer-3.0")

Rep.Element = {}

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
		local preStart, preEnd = string.find(pattern, "%%s")
		local prePattern = string.sub(pattern, 1, preStart - 1)
		local midStart, midEnd = string.find(pattern, "%%d", preEnd + 1)
		local midPattern = string.sub(pattern, preEnd + 1, midStart - 1)
		local postPattern = string.sub(pattern, midEnd + 1)
		table.insert(computedPatterns, { prePattern, midPattern, postPattern })
	end
	return computedPatterns
end

local locale
local function countMappedFactions()
	local count = 0
	for k, v in pairs(G_RLF.db.global.factionMaps[locale]) do
		if v then
			count = count + 1
		end
	end

	return count
end

local function buildFactionLocaleMap(findName)
	local mappedFactions = countMappedFactions()
	local hasMoreFactions = C_Reputation.GetFactionDataByIndex(mappedFactions + 1) ~= nil
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
					local factionData = C_Reputation.GetFactionDataByIndex(i)
					if factionData and factionData.name then
						if not G_RLF.db.global.factionMaps[locale][factionData.name] then
							G_RLF.db.global.factionMaps[locale][factionData.name] = factionData.factionID
						end
					end
				end
			end)
		end

		return
	end

	for i = 1, numFactions do
		local factionData = C_Reputation.GetFactionDataByIndex(i)
		if factionData then
			if not G_RLF.db.global.factionMaps[locale][factionData.name] then
				G_RLF.db.global.factionMaps[locale][factionData.name] = factionData.factionID
			end
			if findName and factionData.name == findName then
				break
			end
		end
	end
end

function Rep.Element:new(...)
	local element = {}
	G_RLF.InitializeLootDisplayProperties(element)

	element.type = "Reputation"
	element.IsEnabled = function()
		return Rep:IsEnabled()
	end

	local factionName, factionData, rL, gL, bL
	element.quantity, factionName, rL, gL, bL, element.factionId, factionData, element.repType = ...
	element.r, element.g, element.b = rL or 0.5, gL or 0.5, bL or 1
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

		local color = G_RLF:RGBAToHexFormat(element.r, element.g, element.b, 0.7)

		if element.repType == RepType.DelveCompanion and factionData then
			str = math.floor((factionData.currentXp / factionData.nextLevelAt) * 10000) / 100 .. "%"
			return "    " .. color .. str .. "|r"
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
				local bagSize = G_RLF.db.global.fontSize
				str = str .. "|A:ParagonReputation_Bag:" .. bagSize .. ":" .. bagSize .. ":0:0|a    "
			end
			if factionData.currentValue ~= nil and factionData.currentValue > 0 then
				str = str .. factionData.currentValue
			end
			if factionData.threshold ~= nil and factionData.threshold > 0 then
				str = str .. "/" .. factionData.threshold
			end
		elseif element.typeType == RepType.Friendship then
			if factionData.repNumerator ~= nil and factionData.repNumerator > 0 then
				str = str .. factionData.repNumerator
				if factionData.repDenominator ~= nil and factionData.repDenominator > 0 then
					str = str .. "/" .. factionData.repDenominator
				end
			end
		else
			if factionData.currentStanding >= 0 and factionData.currentReactionThreshold > 0 then
				str = str .. factionData.currentStanding .. "/" .. factionData.currentReactionThreshold
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
	-- TODO: Move this to db defaults
	G_RLF.db.global.factionMaps = G_RLF.db.global.factionMaps or {}
	G_RLF.db.global.factionMaps[locale] = G_RLF.db.global.factionMaps[locale] or {}

	self.companionFactionId = C_DelvesUI.GetFactionForCompanion(BRANN_COMPANION_INFO_ID)
	local factionData = C_Reputation.GetFactionDataByID(self.companionFactionId)
	if factionData then
		self.companionFactionName = factionData.name
	end

	increasePatterns = precomputePatternSegments({
		FACTION_STANDING_INCREASED,
		FACTION_STANDING_INCREASED_ACCOUNT_WIDE,
		FACTION_STANDING_INCREASED_ACH_BONUS,
		FACTION_STANDING_INCREASED_ACH_BONUS_ACCOUNT_WIDE,
		FACTION_STANDING_INCREASED_BONUS,
		FACTION_STANDING_INCREASED_DOUBLE_BONUS,
	})

	decreasePatterns = precomputePatternSegments({
		FACTION_STANDING_DECREASED,
		FACTION_STANDING_DECREASED_ACCOUNT_WIDE,
	})

	RunNextFrame(function()
		buildFactionLocaleMap()
	end)

	if G_RLF.db.global.repFeed then
		self:Enable()
	else
		self:Disable()
	end
end

-- Function to extract faction and reputation change using precomputed patterns
local function extractFactionAndRep(message, patterns)
	for _, segments in ipairs(patterns) do
		local prePattern, midPattern, postPattern = unpack(segments)
		local preMatchStart, preMatchEnd = string.find(message, prePattern, 1, true)
		if preMatchStart then
			local msgLoop = message:sub(preMatchEnd + 1)
			local midMatchStart, midMatchEnd = string.find(msgLoop, midPattern, 1, true)
			if midMatchStart then
				local postMatchStart, postMatchEnd = string.find(msgLoop, postPattern, midMatchEnd, true)
				if postMatchStart then
					local faction = msgLoop:sub(1, midMatchStart - 1)
					local rep
					if midMatchEnd == postMatchStart then
						rep = msgLoop:sub(midMatchEnd + 1)
					else
						rep = msgLoop:sub(midMatchEnd + 1, postMatchStart - 1)
					end
					return faction, tonumber(rep)
				end
			end
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
			local rep = message:sub(repStart, repEnd)
			return companionFactionName, tonumber(rep)
		end
	end

	return nil, nil
end

function Rep:OnDisable()
	self:UnregisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
end

function Rep:OnEnable()
	self:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
	print(self.companionFactionName)
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
		faction, repChange = extractFactionAndRepForDelves(message, self.companionFactionName)
		if faction then
			isDelveCompanion = true
		end
	end
	return faction, repChange, isDelveCompanion
end

function Rep:CHAT_MSG_COMBAT_FACTION_CHANGE(eventName, message)
	self:getLogger():Info(eventName .. " " .. message, "WOWEVENT", self.moduleName)
	return self:fn(function()
		local faction, repChange, isDelveCompanion = self:ParseFactionChangeMessage(message)

		if not faction or not repChange then
			self:getLogger():Error(
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
		if G_RLF.db.global.factionMaps[locale][faction] == nil then
			-- attempt to find the missing faction's ID
			self:getLogger():Debug(faction .. " not cached for " .. locale, addonName, self.moduleName)
			buildFactionLocaleMap(faction)
		end

		local repType, fId, factionData
		if G_RLF.db.global.factionMaps[locale][faction] then
			fId = G_RLF.db.global.factionMaps[locale][faction]
			if C_Reputation.IsMajorFaction(fId) then
				color = ACCOUNT_WIDE_FONT_COLOR
				repType = RepType.MajorFaction
				factionData = C_MajorFactions.GetMajorFactionRenownInfo(fId)
			elseif isDelveCompanion then
				factionData = C_Reputation.GetFactionDataByID(fId)
				local ranks = C_GossipInfo.GetFriendshipReputationRanks(fId)
				local info = C_GossipInfo.GetFriendshipReputation(fId)
				if factionData.reaction then
					color = FACTION_BAR_COLORS[factionData.reaction]
				end
				factionData.currentLevel = ranks and ranks.currentLevel or 0
				factionData.maxLevel = ranks and ranks.maxLevel or 0
				factionData.currentXp = info.standing - info.reactionThreshold
				factionData.nextLevelAt = info.nextThreshold - info.reactionThreshold
				repType = RepType.DelveCompanion
			else
				local friendInfo = C_GossipInfo.GetFriendshipReputation(fId)
				factionData = C_Reputation.GetFactionDataByID(fId)
				if factionData.reaction then
					color = FACTION_BAR_COLORS[factionData.reaction]
				end
				if friendInfo and friendInfo.friendshipFactionID and friendInfo.friendshipFactionID > 0 then
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

			if C_Reputation.IsFactionParagon(fId) then
				color = color or FACTION_GREEN_COLOR
				repType = RepType.Paragon
				factionData = factionData or {}
				factionData.currentValue, factionData.threshold, factionData.rewardQuestId, factionData.hasRewardPending, factionData.tooLowLevelForParagon =
					C_Reputation.GetFactionParagonInfo(fId)
			end
		else
			self:getLogger():Warn(faction .. " is STILL not cached for " .. locale, addonName, self.moduleName)
		end

		if color then
			r, g, b = color.r, color.g, color.b
		end

		local e = self.Element:new(repChange, faction, r, g, b, fId, factionData, repType)
		e:Show()
	end)
end

return Rep
