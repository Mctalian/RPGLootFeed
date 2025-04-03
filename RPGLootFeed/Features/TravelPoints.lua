---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

---@class RLF_TravelPoints: RLF_Module, AceEvent
local TravelPoints = G_RLF.RLF:NewModule("TravelPoints", "AceEvent-3.0")
local currentTravelersJourney, maxTravelersJourney

TravelPoints.Element = {}

function TravelPoints.Element:new(...)
	---@class TravelPoints.Element: RLF_LootElement
	local element = {}
	G_RLF.InitializeLootDisplayProperties(element)

	element.type = "TravelPoints"
	element.IsEnabled = function()
		return TravelPoints:IsEnabled()
	end

	element.key = "TRAVELPOINTS"
	element.quantity = ...
	element.r, element.g, element.b, element.a = unpack(G_RLF.db.global.travelPoints.textColor)
	element.textFn = function(existingAmount)
		return _G["MONTHLY_ACTIVITIES_POINTS"] .. " + " .. ((existingAmount or 0) + element.quantity)
	end
	element.icon = G_RLF.DefaultIcons.TRAVELPOINTS
	element.quality = Enum.ItemQuality.Common

	element.secondaryTextFn = function()
		if not currentTravelersJourney then
			return ""
		end
		if not maxTravelersJourney then
			return ""
		end

		local color = G_RLF:RGBAToHexFormat(element.r, element.g, element.b, element.a)

		return "    " .. color .. currentTravelersJourney .. "/" .. maxTravelersJourney .. "|r"
	end

	return element
end

local function initTravelersJourneyValues()
	local allInfo = C_PerksActivities.GetPerksActivitiesInfo()
	if allInfo == nil then
		G_RLF:LogWarn("Could not get all activity info", addonName, TravelPoints.moduleName)
		return
	end

	local progress = 0
	for i, v in ipairs(allInfo.activities) do
		if v.completed then
			progress = progress + v.thresholdContributionAmount
		end
	end

	local max = 0
	for i, v in ipairs(allInfo.thresholds) do
		max = math.max(max, v.requiredContributionAmount)
	end

	currentTravelersJourney = progress
	maxTravelersJourney = max
end

function TravelPoints:OnInitialize()
	if G_RLF.db.global.travelPoints.enabled then
		self:Enable()
	else
		self:Disable()
	end
end

function TravelPoints:OnDisable()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:UnregisterEvent("PERKS_ACTIVITY_COMPLETED")
end

function TravelPoints:OnEnable()
	G_RLF:LogDebug("OnEnable", addonName, self.moduleName)
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PERKS_ACTIVITY_COMPLETED")
	if currentTravelersJourney == nil then
		self:fn(initTravelersJourneyValues)
	end
end

function TravelPoints:PLAYER_ENTERING_WORLD(eventName)
	G_RLF:LogInfo(eventName, "WOWEVENT", self.moduleName)
	self:fn(initTravelersJourneyValues)
end

function TravelPoints:PERKS_ACTIVITY_COMPLETED(eventName, activityID)
	G_RLF:LogInfo(eventName, "WOWEVENT", self.moduleName, activityID)

	local info = C_PerksActivities.GetPerksActivityInfo(activityID)
	if info == nil then
		G_RLF:LogWarn("Could not get activity info", addonName, self.moduleName)
		return
	end
	local amount = info.thresholdContributionAmount

	currentTravelersJourney = (currentTravelersJourney or 0) + amount

	if amount > 0 then
		local e = self.Element:new(amount)
		e:Show()
	else
		G_RLF:LogWarn(eventName .. " fired but amount was not positive", addonName, self.moduleName)
	end
end

return TravelPoints
