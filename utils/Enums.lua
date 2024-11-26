local addonName, G_RLF = ...

G_RLF.DisableBossBanner = {
	ENABLED = 0,
	FULLY_DISABLE = 1,
	DISABLE_LOOT = 2,
	DISABLE_MY_LOOT = 3,
	DISABLE_GROUP_LOOT = 4,
}

G_RLF.LogEventSource = {
	ADDON = addonName,
	WOWEVENT = "WOWEVENT",
}

G_RLF.LogLevel = {
	debug = "DEBUG",
	info = "INFO",
	warn = "WARN",
	error = "ERROR",
}

G_RLF.FeatureModule = {
	ItemLoot = "ItemLoot",
	Currency = "Currency",
	Money = "Money",
	Reputation = "Reputation",
	Experience = "Experience",
	Profession = "Professions",
}

G_RLF.PricesEnum = {
	None = "none",
	Vendor = "vendor",
	AH = "ah",
}

G_RLF.WrapCharEnum = {
	DEFAULT = 0,
	SPACE = 1,
	PARENTHESIS = 2,
	BRACKET = 3,
	BRACE = 4,
	ANGLE = 5,
}
