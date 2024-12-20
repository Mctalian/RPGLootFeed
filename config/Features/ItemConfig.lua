local addonName, G_RLF = ...

local ItemConfig = {}

local PricesEnum = G_RLF.PricesEnum

G_RLF.defaults.global.itemQualityFilter = {
	[G_RLF.ItemQualEnum.Poor] = true,
	[G_RLF.ItemQualEnum.Common] = true,
	[G_RLF.ItemQualEnum.Uncommon] = true,
	[G_RLF.ItemQualEnum.Rare] = true,
	[G_RLF.ItemQualEnum.Epic] = true,
	[G_RLF.ItemQualEnum.Legendary] = true,
	[G_RLF.ItemQualEnum.Artifact] = true,
	[G_RLF.ItemQualEnum.Heirloom] = true,
}
G_RLF.defaults.global.auctionHouseSource = G_RLF.L["None"]
G_RLF.defaults.global.pricesForSellableItems = PricesEnum.Vendor
G_RLF.defaults.global.itemHighlights = {
	boe = false,
	bop = false,
	quest = false,
	transmog = false,
	mounts = true,
	legendary = true,
	betterThanEquipped = true,
}

G_RLF.options.args.features.args.itemLootConfig = {
	type = "group",
	handler = ItemConfig,
	name = G_RLF.L["Item Loot Config"],
	order = 2.1,
	args = {
		enableItemLoot = {
			type = "toggle",
			name = G_RLF.L["Enable Item Loot in Feed"],
			desc = G_RLF.L["EnableItemLootDesc"],
			width = "double",
			get = function()
				return G_RLF.db.global.itemLootFeed
			end,
			set = function(_, value)
				G_RLF.db.global.itemLootFeed = value
				if value then
					G_RLF.RLF:EnableModule("ItemLoot")
				else
					G_RLF.RLF:DisableModule("ItemLoot")
				end
			end,
			order = 1,
		},
		itemLootOptions = {
			type = "group",
			inline = true,
			name = G_RLF.L["Item Loot Options"],
			disabled = function()
				return not G_RLF.db.global.itemLootFeed
			end,
			order = 1.1,
			args = {
				itemSecondaryTextOptions = {
					type = "group",
					name = G_RLF.L["Item Secondary Text Options"],
					inline = true,
					order = 1.2,
					args = {
						pricesForSellableItems = {
							type = "select",
							name = G_RLF.L["Prices for Sellable Items"],
							desc = G_RLF.L["PricesForSellableItemsDesc"],
							values = function()
								local values = {
									[PricesEnum.None] = G_RLF.L["None"],
									[PricesEnum.Vendor] = G_RLF.L["Vendor Price"],
								}
								if G_RLF.AuctionIntegrations.numActiveIntegrations > 0 then
									values[PricesEnum.AH] = G_RLF.L["Auction Price"]
								end
								return values
							end,
							sorting = {
								PricesEnum.None,
								PricesEnum.Vendor,
								PricesEnum.AH,
							},
							get = function(info)
								if
									G_RLF.db.global.pricesForSellableItems == PricesEnum.AH
									and G_RLF.AuctionIntegrations.numActiveIntegrations == 0
								then
									G_RLF.db.global.pricesForSellableItems = PricesEnum.Vendor
								end
								return G_RLF.db.global.pricesForSellableItems
							end,
							set = function(info, value)
								G_RLF.db.global.pricesForSellableItems = value
							end,
							order = 1,
						},
						auctionHouseSource = {
							type = "select",
							name = G_RLF.L["Auction House Source"],
							desc = G_RLF.L["AuctionHouseSourceDesc"],
							values = function()
								local values = {}
								values[G_RLF.AuctionIntegrations.nilIntegration:ToString()] =
									G_RLF.AuctionIntegrations.nilIntegration:ToString()

								local activeIntegrations = G_RLF.AuctionIntegrations.activeIntegrations
								local numActiveIntegrations = G_RLF.AuctionIntegrations.numActiveIntegrations
								if activeIntegrations and numActiveIntegrations >= 1 then
									for k, _ in pairs(activeIntegrations) do
										values[k] = k
									end
								end
								return values
							end,
							sorting = function()
								local values = {}
								values[1] = G_RLF.AuctionIntegrations.nilIntegration:ToString()

								local activeIntegrations = G_RLF.AuctionIntegrations.activeIntegrations
								local numActiveIntegrations = G_RLF.AuctionIntegrations.numActiveIntegrations
								if activeIntegrations and numActiveIntegrations >= 1 then
									local i = 2
									for k, _ in pairs(activeIntegrations) do
										values[i] = k
										i = i + 1
									end
								end
								return values
							end,
							hidden = function()
								local activeIntegrations = G_RLF.AuctionIntegrations.activeIntegrations
								local numActiveIntegrations = G_RLF.AuctionIntegrations.numActiveIntegrations
								local hide = not activeIntegrations or numActiveIntegrations == 0
								if hide then
									G_RLF.db.global.auctionHouseSource =
										G_RLF.AuctionIntegrations.nilIntegration:ToString()
								end
								return hide
							end,
							get = function(info)
								local activeIntegrations = G_RLF.AuctionIntegrations.activeIntegrations
								local numActiveIntegrations = G_RLF.AuctionIntegrations.numActiveIntegrations
								if
									not activeIntegrations
									or not activeIntegrations[G_RLF.db.global.auctionHouseSource]
									or numActiveIntegrations == 0
								then
									G_RLF.db.global.auctionHouseSource =
										G_RLF.AuctionIntegrations.nilIntegration:ToString()
								end
								return G_RLF.db.global.auctionHouseSource
							end,
							set = function(info, value)
								G_RLF.db.global.auctionHouseSource = value
								if value ~= G_RLF.AuctionIntegrations.nilIntegration:ToString() then
									G_RLF.AuctionIntegrations.activeIntegration =
										G_RLF.AuctionIntegrations.activeIntegrations[value]
								else
									G_RLF.AuctionIntegrations.activeIntegration =
										G_RLF.AuctionIntegrations.nilIntegration
								end
							end,
							order = 2,
						},
					},
				},
				itemQualityFilter = {
					type = "multiselect",
					name = G_RLF.L["Item Quality Filter"],
					desc = G_RLF.L["ItemQualityFilterDesc"],
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
					width = "double",
					get = function(info, quality)
						return G_RLF.db.global.itemQualityFilter[quality]
					end,
					set = function(info, quality, value)
						G_RLF.db.global.itemQualityFilter[quality] = value
					end,
					order = 2,
				},
				itemHighlights = {
					type = "group",
					name = G_RLF.L["Item Highlights"],
					desc = G_RLF.L["ItemHighlightsDesc"],
					inline = true,
					order = 3,
					args = {
						highlightMount = {
							type = "toggle",
							name = G_RLF.L["Highlight Mounts"],
							desc = G_RLF.L["HighlightMountsDesc"],
							width = "double",
							get = function(info)
								return G_RLF.db.global.itemHighlights.mounts
							end,
							set = function(info, value)
								G_RLF.db.global.itemHighlights.mounts = value
							end,
							order = 1,
						},
						highlightLegendary = {
							type = "toggle",
							name = G_RLF.L["Highlight Legendary Items"],
							desc = G_RLF.L["HighlightLegendaryDesc"],
							width = "double",
							get = function(info)
								return G_RLF.db.global.itemHighlights.legendary
							end,
							set = function(info, value)
								G_RLF.db.global.itemHighlights.legendary = value
							end,
							order = 2,
						},
						highlightBetterThanEquipped = {
							type = "toggle",
							name = G_RLF.L["Highlight Items Better Than Equipped"],
							desc = G_RLF.L["HighlightBetterThanEquippedDesc"],
							width = "double",
							get = function(info)
								return G_RLF.db.global.itemHighlights.betterThanEquipped
							end,
							set = function(info, value)
								G_RLF.db.global.itemHighlights.betterThanEquipped = value
							end,
							order = 3,
						},
						-- highlightBoE = {
						--   type = "toggle",
						--   name = G_RLF.L["Highlight BoE Items"],
						--   desc = G_RLF.L["HighlightBoEDesc"],
						--   width = "double",
						--   get = function(info) return G_RLF.db.global.itemHighlights.boe end,
						--   set = function(info, value) G_RLF.db.global.itemHighlights.boe = value end,
						--   order = 3,
						-- },
						-- highlightBoP = {
						--   type = "toggle",
						--   name = G_RLF.L["Highlight BoP Items"],
						--   desc = G_RLF.L["HighlightBoPDesc"],
						--   width = "double",
						--   get = function(info) return G_RLF.db.global.itemHighlights.bop end,
						--   set = function(info, value) G_RLF.db.global.itemHighlights.bop = value end,
						--   order = 4,
						-- },
						-- highlightQuest = {
						--   type = "toggle",
						--   name = G_RLF.L["Highlight Quest Items"],
						--   desc = G_RLF.L["HighlightQuestDesc"],
						--   width = "double",
						--   get = function(info) return G_RLF.db.global.itemHighlights.quest end,
						--   set = function(info, value) G_RLF.db.global.itemHighlights.quest = value end,
						--   order = 5,
						-- },
						-- highlightTransmog = {
						--   type = "toggle",
						--   name = G_RLF.L["Highlight Transmog Items"],
						--   desc = G_RLF.L["HighlightTransmogDesc"],
						--   width = "double",
						--   get = function(info) return G_RLF.db.global.itemHighlights.transmog end,
						--   set = function(info, value) G_RLF.db.global.itemHighlights.transmog = value end,
						--   order = 6,
						-- },
					},
				},
			},
		},
	},
}
