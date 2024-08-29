local Rep = G_RLF.RLF:NewModule("Reputation", "AceEvent-3.0")

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

function Rep:OnDisable()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:UnregisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
	self:UnregisterEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED")
end

function Rep:OnEnable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
	self:RegisterEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED")
	if showLegacyReps == nil then
		self:SnapShot()
	end
end

local function initializeParagonFaction(fId)
	if not paragonRepData[fId] then
		paragonRepData[fId] = 0
	end
end

local function initializeMajorFaction(fId, mfd)
	if not majorRepData[fId] then
		local level = mfd.renownLevel
		local max = mfd.renownLevelThreshold
		majorRepData[fId] = { level, 0, max }
	end
end

local function initializeNormalFaction(fId)
	if not repData[fId] then
		repData[fId] = 0
	end
end

local function initializeRepFaction(fId)
	if C_Reputation.IsFactionParagon(fId) then
		initializeParagonFaction(fId)
	elseif C_Reputation.IsMajorFaction(fId) then
		local mfd = C_MajorFactions.GetMajorFactionData(fId)
		initializeMajorFaction(fId, mfd)
	else
		initializeNormalFaction(fId)
	end
end

local function handleMajorFactionRepChange(id, level)
	local factionData = C_Reputation.GetFactionDataByID(id)
	local majorFactionData = C_MajorFactions.GetMajorFactionData(id)
	local level = level or C_MajorFactions.GetCurrentRenownLevel(id)
	local rep = majorFactionData.renownReputationEarned
	local max = majorFactionData.renownLevelThreshold
	local oldLevel, oldRep, oldMax = unpack(majorRepData[id])

	if rep > oldRep then
		G_RLF.LootDisplay:ShowRep(rep - oldRep, factionData)
	elseif rep < oldRep then
		G_RLF.LootDisplay:ShowRep(oldMax - oldRep + rep, factionData)
	elseif rep == oldRep and level > oldLevel then
		G_RLF.LootDisplay:ShowRep(oldMax - oldRep + rep, factionData)
	end
	majorRepData[id] = { level, rep, max }
end

local function factionListHasNotChanged()
	return C_Reputation.GetFactionDataByIndex(firstNilIndex) == nil -- if a new index hasn't been added
		and firstNilIndex > 1 -- we had at least 1 faction before
		and C_Reputation.GetFactionDataByIndex(firstNilIndex - 1) -- the previous faction is still not nil
		and showLegacyReps == C_Reputation.AreLegacyReputationsShown() -- Showing Legacy Reputations hasn't changed
end

local function addAnyNewFactions()
	if factionListHasNotChanged() then
		-- No new factions, skipping
		return
	end

	showLegacyReps = C_Reputation.AreLegacyReputationsShown()

	local i = 1
	local factionData = C_Reputation.GetFactionDataByIndex(i)
	while factionData ~= nil do
		if not factionData.isHeader or factionData.isHeaderWithRep then
			local fId = factionData.factionID
			initializeRepFaction(fId)
		end
		i = i + 1
		factionData = C_Reputation.GetFactionDataByIndex(i)
	end

	firstNilIndex = i
end

function Rep:PLAYER_ENTERING_WORLD()
	self:SnapShot()
end

function Rep:SnapShot()
	showLegacyReps = C_Reputation.AreLegacyReputationsShown()
	local count = 0
	local i = 1
	local factionData = C_Reputation.GetFactionDataByIndex(i)
	while factionData ~= nil do
		if not factionData.isHeader or factionData.isHeaderWithRep then
			if C_Reputation.IsFactionParagon(factionData.factionID) then
				-- Need to support Paragon factions
				local value, max = C_Reputation.GetFactionParagonInfo(factionData.factionID)
				paragonRepData[factionData.factionID] = value
			elseif C_Reputation.IsMajorFaction(factionData.factionID) then
				-- Need to support Major factions
				local majorFactionData = C_MajorFactions.GetMajorFactionData(factionData.factionID)
				local level = majorFactionData.renownLevel
				local rep = majorFactionData.renownReputationEarned
				local max = majorFactionData.renownLevelThreshold
				majorRepData[factionData.factionID] = { level, rep, max }
			else
				repData[factionData.factionID] = factionData.currentStanding
			end
			count = count + 1
		end
		i = i + 1
		factionData = C_Reputation.GetFactionDataByIndex(i)
	end

	firstNilIndex = i
	cachedFactionCount = count
end

function Rep:FindDelta()
	addAnyNewFactions()

	if G_RLF.db.global.repFeed then
		-- Normal rep factions
		for k, v in pairs(repData) do
			local factionData = C_Reputation.GetFactionDataByID(k)
			if factionData.currentStanding ~= v then
				G_RLF.LootDisplay:ShowRep(factionData.currentStanding - v, factionData)
				repData[k] = factionData.currentStanding
			end
		end
		-- Paragon facions
		for k, v in pairs(paragonRepData) do
			local factionData = C_Reputation.GetFactionDataByID(k)
			local value, max = C_Reputation.GetFactionParagonInfo(k)
			if value ~= v then
				-- Not thoroughly tested
				if v == max then
					-- We were at paragon cap, then the reward was obtained, so we started back at 0
					G_RLF.LootDisplay:ShowRep(value, factionData)
				else
					G_RLF.LootDisplay:ShowRep(value - v, factionData)
				end
				paragonRepData[k] = value
			end
		end
		-- Major factions
		for k, v in pairs(majorRepData) do
			-- Delay in case the rep change caused a level up,
			-- the level up event should take precedent.
			C_Timer.After(0.5, function()
				handleMajorFactionRepChange(k)
			end)
		end
	end
end

function Rep:MAJOR_FACTION_RENOWN_LEVEL_CHANGED(_, mfID, newLevel, oldLevel)
	addAnyNewFactions()
	initializeMajorFaction(mfID)

	handleMajorFactionRepChange(mfID, newLevel)
end

function Rep:CHAT_MSG_COMBAT_FACTION_CHANGE()
	self:FindDelta()
end
