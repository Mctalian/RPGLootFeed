local Rep = {}

local repData = {}
local paragonRepData = {}
local majorRepData = {}
local cachedFactionCount
function Rep:Snapshot()
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

	cachedFactionCount = count
end

function Rep:AddAnyNewFactions()
	local i = 1
	local factionData = C_Reputation.GetFactionDataByIndex(i)
	while factionData ~= nil do
		if not factionData.isHeader or factionData.isHeaderWithRep then
			local factionData = C_Reputation.GetFactionDataByIndex(i)
			local fId = factionData.factionID
			if C_Reputation.IsFactionParagon(fId) then
				if not paragonRepData[fId] then
					paragonRepData[fId] = 0
				end
			elseif C_Reputation.IsMajorFaction(fId) then
				if not majorRepData[fId] then
					local mfd = C_MajorFactions.GetMajorFactionData(fId)
					local level = mfd.renownLevel
					local max = mfd.renownLevelThreshold
					majorRepData[fId] = { level, 0, max }
				end
			else
				if not repData[fId] then
					repData[fId] = 0
				end
			end
		end
		i = i + 1
		factionData = C_Reputation.GetFactionDataByIndex(i)
	end
end

function Rep:FindDelta()
	Rep:AddAnyNewFactions()

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
			handleMajorFactionRepChange(k)
		end
	end
end

function handleMajorFactionRepChange(id, level)
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

function Rep:OnChangeMajorFactionRenownLevel(mfID, newLevel, oldLevel)
	handleMajorFactionRepChange(mfID, newLevel)
end

G_RLF.Rep = Rep
