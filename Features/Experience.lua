local addonName, ns = ...

local Xp = G_RLF.RLF:NewModule("Experience", "AceEvent-3.0")

Xp.Element = {}

function Xp.Element:new(...)
	ns.InitializeLootDisplayProperties(self)

	self.type = "Experience"
	self.IsEnabled = function()
		return Xp:IsEnabled()
	end

	self.key = "EXPERIENCE"
	self.quantity = ...
	self.r, self.g, self.b, self.a = 1, 0, 1, 0.8
	self.textFn = function(existingXP)
		return "+" .. ((existingXP or 0) + self.quantity) .. " " .. G_RLF.L["XP"]
	end

	return self
end

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
		self:fn(initXpValues)
	end
end

function Xp:PLAYER_ENTERING_WORLD(eventName)
	self:getLogger():Info(eventName, "WOWEVENT", self.moduleName)
	self:fn(initXpValues)
end

function Xp:PLAYER_XP_UPDATE(eventName, unitTarget)
	self:getLogger():Info(eventName, "WOWEVENT", self.moduleName, unitTarget)
	self:fn(function()
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
				local e = self.Element:new(delta)
				e:Show()
			else
				self:getLogger()
					:Warn(eventName .. " fired but delta was not positive", G_RLF.addonName, self.moduleName)
			end
		end
	end)
end

return Xp
