local Features = {}

G_RLF.defaults.global.itemLootFeed = true
G_RLF.defaults.global.currencyFeed = true
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
        enableMoney = {
            type = "toggle",
            name = G_RLF.L["Enable Money in Feed"],
            desc = G_RLF.L["EnableMoneyDesc"],
            width = "double",
            get = "GetMoneyStatus",
            set = "SetMoneyStatus",
            order = 3
        },
        enableXp = {
            type = "toggle",
            name = G_RLF.L["Enable Experience in Feed"],
            desc = G_RLF.L["EnableXPDesc"],
            width = "double",
            get = "GetXPStatus",
            set = "SetXPStatus",
            order = 4
        },
        enableRep = {
            type = "toggle",
            name = G_RLF.L["Enable Reputation in Feed"],
            desc = G_RLF.L["EnableRepDesc"],
            width = "double",
            get = "GetRepStatus",
            set = "SetRepStatus",
            order = 4
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
