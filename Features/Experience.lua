local Xp = G_RLF.RLF:NewModule("Experience", "AceEvent-3.0")

local currentXP, currentMaxXP, currentLevel
local function initXpValues()
	currentXP = UnitXP("player")
	currentMaxXP = UnitXPMax("player")
	currentLevel = UnitLevel("player")
end

function Xp:OnInitialize()
	if G_RLF.db.global.xpFeed then
		self:Enable()
	else
		self:Disable()
	end
end

function Xp:OnDisable()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:UnregisterEvent("PLAYER_XP_UPDATE")
end

function Xp:OnEnable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_XP_UPDATE")
	if currentXP == nil then
		initXpValues()
	end
end

function Xp:PLAYER_ENTERING_WORLD()
	initXpValues()
end

function Xp:PLAYER_XP_UPDATE(_, unitTarget)
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

return Xp
