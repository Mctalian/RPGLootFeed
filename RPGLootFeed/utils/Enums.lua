local addonName, G_RLF = ...

G_RLF.Expansion = {
	CLASSIC = 0,
	TBC = 1,
	WOTLK = 2,
	CATA = 3,
	MOP = 4,
	WOD = 5,
	LEGION = 6,
	BFA = 7,
	SL = 8,
	DF = 9,
	TWW = 10,
}

G_RLF.DisableBossBanner = {
	ENABLED = 0,
	FULLY_DISABLE = 1,
	DISABLE_LOOT = 2,
	DISABLE_MY_LOOT = 3,
	DISABLE_GROUP_LOOT = 4,
}

G_RLF.FontFlags = {
	NONE = "",
	OUTLINE = "OUTLINE",
	THICKOUTLINE = "THICKOUTLINE",
	MONOCHROME = "MONOCHROME",
}

G_RLF.ItemQualEnum = {}

if GetExpansionLevel() >= G_RLF.Expansion.BFA then
	G_RLF.ItemQualEnum = Enum.ItemQuality
else
	G_RLF.ItemQualEnum = {
		Poor = 0,
		Common = 1,
		Uncommon = 2,
		Rare = 3,
		Epic = 4,
		Legendary = 5,
		Artifact = 6,
		Heirloom = 7,
	}
end

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

G_RLF.EnterAnimationType = {
	NONE = "none",
	FADE = "fade",
	SLIDE = "slide",
}

G_RLF.ExitAnimationType = {
	NONE = "none",
	FADE = "fade",
}

G_RLF.SlideDirection = {
	UP = "up",
	DOWN = "down",
	LEFT = "left",
	RIGHT = "right",
}

G_RLF.WrapCharEnum = {
	DEFAULT = 0,
	SPACE = 1,
	PARENTHESIS = 2,
	BRACKET = 3,
	BRACE = 4,
	ANGLE = 5,
	BAR = 6,
}

G_RLF.GameSounds = {
	LOOT_SMALL_COIN = 567428,
}
