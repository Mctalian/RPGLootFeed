---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

local Features = {}

---@class RLF_DBGlobal
G_RLF.defaults.global = G_RLF.defaults.global or {}

---@class RLF_ConfigLootHistory
G_RLF.defaults.global.lootHistory = {
	enabled = true,
	hideTab = false,
	historyLimit = 100,
}
---@class RLF_ConfigTooltips
G_RLF.defaults.global.tooltips = {
	hover = {
		enabled = true,
		onShift = false,
	},
}
---@class RLF_ConfigMinimap : LibDBIcon.button.DB
---@field hide boolean
---@field lock boolean
---@field minimapPos integer
G_RLF.defaults.global.minimap = {
	hide = true,
	lock = false,
	minimapPos = 220,
}

G_RLF.mainFeatureOrder = {
	ItemLoot = 1,
	PartyLoot = 2,
	Currency = 3,
	Money = 4,
	XP = 5,
	Rep = 6,
	Skills = 7,
	TravelPoints = 8,
}
local lastFeature = G_RLF.mainFeatureOrder.TravelPoints

G_RLF.options.args.features = {
	type = "group",
	handler = Features,
	name = G_RLF.L["Features"],
	desc = G_RLF.L["FeaturesDesc"],
	order = 4,
	args = {
		mainFeaturesHeader = {
			type = "header",
			name = G_RLF.L["Loot Feeds"],
			order = G_RLF.mainFeatureOrder.ItemLoot - 0.1,
		},
		enableItemLoot = {
			type = "toggle",
			name = G_RLF.L["Enable Item Loot in Feed"],
			desc = G_RLF.L["EnableItemLootDesc"],
			width = "double",
			get = "GetItemLootStatus",
			set = "SetItemLootStatus",
			order = G_RLF.mainFeatureOrder.ItemLoot,
		},
		enablePartyLoot = {
			type = "toggle",
			name = G_RLF.L["Enable Party Loot in Feed"],
			desc = G_RLF.L["EnablePartyLootDesc"],
			width = "double",
			get = function()
				return G_RLF.db.global.partyLoot.enabled
			end,
			set = function(info, value)
				G_RLF.db.global.partyLoot.enabled = value
				if value then
					G_RLF.RLF:EnableModule(G_RLF.FeatureModule.PartyLoot)
				else
					G_RLF.RLF:DisableModule(G_RLF.FeatureModule.PartyLoot)
				end
			end,
			order = G_RLF.mainFeatureOrder.PartyLoot,
		},
		enableCurrency = {
			type = "toggle",
			name = G_RLF.L["Enable Currency in Feed"],
			desc = G_RLF.L["EnableCurrencyDesc"],
			width = "double",
			get = "GetCurrencyStatus",
			set = "SetCurrencyStatus",
			disabled = function()
				return GetExpansionLevel() < G_RLF.Expansion.SL
			end,
			order = G_RLF.mainFeatureOrder.Currency,
		},
		enableMoney = {
			type = "toggle",
			name = G_RLF.L["Enable Money in Feed"],
			desc = G_RLF.L["EnableMoneyDesc"],
			width = "double",
			get = "GetMoneyStatus",
			set = "SetMoneyStatus",
			order = G_RLF.mainFeatureOrder.Money,
		},
		enableXp = {
			type = "toggle",
			name = G_RLF.L["Enable Experience in Feed"],
			desc = G_RLF.L["EnableXPDesc"],
			width = "double",
			get = "GetXPStatus",
			set = "SetXPStatus",
			order = G_RLF.mainFeatureOrder.XP,
		},
		enableRep = {
			type = "toggle",
			name = G_RLF.L["Enable Reputation in Feed"],
			desc = G_RLF.L["EnableRepDesc"],
			width = "double",
			get = "GetRepStatus",
			set = "SetRepStatus",
			order = G_RLF.mainFeatureOrder.Rep,
		},
		enableProf = {
			type = "toggle",
			name = G_RLF.L["Enable Professions in Feed"],
			desc = G_RLF.L["EnableProfDesc"],
			width = "double",
			get = "GetProfStatus",
			set = "SetProfStatus",
			order = G_RLF.mainFeatureOrder.Skills,
		},
		enableTravelPoints = {
			type = "toggle",
			name = G_RLF.L["Enable Travel Points in Feed"],
			desc = G_RLF.L["EnableTravelPointsDesc"],
			width = "double",
			disabled = function()
				return not G_RLF:IsRetail()
			end,
			get = function()
				return G_RLF.db.global.travelPoints.enabled
			end,
			set = function(_, value)
				G_RLF.db.global.travelPoints.enabled = value
				if value then
					G_RLF.RLF:EnableModule(G_RLF.FeatureModule.TravelPoints)
				else
					G_RLF.RLF:DisableModule(G_RLF.FeatureModule.TravelPoints)
				end
			end,
			order = G_RLF.mainFeatureOrder.TravelPoints,
		},

		misc = {
			type = "group",
			inline = true,
			name = G_RLF.L["Miscellaneous"],
			order = lastFeature + 1,
			args = {
				showMinimapIcon = {
					type = "toggle",
					name = G_RLF.L["Show Minimap Icon"],
					desc = G_RLF.L["ShowMinimapIconDesc"],
					width = "double",
					get = function()
						return not G_RLF.db.global.minimap.hide
					end,
					set = function(info, value)
						G_RLF.db.global.minimap.hide = not value
						if G_RLF.db.global.minimap.hide then
							G_RLF.DBIcon:Hide(addonName)
						else
							G_RLF.DBIcon:Show(addonName)
						end
					end,
					order = 0.5,
				},
				enableLootHistory = {
					type = "toggle",
					name = G_RLF.L["Enable Loot History"],
					desc = G_RLF.L["EnableLootHistoryDesc"],
					get = "GetLootHistoryStatus",
					set = "SetLootHistoryStatus",
					order = 1,
				},
				lootHistorySize = {
					type = "range",
					name = G_RLF.L["Loot History Size"],
					desc = G_RLF.L["LootHistorySizeDesc"],
					disabled = "LootHistoryDisabled",
					min = 1,
					max = 1000,
					step = 1,
					get = "GetLootHistorySize",
					set = "SetLootHistorySize",
					order = 2,
				},
				hideLootHistoryTab = {
					type = "toggle",
					name = G_RLF.L["Hide Loot History Tab"],
					desc = G_RLF.L["HideLootHistoryTabDesc"],
					width = "double",
					get = function()
						return G_RLF.db.global.lootHistory.hideTab
					end,
					set = function(info, value)
						G_RLF.db.global.lootHistory.hideTab = value
						---@type RLF_LootDisplayFrame
						local frame = G_RLF.RLF_MainLootFrame
						frame:UpdateTabVisibility()
						local partyFrame = G_RLF.RLF_PartyLootFrame
						if partyFrame then
							partyFrame:ToggleHistoryFrame()
						end
					end,
					order = 2.5,
				},
				enableTooltip = {
					type = "toggle",
					name = G_RLF.L["Enable Item/Currency Tooltips"],
					desc = G_RLF.L["EnableTooltipsDesc"],
					width = "double",
					get = "GetTooltipStatus",
					set = "SetTooltipStatus",
					order = 3,
				},
				extraTooltipOptions = {
					type = "group",
					name = G_RLF.L["Tooltip Options"],
					inline = true,
					disabled = "TooltipShiftDisabled",
					order = 4,
					args = {
						onlyShiftOnEnter = {
							type = "toggle",
							name = G_RLF.L["Show only when SHIFT is held"],
							desc = G_RLF.L["OnlyShiftOnEnterDesc"],
							width = "double",
							get = "GetTooltipShiftStatus",
							set = "SetTooltipShiftStatus",
							order = 1,
						},
					},
				},
				enableSecondaryRowText = {
					type = "toggle",
					name = G_RLF.L["Enable Secondary Row Text"],
					desc = G_RLF.L["EnableSecondaryRowTextDesc"],
					width = "double",
					get = "GetSecondaryRowText",
					set = "SetSecondaryRowText",
					order = 5,
				},
			},
		},
	},
}

