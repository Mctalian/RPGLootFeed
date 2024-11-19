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

function Professions:OnInitialize()
	self.professions = {}
	self.isRegisteredSkillLinesChanged = false
	if G_RLF.db.global.profFeed then
		self:Enable()
	else
		self:Disable()
	end
end

function Professions:OnDisable()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:UnregisterEvent("SKILL_LINES_CHANGED")
end

function Professions:OnEnable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function Professions:InitializeProfessions()
	local primaryId, secondaryId, archId, fishingId, cookingId = GetProfessions()
	local profs = { primaryId, secondaryId, archId, fishingId, cookingId }
	for i = 1, #profs do
		if profs[i] then
			local name, icon, level, maxLevel, _, _, _, _, _, _, expansionName = GetProfessionInfo(profs[i])
			self.professions[profs[i]] = {
				name = name,
			}
			self.professions[profs[i]][expansionName] = {
				icon = icon,
				level = level,
				maxLevel = maxLevel,
				expansionName = expansionName,
			}
		end
	end
end

function Professions:PLAYER_ENTERING_WORLD()
	if self.isRegisteredSkillLinesChanged == false then
		self.isRegisteredSkillLinesChanged = true
		self:RegisterEvent("SKILL_LINES_CHANGED")
	end
	self:InitializeProfessions()
end

function Professions:SKILL_LINES_CHANGED()
	local primaryId, secondaryId, archId, fishingId, cookingId = GetProfessions()
	local profs = { primaryId, secondaryId, archId, fishingId, cookingId }
	for i = 1, #profs do
		if profs[i] then
			local name, icon, level, maxLevel, _, _, _, _, _, _, expansionName = GetProfessionInfo(profs[i])
			if self.professions[profs[i]] then
				if self.professions[profs[i]][expansionName] then
					local expansionDetails = self.professions[profs[i]][expansionName]
					local delta = level - expansionDetails.level
					if delta > 0 then
						expansionDetails.level = level
						expansionDetails.maxLevel = maxLevel
						local e = self.Element:new(profs[i], expansionName, icon, level, maxLevel, delta)
						e:Show()
					end
				else
					self.professions[profs[i]][expansionName] = {
						icon = icon,
						level = level,
						maxLevel = maxLevel,
						expansionName = expansionName,
					}
				end
			else
				self.professions[profs[i]] = {
					name = name,
				}
				self.professions[profs[i]][expansionName] = {
					icon = icon,
					level = level,
					maxLevel = maxLevel,
					expansionName = expansionName,
				}
			end
		end
	end
end

return Professions
