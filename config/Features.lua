local Features = {}

G_RLF.defaults.global.itemLootFeed = true
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
        enableItemLoot = {
            type = "toggle",
            name = G_RLF.L["Enable Item Loot in Feed"],
            desc = G_RLF.L["EnableItemLootDesc"],
            width = "double",
            get = "GetItemLootStatus",
            set = "SetItemLootStatus",
            order = 1
        },
        enableCurrency = {
            type = "toggle",
            name = G_RLF.L["Enable Currency in Feed"],
            desc = G_RLF.L["EnableCurrencyDesc"],
            width = "double",
            get = "GetCurrencyStatus",
            set = "SetCurrencyStatus",
            order = 2
        },
        enableTooltip = {
            type = "toggle",
            name = G_RLF.L["Enable Item/Currency Tooltips"],
            desc = G_RLF.L["EnableTooltipsDesc"],
            width = "double",
            get = "GetTooltipStatus",
            set = "SetTooltipStatus",
            order = 3
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
                    order = 1
                }
            }
        },
        enableMoney = {
            type = "toggle",
            name = G_RLF.L["Enable Money in Feed"],
            desc = G_RLF.L["EnableMoneyDesc"],
            width = "double",
            get = "GetMoneyStatus",
            set = "SetMoneyStatus",
            order = 5
        },
        enableXp = {
            type = "toggle",
            name = G_RLF.L["Enable Experience in Feed"],
            desc = G_RLF.L["EnableXPDesc"],
            width = "double",
            get = "GetXPStatus",
            set = "SetXPStatus",
            order = 6
        },
        enableRep = {
            type = "toggle",
            name = G_RLF.L["Enable Reputation in Feed"],
            desc = G_RLF.L["EnableRepDesc"],
            width = "double",
            get = "GetRepStatus",
            set = "SetRepStatus",
            order = 7
        }
    }
}

function Features:GetItemLootStatus(info, value)
    return G_RLF.db.global.itemLootFeed
end

function Features:SetItemLootStatus(info, value)
    G_RLF.db.global.itemLootFeed = value
end

function Features:GetCurrencyStatus(info, value)
    return G_RLF.db.global.currencyFeed
end

function Features:SetCurrencyStatus(info, value)
    G_RLF.db.global.currencyFeed = value
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
end

function Features:GetXPStatus(info, value)
  return G_RLF.db.global.xpFeed
end

function Features:SetXPStatus(info, value)
  G_RLF.db.global.xpFeed = value
end

function Features:GetRepStatus(info, value)
    return G_RLF.db.global.repFeed
  end

function Features:SetRepStatus(info, value)
    G_RLF.db.global.repFeed = value
end
