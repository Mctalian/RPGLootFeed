---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

local MoneyConfig = {}

local lsm = G_RLF.lsm

---@class RLF_DBGlobal
G_RLF.defaults.global = G_RLF.defaults.global or {}

---@class RLF_ConfigMoney
G_RLF.defaults.global.money = {
	enabled = true,
	showMoneyTotal = true,
	moneyTotalColor = { 0.333, 0.333, 1.0, 1.0 },
	moneyTextWrapChar = G_RLF.WrapCharEnum.BAR,
	abbreviateTotal = true,
	accountantMode = false,
	onlyIncome = false,
	overrideMoneyLootSound = false,
	moneyLootSound = "",
}

G_RLF.options.args.features.args.moneyConfig = {
	type = "group",
	handler = MoneyConfig,
	name = G_RLF.L["Money Config"],
	order = G_RLF.mainFeatureOrder.Money,
	args = {
		enableMoney = {
			type = "toggle",
			name = G_RLF.L["Enable Money in Feed"],
			desc = G_RLF.L["EnableMoneyDesc"],
			width = "double",
			get = function()
				return G_RLF.db.global.money.enabled
			end,
			set = function(_, value)
				G_RLF.db.global.money.enabled = value
				if value then
					G_RLF.RLF:EnableModule("Money")
				else
					G_RLF.RLF:DisableModule("Money")
				end
			end,
			order = 1,
		},
		moneyOptions = {
			type = "group",
			inline = true,
			name = G_RLF.L["Money Options"],
			disabled = function()
				return not G_RLF.db.global.money.enabled
			end,
			order = 1.1,
			args = {
				-- TODO: Money total is in secondary text row, unlike other total counters
				-- Will need to make Money consistent with other features to have the same
				-- options for total counters.

				moneyTotalOptions = {
					type = "group",
					inline = true,
					name = G_RLF.L["Money Total Options"],
					order = 1,
					args = {
						showMoneyTotal = {
							type = "toggle",
							name = G_RLF.L["Show Money Total"],
							desc = G_RLF.L["ShowMoneyTotalDesc"],
							width = "double",
							get = function()
								return G_RLF.db.global.money.showMoneyTotal
							end,
							set = function(_, value)
								G_RLF.db.global.money.showMoneyTotal = value
							end,
						},
						-- moneyTotalColor = {
						--   type = "color",
						--   name = G_RLF.L["Money Total Color"],
						--   desc = G_RLF.L["MoneyTotalColorDesc"],
						--   disabled = function()
						--     return not G_RLF.db.global.money.showMoneyTotal
						--   end,
						--   hasAlpha = true,
						--   get = function()
						--     return unpack(G_RLF.db.global.money.moneyTotalColor)
						--   end,
						--   set = function(_, r, g, b, a)
						--     G_RLF.db.global.money.moneyTotalColor = { r, g, b, a }
						--   end,
						-- },
						-- moneyTextWrapChar = {
						--   type = "select",
						--   name = G_RLF.L["Money Text Wrap Char"],
						--   desc = G_RLF.L["MoneyTextWrapCharDesc"],
						--   disabled = function()
						--     return not G_RLF.db.global.money.showMoneyTotal
						--   end,
						--   values = G_RLF.WrapCharOptions,
						--   get = function()
						--     return G_RLF.db.global.money.moneyTextWrapChar
						--   end,
						--   set = function(_, value)
						--     G_RLF.db.global.money.moneyTextWrapChar = value
						--   end,
						-- },
						abbreviateTotal = {
							type = "toggle",
							name = G_RLF.L["Abbreviate Total"],
							desc = G_RLF.L["AbbreviateTotalDesc"],
							disabled = function()
								return not G_RLF.db.global.money.showMoneyTotal
							end,
							width = "double",
							get = function()
								return G_RLF.db.global.money.abbreviateTotal
							end,
							set = function(_, value)
								G_RLF.db.global.money.abbreviateTotal = value
							end,
						},
					},
				},
				onlyIncome = {
					type = "toggle",
					name = G_RLF.L["Only Income"],
					desc = G_RLF.L["OnlyIncomeDesc"],
					width = "double",
					get = function()
						return G_RLF.db.global.money.onlyIncome
					end,
					set = function(_, value)
						G_RLF.db.global.money.onlyIncome = value
					end,
					order = 2,
				},
				accountantMode = {
					type = "toggle",
					name = G_RLF.L["Accountant Mode"],
					desc = G_RLF.L["AccountantModeDesc"],
					width = "double",
					disabled = function()
						return G_RLF.db.global.money.onlyIncome
					end,
					get = function()
						return G_RLF.db.global.money.accountantMode
					end,
					set = function(_, value)
						G_RLF.db.global.money.accountantMode = value
					end,
					order = 3,
				},
				overrideMoneyLootSound = {
					type = "toggle",
					name = G_RLF.L["Override Money Loot Sound"],
					desc = G_RLF.L["OverrideMoneyLootSoundDesc"],
					get = function()
						return G_RLF.db.global.money.overrideMoneyLootSound
					end,
					set = function(_, value)
						G_RLF.db.global.money.overrideMoneyLootSound = value
						MoneyConfig:OverrideSound()
					end,
					width = "double",
					order = 4,
				},
				moneyLootSound = {
					type = "select",
					name = G_RLF.L["Money Loot Sound"],
					desc = G_RLF.L["MoneyLootSoundDesc"],
					values = function()
						local sounds = {}
						for k, v in pairs(lsm:HashTable(lsm.MediaType.SOUND)) do
							sounds[v] = k
						end
						return sounds
					end,
					get = function()
						return G_RLF.db.global.money.moneyLootSound
					end,
					set = function(_, value)
						G_RLF.db.global.money.moneyLootSound = value
						MoneyConfig:OverrideSound()
					end,
					disabled = function()
						return not G_RLF.db.global.money.overrideMoneyLootSound
					end,
					width = "full",
					order = 5,
				},
			},
		},
	},
}

function MoneyConfig:OverrideSound()
	if G_RLF.db.global.money.overrideMoneyLootSound then
		MuteSoundFile(G_RLF.GameSounds.LOOT_SMALL_COIN)
	else
		UnmuteSoundFile(G_RLF.GameSounds.LOOT_SMALL_COIN)
	end
end
