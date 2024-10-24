local addonName, G_RLF = ...

local Features = {}

G_RLF.defaults.global.lootHistoryEnabled = true
G_RLF.defaults.global.historyLimit = 100
G_RLF.defaults.global.enablePartyLoot = false
G_RLF.defaults.global.itemLootFeed = true
G_RLF.defaults.global.itemQualityFilter = {
	[Enum.ItemQuality.Poor] = true,
	[Enum.ItemQuality.Common] = true,
	[Enum.ItemQuality.Uncommon] = true,
	[Enum.ItemQuality.Rare] = true,
	[Enum.ItemQuality.Epic] = true,
	[Enum.ItemQuality.Legendary] = true,
	[Enum.ItemQuality.Artifact] = true,
	[Enum.ItemQuality.Heirloom] = true,
}
G_RLF.defaults.global.currencyFeed = true
G_RLF.defaults.global.tooltip = true
G_RLF.defaults.global.tooltipOnShift = false
G_RLF.defaults.global.moneyFeed = true
G_RLF.defaults.global.xpFeed = true
G_RLF.defaults.global.repFeed = true

G_RLF.options.args.features = {
	type = "group",
	handler = Features,
	name = G_RLF.L["Features"],
	desc = G_RLF.L["FeaturesDesc"],
	order = 4,
	args = {
		enableLootHistory = {
			type = "toggle",
			name = G_RLF.L["Enable Loot History"],
			desc = G_RLF.L["EnableLootHistoryDesc"],
			width = "double",
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
			order = 1.1,
		},
		enableSecondaryRowText = {
			type = "toggle",
			name = G_RLF.L["Enable Secondary Row Text"],
			desc = G_RLF.L["EnableSecondaryRowTextDesc"],
			width = "double",
			get = "GetSecondaryRowText",
			set = "SetSecondaryRowText",
			order = 1.2,
		},
		enablePartyLoot = {
			type = "toggle",
			name = G_RLF.L["Enable Party Loot in Feed"],
			desc = G_RLF.L["EnablePartyLootDesc"],
			width = "double",
			get = "GetPartyLootStatus",
			set = "SetPartyLootStatus",
			order = 1.3,
		},
		enableItemLoot = {
			type = "toggle",
			name = G_RLF.L["Enable Item Loot in Feed"],
			desc = G_RLF.L["EnableItemLootDesc"],
			width = "double",
			get = "GetItemLootStatus",
			set = "SetItemLootStatus",
			order = 2,
		},
		itemLootConfig = {
			type = "group",
			disabled = "ItemLootDisabled",
			name = G_RLF.L["Item Loot Config"],
			inline = true,
			order = 2.1,
			args = {
				itemQualityFilter = {
					type = "multiselect",
					name = G_RLF.L["Item Quality Filter"],
					desc = G_RLF.L["ItemQualityFilterDesc"],
					values = {
						[Enum.ItemQuality.Poor] = G_RLF.L["Poor"],
						[Enum.ItemQuality.Common] = G_RLF.L["Common"],
						[Enum.ItemQuality.Uncommon] = G_RLF.L["Uncommon"],
						[Enum.ItemQuality.Rare] = G_RLF.L["Rare"],
						[Enum.ItemQuality.Epic] = G_RLF.L["Epic"],
						[Enum.ItemQuality.Legendary] = G_RLF.L["Legendary"],
						[Enum.ItemQuality.Artifact] = G_RLF.L["Artifact"],
						[Enum.ItemQuality.Heirloom] = G_RLF.L["Heirloom"],
					},
					width = "double",
					get = "GetItemQualityFilter",
					set = "SetItemQualityFilter",
					order = 1,
				},
			},
		},
		enableCurrency = {
			type = "toggle",
			name = G_RLF.L["Enable Currency in Feed"],
			desc = G_RLF.L["EnableCurrencyDesc"],
			width = "double",
			get = "GetCurrencyStatus",
			set = "SetCurrencyStatus",
			order = 2.2,
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
			order = 4,
			args = {
				onlyShiftOnEnter = {
					type = "toggle",
					disabled = "TooltipShiftDisabled",
					name = G_RLF.L["Show only when SHIFT is held"],
					desc = G_RLF.L["OnlyShiftOnEnterDesc"],
					width = "double",
					get = "GetTooltipShiftStatus",
					set = "SetTooltipShiftStatus",
					order = 1,
				},
			},
		},
		enableMoney = {
			type = "toggle",
			name = G_RLF.L["Enable Money in Feed"],
			desc = G_RLF.L["EnableMoneyDesc"],
			width = "double",
			get = "GetMoneyStatus",
			set = "SetMoneyStatus",
			order = 5,
		},
		enableXp = {
			type = "toggle",
			name = G_RLF.L["Enable Experience in Feed"],
			desc = G_RLF.L["EnableXPDesc"],
			width = "double",
			get = "GetXPStatus",
			set = "SetXPStatus",
			order = 6,
		},
		enableRep = {
			type = "toggle",
			name = G_RLF.L["Enable Reputation in Feed"],
			desc = G_RLF.L["EnableRepDesc"],
			width = "double",
			get = "GetRepStatus",
			set = "SetRepStatus",
			order = 7,
		},
	},
}

