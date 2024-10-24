local addonName, G_RLF = ...

local Xp = G_RLF.RLF:NewModule("Experience", "AceEvent-3.0")
local currentXP, currentMaxXP, currentLevel

Xp.Element = {}

function Xp.Element:new(...)
	local element = {}
	G_RLF.InitializeLootDisplayProperties(element)

	element.type = "Experience"
	element.IsEnabled = function()
		return Xp:IsEnabled()
	end

	element.key = "EXPERIENCE"
	element.quantity = ...
	element.r, element.g, element.b, element.a = 1, 0, 1, 0.8
	element.textFn = function(existingXP)
		return "+" .. ((existingXP or 0) + element.quantity) .. " " .. G_RLF.L["XP"]
	end

	element.secondaryTextFn = function()
		if not currentXP then
			return ""
		end
		if not currentMaxXP then
			return ""
		end
		local color = G_RLF:RGBAToHexFormat(1, 1, 1, 1)

		return "    "
			.. color
			.. currentLevel
			.. "|r    "
			.. math.floor((currentXP / currentMaxXP) * 10000) / 100
			.. "%"
	end

	return element
end

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
				self:getLogger():Warn("Could not get player level", addonName, self.moduleName)
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
				self:getLogger():Warn(eventName .. " fired but delta was not positive", addonName, self.moduleName)
			end
		end
	end)
end

return Xp
