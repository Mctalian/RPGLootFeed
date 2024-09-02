local Rep = G_RLF.RLF:NewModule("Reputation", "AceEvent-3.0", "AceTimer-3.0")

local repData = {}
local paragonRepData = {}
local majorRepData = {}
local cachedFactionCount
local showLegacyReps
local firstNilIndex = 1

function Rep:OnInitialize()
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
					local rep = msgLoop:sub(midMatchEnd + 1, postMatchStart - 1)
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

function Rep:CHAT_MSG_COMBAT_FACTION_CHANGE(_, message)
	local faction, repChange = extractFactionAndRep(message, increasePatterns)
	if faction and repChange then
		G_RLF.LootDisplay:ShowRep(repChange, faction)
	else
		faction, repChange = extractFactionAndRep(message, decreasePatterns)
		if faction and repChange then
			G_RLF.LootDisplay:ShowRep(-repChange, faction)
		end
	end
end

return Rep
