---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

---@class RLF_Experience: RLF_Module, AceEvent-3.0
local Xp = G_RLF.RLF:NewModule(G_RLF.FeatureModule.Experience, "AceEvent-3.0")
local currentXP, currentMaxXP, currentLevel

-- Context provider function to be registered when module is enabled
local function createExperienceContextProvider()
	return function(context, data)
		-- Basic XP display
		context.xpLabel = G_RLF.L["XP"]

		-- Current XP percentage for secondary text
		if currentXP and currentMaxXP and currentMaxXP > 0 then
			local percentage = currentXP / currentMaxXP * 100
			context.currentXPPercentage = string.format("%.2f", percentage) .. "%%" -- need to escape % since it's being used in a gsub later
		else
			-- When XP data is not available, provide empty percentage
			context.currentXPPercentage = ""
		end
	end
end

Xp.Element = {}

function Xp.Element:new(...)
	---@class Xp.Element: RLF_BaseLootElement
	local element = {}
	G_RLF.InitializeLootDisplayProperties(element)

	element.type = G_RLF.FeatureModule.Experience
	element.IsEnabled = function()
		return Xp:IsEnabled()
	end

	element.key = "EXPERIENCE"
	element.quantity = ...
	if not element.quantity or element.quantity == 0 then
		return
	end

	element.itemCount = currentLevel
	element.icon = G_RLF.DefaultIcons.XP
	if not G_RLF.db.global.xp.enableIcon or G_RLF.db.global.misc.hideAllIcons then
		element.icon = nil
	end
	element.quality = G_RLF.ItemQualEnum.Epic

	-- Generate text elements using the new data-driven approach
	element.textElements = Xp:GenerateTextElements(element.quantity)

	---@type RLF_LootElementData
	local elementData = {
		key = element.key,
		type = "Experience", -- Use string type for context provider lookup
		textElements = element.textElements,
		quantity = element.quantity,
		icon = element.icon,
		quality = element.quality,
	}

	element.textFn = function(existingXP)
		return G_RLF.TextTemplateEngine:ProcessRowElements(1, elementData, existingXP)
	end

	element.secondaryTextFn = function(existingXP)
		return G_RLF.TextTemplateEngine:ProcessRowElements(2, elementData, existingXP)
	end

	return element
end

--- Generate text elements for Experience type using the new data-driven approach
---@param quantity number The experience amount
---@return table<number, table<string, RLF_TextElement>> textElements Row-indexed elements: [row][elementKey] = element
function Xp:GenerateTextElements(quantity)
	local elements = {}

	local xpTextColor = G_RLF.db.global.xp.experienceTextColor

	-- Row 1: Primary experience display
	elements[1] = {}
	elements[1].primary = {
		type = "primary",
		template = "{sign}{total} {xpLabel}",
		order = 1,
		color = xpTextColor,
	}

	-- Row 2: Context text element (XP percentage)
	elements[2] = {}
	elements[2].contextSpacer = {
		type = "spacer",
		spacerCount = 4, -- "    " spacing
		order = 1,
	}

	elements[2].context = {
		type = "context",
		template = "{currentXPPercentage}",
		order = 2,
		color = xpTextColor,
	}

	return elements
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
	-- Unregister our context provider
	G_RLF.TextTemplateEngine.contextProviders["Experience"] = nil

	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:UnregisterEvent("PLAYER_XP_UPDATE")
end

function Xp:OnEnable()
	G_RLF:LogDebug("OnEnable", addonName, self.moduleName)

	-- Register our context provider with the TextTemplateEngine
	G_RLF.TextTemplateEngine:RegisterContextProvider("Experience", createExperienceContextProvider())

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
	if unitTarget ~= "player" then
		return
	end

	local oldLevel = currentLevel
	local oldCurrentXP = currentXP
	local oldMaxXP = currentMaxXP
	local newLevel = UnitLevel(unitTarget)
	if newLevel == nil then
		G_RLF:LogWarn("Could not get player level", addonName, self.moduleName)
		return
	end
	currentLevel = newLevel
	currentXP = UnitXP(unitTarget)
	currentMaxXP = UnitXPMax(unitTarget)
	local delta = 0
	if newLevel > oldLevel then
		delta = (oldMaxXP - oldCurrentXP) + currentXP
	else
		delta = currentXP - oldCurrentXP
	end

	if delta > 0 then
		self:fn(function()
			local e = self.Element:new(delta)
			if e then
				e:Show()
			end
		end)
	else
		G_RLF:LogWarn(eventName .. " fired but delta was not positive", addonName, self.moduleName)
	end
end

return Xp
