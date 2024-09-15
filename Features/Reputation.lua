local addonName, ns = ...

local Rep = G_RLF.RLF:NewModule("Reputation", "AceEvent-3.0", "AceTimer-3.0")

Rep.Element = {}

function Rep.Element:new(...)
	ns.InitializeLootDisplayProperties(self)

	self.type = "Reputation"
	self.IsEnabled = function()
		return Rep:IsEnabled()
	end

	local factionName, rL, gL, bL
	self.quantity, factionName, rL, gL, bL = ...
	self.r, self.g, self.b = rL or 0.5, gL or 0.5, bL or 1
	self.a = 1
	self.key = "REP_" .. factionName
	self.textFn = function(existingRep)
		local sign = "+"
		local rep = (existingRep or 0) + self.quantity
		if rep < 0 then
			sign = "-"
		end
		return sign .. math.abs(rep) .. " " .. factionName
	end

	return self
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
				G_RLF.addonName,
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
			self:getLogger():Debug(faction .. " not cached for " .. locale, G_RLF.addonName, self.moduleName)
			buildFactionLocaleMap(faction)
		end

		if G_RLF.db.global.factionMaps[locale][faction] then
			local fId = G_RLF.db.global.factionMaps[locale][faction]
			if C_Reputation.IsMajorFaction(fId) then
				color = ACCOUNT_WIDE_FONT_COLOR
			elseif C_Reputation.IsFactionParagon(fId) then
				color = FACTION_GREEN_COLOR
			else
				local factionData = C_Reputation.GetFactionDataByID(fId)
				if factionData.reaction then
					color = FACTION_BAR_COLORS[factionData.reaction]
				end
			end
		else
			self:getLogger():Warn(faction .. " is STILL not cached for " .. locale, G_RLF.addonName, self.moduleName)
		end

		if color then
			r, g, b = color.r, color.g, color.b
		end

		local e = self.Element:new(repChange, faction, r, g, b)
		e:Show()
	end)
end

return Rep
