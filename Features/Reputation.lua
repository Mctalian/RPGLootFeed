local Rep = {}

local repData = {}
local paragonRepData = {}
local majorRepData = {}
local cachedFactionCount
function Rep:RefreshRepData()
    C_Reputation.ExpandAllFactionHeaders()
    local numFactions = C_Reputation.GetNumFactions()
    if numFactions <= 0 then
        return
    end

    local count = 0
    for i = 1, numFactions do
        local factionData = C_Reputation.GetFactionDataByIndex(i)
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

    cachedFactionCount = count
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
              majorRepData[fId] = { level, 0, max}
            end
          else
            if not repData[fId] then
              repData[fId] = 0
            end
          end
      end
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
          end
      end
      -- Major factions
      for k, v in pairs(majorRepData) do
          local factionData = C_Reputation.GetFactionDataByID(k)
          local majorFactionData = C_MajorFactions.GetMajorFactionData(k)
          local level = majorFactionData.renownLevel
          local rep = majorFactionData.renownReputationEarned
          local max = majorFactionData.renownLevelThreshold
          local oldLevel, oldRep, oldMax = unpack(v)
          -- Not thoroughly tested
          if oldLevel == level then
              if rep ~= oldRep then
                  G_RLF.LootDisplay:ShowRep(rep - oldRep, factionData)
              end
          else
              G_RLF.LootDisplay:ShowRep(oldMax - oldRep + rep, factionData)
          end
      end
  end

  Rep:RefreshRepData()
end

G_RLF.Rep = Rep
