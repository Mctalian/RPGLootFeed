local addonName, G_RLF = ...

local PartyLootConfig = {}

G_RLF.defaults.global.partyLoot = {
	enabled = false,
	itemQualityFilter = {
		[G_RLF.ItemQualEnum.Poor] = true,
		[G_RLF.ItemQualEnum.Common] = true,
		[G_RLF.ItemQualEnum.Uncommon] = true,
		[G_RLF.ItemQualEnum.Rare] = true,
		[G_RLF.ItemQualEnum.Epic] = true,
		[G_RLF.ItemQualEnum.Legendary] = true,
		[G_RLF.ItemQualEnum.Artifact] = true,
		[G_RLF.ItemQualEnum.Heirloom] = true,
	},
	onlyEpicAndAboveInRaid = true,
	onlyEpicAndAboveInInstance = true,
}

G_RLF.options.args.features.args.partyLootConfig = {
	type = "group",
	handler = PartyLootConfig,
	name = G_RLF.L["Party Loot Config"],
	order = G_RLF.mainFeatureOrder.PartyLoot,
	args = {
		enablePartyLoot = {
			type = "toggle",
			name = G_RLF.L["Enable Party Loot in Feed"],
			desc = G_RLF.L["EnablePartyLootDesc"],
			width = "double",
			get = function()
				return G_RLF.db.global.partyLoot.enabled
			end,
			set = function(_, value)
				G_RLF.db.global.partyLoot.enabled = value
			end,
			order = 1,
		},
		partyLootOptions = {
			type = "group",
			inline = true,
			name = G_RLF.L["Party Loot Options"],
			disabled = function()
				return not G_RLF.db.global.partyLoot.enabled
			end,
			order = 2,
			args = {
				itemQualityFilter = {
					type = "multiselect",
					name = G_RLF.L["Party Item Quality Filter"],
					desc = G_RLF.L["PartyItemQualityFilterDesc"],
					values = {
						[G_RLF.ItemQualEnum.Poor] = G_RLF.L["Poor"],
						[G_RLF.ItemQualEnum.Common] = G_RLF.L["Common"],
						[G_RLF.ItemQualEnum.Uncommon] = G_RLF.L["Uncommon"],
						[G_RLF.ItemQualEnum.Rare] = G_RLF.L["Rare"],
						[G_RLF.ItemQualEnum.Epic] = G_RLF.L["Epic"],
						[G_RLF.ItemQualEnum.Legendary] = G_RLF.L["Legendary"],
						[G_RLF.ItemQualEnum.Artifact] = G_RLF.L["Artifact"],
						[G_RLF.ItemQualEnum.Heirloom] = G_RLF.L["Heirloom"],
					},
					get = function(_, key)
						return G_RLF.db.global.partyLoot.itemQualityFilter[key]
					end,
					set = function(_, key, value)
						G_RLF.db.global.partyLoot.itemQualityFilter[key] = value
					end,
					order = 1,
				},
				onlyEpicAndAboveInRaid = {
					type = "toggle",
					name = G_RLF.L["Only Epic and Above in Raid"],
					desc = G_RLF.L["OnlyEpicAndAboveInRaidDesc"],
					width = "double",
					get = function()
						return G_RLF.db.global.partyLoot.onlyEpicAndAboveInRaid
					end,
					set = function(_, value)
						G_RLF.db.global.partyLoot.onlyEpicAndAboveInRaid = value
						G_RLF.RLF:GetModule("ItemLoot"):SetPartyLootFilters()
					end,
					order = 2,
				},
				onlyEpicAndAboveInInstance = {
					type = "toggle",
					name = G_RLF.L["Only Epic and Above in Instance"],
					desc = G_RLF.L["OnlyEpicAndAboveInInstanceDesc"],
					width = "double",
					get = function()
						return G_RLF.db.global.partyLoot.onlyEpicAndAboveInInstance
					end,
					set = function(_, value)
						G_RLF.db.global.partyLoot.onlyEpicAndAboveInInstance = value
						G_RLF.RLF:GetModule("ItemLoot"):SetPartyLootFilters()
					end,
					order = 3,
				},
			},
		},
	},
}
