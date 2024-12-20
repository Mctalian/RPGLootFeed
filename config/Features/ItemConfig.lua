local addonName, G_RLF = ...

local ItemConfig = {}

local PricesEnum = G_RLF.PricesEnum

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
	disabled = "ItemLootDisabled",
	name = G_RLF.L["Item Loot Config"],
	order = 2.1,
	args = {
		enableItemLoot = {
			type = "toggle",
			name = G_RLF.L["Enable Item Loot in Feed"],
			desc = G_RLF.L["EnableItemLootDesc"],
			width = "double",
			get = "GetItemLootStatus",
			set = "SetItemLootStatus",
			order = 1,
		},
		enablePartyLoot = {
			type = "toggle",
			name = G_RLF.L["Enable Party Loot in Feed"],
			desc = G_RLF.L["EnablePartyLootDesc"],
			width = "double",
			get = "GetPartyLootStatus",
			set = "SetPartyLootStatus",
			order = 1.1,
		},
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
							G_RLF.db.global.auctionHouseSource = G_RLF.AuctionIntegrations.nilIntegration:ToString()
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
							G_RLF.db.global.auctionHouseSource = G_RLF.AuctionIntegrations.nilIntegration:ToString()
						end
						return G_RLF.db.global.auctionHouseSource
					end,
					set = function(info, value)
						G_RLF.db.global.auctionHouseSource = value
						if value ~= G_RLF.AuctionIntegrations.nilIntegration:ToString() then
							G_RLF.AuctionIntegrations.activeIntegration =
								G_RLF.AuctionIntegrations.activeIntegrations[value]
						else
							G_RLF.AuctionIntegrations.activeIntegration = G_RLF.AuctionIntegrations.nilIntegration
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
}

function ItemConfig:GetItemLootStatus(info, value)
	return G_RLF.db.global.itemLootFeed
end

function ItemConfig:SetItemLootStatus(info, value)
	G_RLF.db.global.itemLootFeed = value
	if value then
		G_RLF.RLF:EnableModule("ItemLoot")
	else
		G_RLF.RLF:DisableModule("ItemLoot")
	end
end

function ItemConfig:GetPartyLootStatus()
	return G_RLF.db.global.enablePartyLoot
end

function ItemConfig:SetPartyLootStatus(info, value)
	G_RLF.db.global.enablePartyLoot = value
end

function ItemConfig:ItemLootDisabled()
	return not G_RLF.db.global.itemLootFeed
end

function ItemConfig:GetItemQualityFilter(info, quality)
	return G_RLF.db.global.itemQualityFilter[quality]
end

function ItemConfig:SetItemQualityFilter(info, quality, value)
	G_RLF.db.global.itemQualityFilter[quality] = value
end
