local addonName, G_RLF = ...

local Rep = G_RLF.RLF:NewModule("Reputation", "AceEvent-3.0", "AceTimer-3.0")

Rep.Element = {}

local RepType = {
	MajorFaction = 1,
	Paragon = 2,
	BaseFaction = 3,
}

function Rep.Element:new(...)
	local element = {}
	G_RLF.InitializeLootDisplayProperties(element)

	element.type = "Reputation"
	element.IsEnabled = function()
		return Rep:IsEnabled()
	end

	local factionName, rL, gL, bL
	element.quantity, factionName, rL, gL, bL, element.factionId, element.repType = ...
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
		local color = G_RLF:RGBAToHexFormat(element.r, element.g, element.b, 0.7)

		local function normalRep()
			local factionData = C_Reputation.GetFactionDataByID(element.factionId)
			if factionData.currentStanding >= 0 and factionData.currentReactionThreshold > 0 then
				str = str .. factionData.currentStanding .. "/" .. factionData.currentReactionThreshold
			end
		end

		if element.repType == RepType.MajorFaction then
			local factionData = C_MajorFaction.GetMajorFactionRenownInfo(element.factionId)
			if factionData.currentLevel > 0 then
				str = str .. factionData.currentLevel
			end
			if factionData.renownReputationEarned > 0 and factionData.renownLevelThreshold > 0 then
				str = str
					.. "    ("
					.. factionData.renownReputationEarned
					.. "/"
					.. factionData.renownLevelThreshold
					.. ")"
			end
		elseif element.repType == RepType.Paragon then
			local factionData = C_Reputation.GetFactionParagonInfo(element.factionId)
			if factionData.tooLowLevelForParagon then
				normalRep()
			else
				if factionData.hasRewardPending then
					local secondaryFontSize = G_RLF.db.global.secondaryFontSize
					str = str
						.. "|A:ParagonReputation_Bag:"
						.. secondaryFontSize
						.. ":"
						.. secondaryFontSize
						.. ":0:0|a    "
				end
				if factionData.currentValue > 0 then
					str = str .. factionData.currentValue
				end
				if factionData.threshold > 0 then
					str = str .. "/" .. factionData.threshold
				end
			end
		else
			normalRep()
		end

		if str ~= "" then
			str = "|c" .. color .. str .. "|r"
		end

		return str
	end

	return element
end

local locale
function Rep:OnInitialize()
	locale = GetLocale()
	-- TODO: Move this to db defaults
	G_RLF.db.global.factionMaps = G_RLF.db.global.factionMaps or {}
	G_RLF.db.global.factionMaps[locale] = G_RLF.db.global.factionMaps[locale] or {}
	if G_RLF.db.global.repFeed then
		self:Enable()
	else
		self:Disable()
	end
end

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
	if countMappedFactions() == numFactions and not findName then
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

local increasePatterns = precomputePatternSegments({
	FACTION_STANDING_INCREASED,
	FACTION_STANDING_INCREASED_ACCOUNT_WIDE,
	FACTION_STANDING_INCREASED_ACH_BONUS,
	FACTION_STANDING_INCREASED_ACH_BONUS_ACCOUNT_WIDE,
	FACTION_STANDING_INCREASED_BONUS,
	FACTION_STANDING_INCREASED_DOUBLE_BONUS,
})

local decreasePatterns = precomputePatternSegments({
	FACTION_STANDING_DECREASED,
	FACTION_STANDING_DECREASED_ACCOUNT_WIDE,
})

function Rep:OnDisable()
	self:UnregisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
end

function Rep:OnEnable()
	self:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
end

function Rep:CHAT_MSG_COMBAT_FACTION_CHANGE(eventName, message)
	self:getLogger():Info(eventName .. " " .. message, "WOWEVENT", self.moduleName)
	return self:fn(function()
		local faction, repChange = extractFactionAndRep(message, increasePatterns)
		if not faction then
			faction, repChange = extractFactionAndRep(message, decreasePatterns)
			if repChange then
				repChange = -repChange
			end
		end
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

		local e = self.Element:new(repChange, faction, r, g, b, fId, type)
		e:Show()
	end)
end

return Rep
