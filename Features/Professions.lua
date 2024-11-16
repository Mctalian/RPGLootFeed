local addonName, G_RLF = ...

local Professions = G_RLF.RLF:NewModule("Professions", "AceEvent-3.0")

Professions.Element = {}

local color = "|cFF5555FF"

function Professions.Element:new(...)
	local element = {}
	G_RLF.InitializeLootDisplayProperties(element)

	element.type = "Professions"
	element.IsEnabled = function()
		return Professions:IsEnabled()
	end

	local keyPrefix = "PROF_"

	local key
	key, element.name, element.icon, element.level, element.maxLevel, element.quantity = ...
	element.quality = Enum.ItemQuality.Rare

	element.key = keyPrefix .. key

	element.textFn = function()
		return color .. element.name .. " " .. element.level .. "|r"
	end

	element.secondaryTextFn = function()
		return ""
	end

	return element
end

local segments
local localeString = _G.SKILL_RANK_UP
function Professions:OnInitialize()
	self.professions = {}
	self.profNameIconMap = {}
	self.profLocaleBaseNames = {}
	if G_RLF.db.global.profFeed then
		self:Enable()
	else
		self:Disable()
	end
	segments = G_RLF:CreatePatternSegmentsForStringNumber(localeString)
end

function Professions:OnDisable()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:UnregisterEvent("CHAT_MSG_SKILL")
end

function Professions:OnEnable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("CHAT_MSG_SKILL")
end

function Professions:InitializeProfessions()
	local primaryId, secondaryId, archId, fishingId, cookingId = GetProfessions()
	local profs = { primaryId, secondaryId, archId, fishingId, cookingId }
	for i = 1, #profs do
		if profs[i] then
			local name, icon, skillLevel, maxSkillLevel, numAbilities, spellOffset, skillLine, skillModifier, specializationIndex, specializationOffset, a, b =
				GetProfessionInfo(profs[i])
			if name and icon then
				self.profNameIconMap[name] = icon
			end
		end
	end

	for k, v in pairs(self.profNameIconMap) do
		table.insert(self.profLocaleBaseNames, k)
	end
end

function Professions:PLAYER_ENTERING_WORLD()
	Professions:InitializeProfessions()
end

function Professions:CHAT_MSG_SKILL(event, message)
	G_RLF:LogInfo(event, "WOWEVENT", self.moduleName, nil, message)

	local skillName, skillLevel = G_RLF:ExtractDynamicsFromPattern(message, segments)
	if skillName and skillLevel then
		if not self.professions[skillName] then
			self.professions[skillName] = {
				name = skillName,
				lastSkillLevel = skillLevel,
			}
		end
		local icon
		if self.profNameIconMap[skillName] then
			icon = self.profNameIconMap[skillName]
		else
			for i = 1, #self.profLocaleBaseNames do
				if skillName:find(self.profLocaleBaseNames[i]) then
					icon = self.profNameIconMap[self.profLocaleBaseNames[i]]
					self.profNameIconMap[skillName] = icon
					break
				end
			end
		end
		local e = self.Element:new(
			skillName,
			skillName,
			icon,
			skillLevel,
			nil,
			skillLevel - self.professions[skillName].lastSkillLevel
		)
		e:Show()
		self.professions[skillName].lastSkillLevel = skillLevel
	end
end

return Professions
