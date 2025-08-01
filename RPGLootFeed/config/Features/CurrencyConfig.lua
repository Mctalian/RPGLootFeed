---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

local CurrencyConfig = {}

---@class RLF_DBGlobal
G_RLF.defaults.global = G_RLF.defaults.global or {}

---@class RLF_ConfigCurrency
G_RLF.defaults.global.currency = {
	enabled = true,
	currencyTotalTextEnabled = true,
	currencyTotalTextColor = { 0.737, 0.737, 0.737, 1 },
	currencyTotalTextWrapChar = G_RLF.WrapCharEnum.PARENTHESIS,
	lowerThreshold = 0.7,
	upperThreshold = 0.9,
	lowestColor = { 1, 1, 1, 1 },
	midColor = { 1, 0.608, 0, 1 },
	upperColor = { 1, 0, 0, 1 },
	enableIcon = true,
}

G_RLF.options.args.features.args.currencyConfig = {
	type = "group",
	handler = CurrencyConfig,
	name = G_RLF.L["Currency Config"],
	order = G_RLF.mainFeatureOrder.Currency,
	disabled = function()
		return GetExpansionLevel() < G_RLF.Expansion.WOTLK
	end,
	args = {
		enableCurrency = {
			type = "toggle",
			name = G_RLF.L["Enable Currency in Feed"],
			desc = G_RLF.L["EnableCurrencyDesc"],
			width = "double",
			get = function()
				return G_RLF.db.global.currency.enabled
			end,
			set = function(_, value)
				G_RLF.db.global.currency.enabled = value
				if value then
					G_RLF.RLF:EnableModule(G_RLF.FeatureModule.Currency)
				else
					G_RLF.RLF:DisableModule(G_RLF.FeatureModule.Currency)
				end
			end,
			disabled = function()
				return GetExpansionLevel() < G_RLF.Expansion.WOTLK
			end,
			order = 1,
		},
		currencyOptions = {
			type = "group",
			inline = true,
			name = G_RLF.L["Currency Options"],
			disabled = function()
				return not G_RLF.db.global.currency.enabled
			end,
			order = 2,
			args = {
				showIcon = {
					type = "toggle",
					name = G_RLF.L["Show Currency Icon"],
					desc = G_RLF.L["ShowCurrencyIconDesc"],
					width = "double",
					disabled = function()
						return G_RLF.db.global.misc.hideAllIcons
					end,
					get = function()
						return G_RLF.db.global.currency.enableIcon
					end,
					set = function(_, value)
						G_RLF.db.global.currency.enableIcon = value
					end,
					order = 0.5,
				},
				totalTextOptions = {
					type = "group",
					inline = true,
					name = G_RLF.L["Currency Total Text Options"],
					order = 1,
					args = {
						currencyTotalTextEnabled = {
							type = "toggle",
							name = G_RLF.L["Enable Currency Total Text"],
							desc = G_RLF.L["EnableCurrencyTotalTextDesc"],
							width = "double",
							get = function()
								return G_RLF.db.global.currency.currencyTotalTextEnabled
							end,
							set = function(_, value)
								G_RLF.db.global.currency.currencyTotalTextEnabled = value
							end,
							order = 1,
						},
						currencyTotalTextColor = {
							type = "color",
							name = G_RLF.L["Currency Total Text Color"],
							desc = G_RLF.L["CurrencyTotalTextColorDesc"],
							hasAlpha = true,
							disabled = function()
								return not G_RLF.db.global.currency.currencyTotalTextEnabled
							end,
							width = "double",
							get = function()
								return unpack(G_RLF.db.global.currency.currencyTotalTextColor)
							end,
							set = function(_, r, g, b, a)
								G_RLF.db.global.currency.currencyTotalTextColor = { r, g, b, a }
							end,
							order = 2,
						},
						currencyTotalTextWrapChar = {
							type = "select",
							name = G_RLF.L["Currency Total Text Wrap Character"],
							desc = G_RLF.L["CurrencyTotalTextWrapCharDesc"],
							disabled = function()
								return not G_RLF.db.global.currency.currencyTotalTextEnabled
							end,
							values = G_RLF.WrapCharOptions,
							get = function()
								return G_RLF.db.global.currency.currencyTotalTextWrapChar
							end,
							set = function(_, value)
								G_RLF.db.global.currency.currencyTotalTextWrapChar = value
							end,
							order = 3,
						},
					},
				},
			},
		},
	},
}
