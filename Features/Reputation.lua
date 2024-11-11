local addonName, G_RLF = ...

local Rep = G_RLF.RLF:NewModule("Reputation", "AceEvent-3.0", "AceTimer-3.0")

Rep.Element = {}

local RepType = {
	MajorFaction = 1,
	Paragon = 2,
	BaseFaction = 3,
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
	local numFactions = C_Reputation.GetNumFactions()
	local mappedFactions = countMappedFactions()
	if mappedFactions >= numFactions and not findName then
		return
	end

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

	-- If we are searching for a specific faction, we need to expand all headers to ensure we find it
	C_Reputation.ExpandAllFactionHeaders()

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

	local factionName, rL, gL, bL
	element.quantity, factionName, rL, gL, bL, element.factionId, element.repType, element.isDelveCompanion = ...
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

	element.secondaryTextFn = function()
		local str = ""

		if not element.factionId or element.isDelveCompanion then
			return str
		end

		local color = G_RLF:RGBAToHexFormat(element.r, element.g, element.b, 0.7)

		local function normalRep()
			local factionData = C_Reputation.GetFactionDataByID(element.factionId)
			if factionData.currentStanding >= 0 and factionData.currentReactionThreshold > 0 then
				str = str .. factionData.currentStanding .. "/" .. factionData.currentReactionThreshold
			end
		end

		if element.repType == RepType.MajorFaction then
			local factionData = C_MajorFactions.GetMajorFactionRenownInfo(element.factionId)
			if factionData.renownLevel ~= nil and factionData.renownLevel > 0 then
				str = str .. factionData.renownLevel
			end
			if
				factionData.renownReputationEarned ~= nil
				and factionData.renownLevelThreshold ~= nil
				and factionData.renownReputationEarned > 0
				and factionData.renownLevelThreshold > 0
			then
				str = str
					.. "    ("
					.. factionData.renownReputationEarned
					.. "/"
					.. factionData.renownLevelThreshold
					.. ")"
			end
		elseif element.repType == RepType.Paragon then
			local currentValue, threshold, _, hasRewardPending, tooLowLevelForParagon =
				C_Reputation.GetFactionParagonInfo(element.factionId)

			if hasRewardPending then
				local bagSize = G_RLF.db.global.fontSize
				str = str .. "|A:ParagonReputation_Bag:" .. bagSize .. ":" .. bagSize .. ":0:0|a    "
			end
			if currentValue ~= nil and currentValue > 0 then
				str = str .. currentValue
			end
			if threshold ~= nil and threshold > 0 then
				str = str .. "/" .. threshold
			end
		else
			normalRep()
		end

		if str ~= "" then
			str = "    " .. color .. str .. "|r"
		end

		return str
	end

	return element
end

local season, companionFactionId, companionFactionName
local increasePatterns, decreasePatterns
function Rep:OnInitialize()
	locale = GetLocale()
	-- TODO: Move this to db defaults
	G_RLF.db.global.factionMaps = G_RLF.db.global.factionMaps or {}
	G_RLF.db.global.factionMaps[locale] = G_RLF.db.global.factionMaps[locale] or {}

	season = C_DelvesUI.GetCurrentDelvesSeasonNumber()
	companionFactionId = C_DelvesUI.GetFactionForCompanion(season)
	local factionData = C_Reputation.GetFactionDataByID(companionFactionId)
	if factionData then
		companionFactionName = factionData.name
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

local function extractFactionAndRepForDelves(message)
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
		faction, repChange = extractFactionAndRepForDelves(message)
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

		local type, fId
		if G_RLF.db.global.factionMaps[locale][faction] then
			fId = G_RLF.db.global.factionMaps[locale][faction]
			if C_Reputation.IsMajorFaction(fId) then
				color = ACCOUNT_WIDE_FONT_COLOR
				type = RepType.MajorFaction
			elseif C_Reputation.IsFactionParagon(fId) then
				color = FACTION_GREEN_COLOR
				type = RepType.Paragon
			else
				local factionData = C_Reputation.GetFactionDataByID(fId)
				if factionData.reaction then
					color = FACTION_BAR_COLORS[factionData.reaction]
				end
				type = RepType.BaseFaction
			end
		else
			self:getLogger():Warn(faction .. " is STILL not cached for " .. locale, addonName, self.moduleName)
		end

		if color then
			r, g, b = color.r, color.g, color.b
		end

		local e = self.Element:new(repChange, faction, r, g, b, fId, type, isDelveCompanion)
		e:Show()
	end)
end

return Rep
