local Rep = {}

local repData = {}
local paragonRepData = {}
local majorRepData = {}
local cachedFactionCount
function Rep:Snapshot()
	C_Reputation.ExpandAllFactionHeaders()
	local numFactions = C_Reputation.GetNumFactions()
	if numFactions <= 0 then
		return
	end

	local count = 0
	for i = 1, numFactions do
		local factionData = C_Reputation.GetFactionDataByIndex(i)
		if factionData ~= nil then
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
		end
	end
	G_RLF:Print("Rep refreshed")
	G_RLF:Print(dump(majorRepData[2590]))

	cachedFactionCount = count
end

function dump(o)
	if type(o) == "table" then
		local s = "{ "
		for k, v in pairs(o) do
			if type(k) ~= "number" then
				k = '"' .. k .. '"'
			end
			s = s .. "[" .. k .. "] = " .. dump(v) .. ","
		end
		return s .. "} "
	else
		return tostring(o)
	end
end

function Rep:AddAnyNewFactions()
	-- Unfortunately, everything needs to be expanded before we can get the number of factions
	C_Reputation.ExpandAllFactionHeaders()
	local numFactions = C_Reputation.GetNumFactions()
	if numFactions <= 0 then
		return
	end

	for i = 1, numFactions do
		local factionData = C_Reputation.GetFactionDataByIndex(i)
		if factionData ~= nil then
			if not factionData.isHeader or factionData.isHeaderWithRep then
				local factionData = C_Reputation.GetFactionDataByIndex(i)
				local fId = factionData.factionID
				if C_Reputation.IsFactionParagon(fId) then
					if not paragonRepData[fId] then
						paragonRepData[fId] = 0
						G_RLF:Print(fId .. " added")
					end
				elseif C_Reputation.IsMajorFaction(fId) then
					if not majorRepData[fId] then
						local mfd = C_MajorFactions.GetMajorFactionData(fId)
						local level = mfd.renownLevel
						local max = mfd.renownLevelThreshold
						majorRepData[fId] = { level, 0, max }
						G_RLF:Print(fId .. " added")
					end
				else
					if not repData[fId] then
						repData[fId] = 0
						G_RLF:Print(fId .. " added")
					end
				end
			end
		end
	end
	G_RLF:Print("New factions added")
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
			local factionData = C_Reputation.GetFactionDataByID(k)
			local majorFactionData = C_MajorFactions.GetMajorFactionData(k)
			local level = C_MajorFactions.GetCurrentRenownLevel(k)
			local rep = majorFactionData.renownReputationEarned
			local max = majorFactionData.renownLevelThreshold
			local oldLevel, oldRep, oldMax = unpack(v)
			if k == 2590 then
				G_RLF:Print(dump(v))
				G_RLF:Print(oldLevel .. "->" .. level)
				G_RLF:Print(oldRep .. "->" .. rep)
				G_RLF:Print(oldMax .. "->" .. max)
			end
			-- It seems like the renownLevel is not updated quick enough and comes back as the same value
			-- In that case, we will see the same level, but the rep will drop
			if rep > oldRep then
				G_RLF.LootDisplay:ShowRep(rep - oldRep, factionData)
			elseif rep < oldRep then
				G_RLF.LootDisplay:ShowRep(oldMax - oldRep + rep, factionData)
			elseif rep == oldRep and level > oldLevel then
				G_RLF.LootDisplay:ShowRep(oldMax - oldRep + rep, factionData)
			end
			majorRepData[k] = { level, rep, max }
		end
	end

	-- Rep:Snapshot()
end

function handleMajorFactionRepChange(id, level)
	local factionData = C_Reputation.GetFactionDataByID(id)
	local majorFactionData = C_MajorFactions.GetMajorFactionData(id)
	local level = level or C_MajorFactions.GetCurrentRenownLevel(id)
	local rep = majorFactionData.renownReputationEarned
	local max = majorFactionData.renownLevelThreshold
	local oldLevel, oldRep, oldMax = unpack(v)
	if id == 2590 then
		G_RLF:Print(dump(v))
		G_RLF:Print(oldLevel .. "->" .. level)
		G_RLF:Print(oldRep .. "->" .. rep)
		G_RLF:Print(oldMax .. "->" .. max)
	end
	-- It seems like the renownLevel is not updated quick enough and comes back as the same value
	-- In that case, we will see the same level, but the rep will drop
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
