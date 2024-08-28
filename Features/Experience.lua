local Xp = {}

local currentXP, currentMaxXP, currentLevel

function Xp:Snapshot()
	currentXP = UnitXP("player")
	currentMaxXP = UnitXPMax("player")
	currentLevel = UnitLevel("player")
end

function Xp:OnXpChange(unitTarget)
	if not G_RLF.db.global.xpFeed then
		return
	end

	if unitTarget == "player" then
		local newLevel = UnitLevel(unitTarget)
		local newCurrentXP = UnitXP(unitTarget)
		local delta = 0
		if newLevel == nil then
			return
		end
		currentLevel = currentLevel or newLevel
		if newLevel > currentLevel then
			delta = (currentMaxXP - currentXP) + newCurrentXP
		else
			delta = newCurrentXP - currentXP
		end
		currentXP = newCurrentXP
		currentLevel = newLevel
		currentMaxXP = UnitXPMax(unitTarget)
		if delta > 0 then
			G_RLF.LootDisplay:ShowXP(delta)
		end
	end
end

G_RLF.Xp = Xp