function Features:GetLootHistoryStatus()
	return G_RLF.db.global.lootHistoryEnabled
end

function Features:SetLootHistoryStatus(info, value)
	G_RLF.db.global.lootHistoryEnabled = value
	LootDisplayFrame:UpdateTabVisibility()
end

function Features:LootHistoryDisabled()
	return not G_RLF.db.global.lootHistoryEnabled
end

function Features:GetLootHistorySize()
	return G_RLF.db.global.historyLimit
end

function Features:SetLootHistorySize(info, value)
	G_RLF.db.global.historyLimit = value
end

function Features:GetSecondaryRowText(info, value)
	return G_RLF.db.global.enabledSecondaryRowText
end

function Features:SetSecondaryRowText(info, value)
	G_RLF.db.global.enabledSecondaryRowText = value
	G_RLF.LootDisplay:UpdateRowStyles()
end

function Features:SecondaryTextDisabled()
	return not G_RLF.db.global.enabledSecondaryRowText
end

function Features:GetPartyLootStatus()
	return G_RLF.db.global.enablePartyLoot
end

function Features:SetPartyLootStatus(info, value)
	G_RLF.db.global.enablePartyLoot = value
end

function Features:GetItemLootStatus(info, value)
	return G_RLF.db.global.itemLootFeed
end

function Features:SetItemLootStatus(info, value)
	G_RLF.db.global.itemLootFeed = value
	if value then
		G_RLF.RLF:EnableModule("ItemLoot")
	else
		G_RLF.RLF:DisableModule("ItemLoot")
	end
end

function Features:ItemLootDisabled()
	return not G_RLF.db.global.itemLootFeed
end

function Features:GetItemQualityFilter(info, quality)
	return G_RLF.db.global.itemQualityFilter[quality]
end

function Features:SetItemQualityFilter(info, quality, value)
	G_RLF.db.global.itemQualityFilter[quality] = value
end

function Features:GetCurrencyStatus(info, value)
	return G_RLF.db.global.currencyFeed
end

function Features:SetCurrencyStatus(info, value)
	G_RLF.db.global.currencyFeed = value
	if value then
		G_RLF.RLF:EnableModule("Currency")
	else
		G_RLF.RLF:DisableModule("Currency")
	end
end

function Features:GetTooltipStatus(info, value)
	return G_RLF.db.global.tooltip
end

function Features:SetTooltipStatus(info, value)
	G_RLF.db.global.tooltip = value
end

function Features:TooltipShiftDisabled()
	return not G_RLF.db.global.tooltip
end

function Features:GetTooltipShiftStatus(info, value)
	return G_RLF.db.global.tooltipOnShift
end

function Features:SetTooltipShiftStatus(info, value)
	G_RLF.db.global.tooltipOnShift = value
end

function Features:GetMoneyStatus(info, value)
	return G_RLF.db.global.moneyFeed
end

function Features:SetMoneyStatus(info, value)
	G_RLF.db.global.moneyFeed = value
	if value then
		G_RLF.RLF:EnableModule("Money")
	else
		G_RLF.RLF:DisableModule("Money")
	end
end

function Features:GetXPStatus(info, value)
	return G_RLF.db.global.xpFeed
end

function Features:SetXPStatus(info, value)
	G_RLF.db.global.xpFeed = value
	if value then
		G_RLF.RLF:EnableModule("Experience")
	else
		G_RLF.RLF:DisableModule("Experience")
	end
end

function Features:GetRepStatus(info, value)
	return G_RLF.db.global.repFeed
end

function Features:SetRepStatus(info, value)
	G_RLF.db.global.repFeed = value
	if value then
		G_RLF.RLF:EnableModule("Reputation")
	else
		G_RLF.RLF:DisableModule("Reputation")
	end
end