function Features:GetLootHistoryStatus()
	return G_RLF.db.global.lootHistory.enabled
end

function Features:SetLootHistoryStatus(info, value)
	G_RLF.db.global.lootHistory.enabled = value
	---@type RLF_LootDisplayFrame
	local frame = G_RLF.RLF_MainLootFrame
	frame:UpdateTabVisibility()
	local partyFrame = G_RLF.RLF_PartyLootFrame
	if partyFrame then
		partyFrame:ToggleHistoryFrame()
	end
end

function Features:LootHistoryDisabled()
	return not G_RLF.db.global.lootHistory.enabled
end

function Features:GetLootHistorySize()
	return G_RLF.db.global.lootHistory.historyLimit
end

function Features:SetLootHistorySize(info, value)
	G_RLF.db.global.lootHistory.historyLimit = value
end

function Features:GetSecondaryRowText(info, value)
	return G_RLF.db.global.styling.enabledSecondaryRowText
end

function Features:SetSecondaryRowText(info, value)
	G_RLF.db.global.styling.enabledSecondaryRowText = value
	G_RLF.LootDisplay:UpdateRowStyles()
end

function Features:SecondaryTextDisabled()
	return not G_RLF.db.global.styling.enabledSecondaryRowText
end

function Features:GetPartyLootStatus()
	return G_RLF.db.global.partyLoot.enabled
