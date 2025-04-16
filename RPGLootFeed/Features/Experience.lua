---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

---@class RLF_Experience: RLF_Module, AceEvent-3.0
local Xp = G_RLF.RLF:NewModule("Experience", "AceEvent-3.0")
local currentXP, currentMaxXP, currentLevel

Xp.Element = {}

function Xp.Element:new(...)
	---@class Xp.Element: RLF_BaseLootElement
	local element = {}
	G_RLF.InitializeLootDisplayProperties(element)

	element.type = "Experience"
	element.IsEnabled = function()
		return Xp:IsEnabled()
	end

	element.key = "EXPERIENCE"
	element.quantity = ...
	element.r, element.g, element.b, element.a = unpack(G_RLF.db.global.xp.experienceTextColor)
	element.textFn = function(existingXP)
		return "+" .. ((existingXP or 0) + element.quantity) .. " " .. G_RLF.L["XP"]
	end
	element.itemCount = currentLevel
	element.icon = G_RLF.DefaultIcons.XP
	element.quality = Enum.ItemQuality.Epic

	element.secondaryTextFn = function()
		if not currentXP then
			return ""
		end
		if not currentMaxXP then
			return ""
		end
		local color = G_RLF:RGBAToHexFormat(element.r, element.g, element.b, element.a)

		return "    " .. color .. math.floor((currentXP / currentMaxXP) * 10000) / 100 .. "%|r"
	end

	return element
end

local function initXpValues()
	currentXP = UnitXP("player")
	currentMaxXP = UnitXPMax("player")
	currentLevel = UnitLevel("player")
end

function Xp:OnInitialize()
	if G_RLF.db.global.xp.enabled then
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
	G_RLF:LogDebug("OnEnable", addonName, self.moduleName)
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_XP_UPDATE")
	if currentXP == nil then
		self:fn(initXpValues)
	end
end

function Xp:PLAYER_ENTERING_WORLD(eventName)
	G_RLF:LogInfo(eventName, "WOWEVENT", self.moduleName)
	self:fn(initXpValues)
end

function Xp:PLAYER_XP_UPDATE(eventName, unitTarget)
	G_RLF:LogInfo(eventName, "WOWEVENT", self.moduleName, unitTarget)
	self:fn(function()
		if unitTarget == "player" then
			local newLevel = UnitLevel(unitTarget)
			local newCurrentXP = UnitXP(unitTarget)
			local delta = 0
			if newLevel == nil then
				G_RLF:LogWarn("Could not get player level", addonName, self.moduleName)
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
				G_RLF:LogWarn(eventName .. " fired but delta was not positive", addonName, self.moduleName)
			end
		end
	end)
end

return Xp
