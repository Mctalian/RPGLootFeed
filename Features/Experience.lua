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
		G_RLF:fn(initXpValues)
	end
end

function Xp:PLAYER_ENTERING_WORLD(eventName)
	self:getLogger():Info(eventName, "WOWEVENT", self.moduleName)
	G_RLF:fn(initXpValues)
end

function Xp:PLAYER_XP_UPDATE(eventName, unitTarget)
	self:getLogger():Info(eventName, "WOWEVENT", self.moduleName, unitTarget)
	G_RLF:fn(function()
		if unitTarget == "player" then
			local newLevel = UnitLevel(unitTarget)
			local newCurrentXP = UnitXP(unitTarget)
			local delta = 0
			if newLevel == nil then
				self:getLogger():Warn("Could not get player level", G_RLF.addonName, self.moduleName)
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
				G_RLF.LootDisplay:ShowLoot("Experience", delta)
			else
				self:getLogger()
					:Warn(eventName .. " fired but delta was not positive", G_RLF.addonName, self.moduleName)
			end
		end
	end)
end

return Xp