end

function Features:SetPartyLootStatus(info, value)
	G_RLF.db.global.partyLoot.enabled = value
end

function Features:GetItemLootStatus(info, value)
	return G_RLF.db.global.item.enabled
end

function Features:SetItemLootStatus(info, value)
	G_RLF.db.global.item.enabled = value
	if value then
		G_RLF.RLF:EnableModule("ItemLoot")
	else
		G_RLF.RLF:DisableModule("ItemLoot")
	end
end

function Features:GetCurrencyStatus(info, value)
	return G_RLF.db.global.currency.enabled
end

function Features:SetCurrencyStatus(info, value)
	G_RLF.db.global.currency.enabled = value
	if value then
		G_RLF.RLF:EnableModule("Currency")
	else
		G_RLF.RLF:DisableModule("Currency")
	end
end

function Features:GetTooltipStatus(info, value)
	return G_RLF.db.global.tooltips.hover.enabled
end

function Features:SetTooltipStatus(info, value)
	G_RLF.db.global.tooltips.hover.enabled = value
end

function Features:TooltipShiftDisabled()
	return not G_RLF.db.global.tooltips.hover.enabled
end

function Features:GetTooltipShiftStatus(info, value)
	return G_RLF.db.global.tooltips.hover.onShift
end

function Features:SetTooltipShiftStatus(info, value)
	G_RLF.db.global.tooltips.hover.onShift = value
end

function Features:GetMoneyStatus(info, value)
	return G_RLF.db.global.money.enabled
end

function Features:SetMoneyStatus(info, value)
	G_RLF.db.global.money.enabled = value
	if value then
		G_RLF.RLF:EnableModule("Money")
	else
		G_RLF.RLF:DisableModule("Money")
	end
end

function Features:GetXPStatus(info, value)
	return G_RLF.db.global.xp.enabled
end

function Features:SetXPStatus(info, value)
	G_RLF.db.global.xp.enabled = value
	if value then
		G_RLF.RLF:EnableModule("Experience")
	else
		G_RLF.RLF:DisableModule("Experience")
	end
end

function Features:GetRepStatus(info, value)
	return G_RLF.db.global.rep.enabled
end

function Features:SetRepStatus(info, value)
	G_RLF.db.global.rep.enabled = value
	if value then
		G_RLF.RLF:EnableModule("Reputation")
	else
		G_RLF.RLF:DisableModule("Reputation")
	end
end

function Features:GetProfStatus(info, value)
	return G_RLF.db.global.prof.enabled
end

function Features:SetProfStatus(info, value)
	G_RLF.db.global.prof.enabled = value
	if value then
		G_RLF.RLF:EnableModule("Professions")
	else
		G_RLF.RLF:DisableModule("Professions")
	end
end
