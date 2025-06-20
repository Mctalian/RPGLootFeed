---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

---@enum G_RLF.Expansion
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

---@enum G_RLF.DisableBossBanner
G_RLF.DisableBossBanner = {
	ENABLED = 0,
	FULLY_DISABLE = 1,
	DISABLE_LOOT = 2,
	DISABLE_MY_LOOT = 3,
	DISABLE_GROUP_LOOT = 4,
}

---@enum G_RLF.FontFlags
G_RLF.FontFlags = {
	NONE = "",
	OUTLINE = "OUTLINE",
	THICKOUTLINE = "THICKOUTLINE",
	MONOCHROME = "MONOCHROME",
}

---@enum G_RLF.ItemQualEnum
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

---@enum G_RLF.LogEventSource
G_RLF.LogEventSource = {
	ADDON = addonName,
	WOWEVENT = "WOWEVENT",
}

---@enum G_RLF.LogLevel
G_RLF.LogLevel = {
	debug = "DEBUG",
	info = "INFO",
	warn = "WARN",
	error = "ERROR",
}

---@enum G_RLF.FeatureModule
G_RLF.FeatureModule = {
	ItemLoot = "ItemLoot",
	PartyLoot = "PartyLoot",
	Currency = "Currency",
	Money = "Money",
	Experience = "Experience",
	Reputation = "Reputation",
	Profession = "Professions",
	TravelPoints = "TravelPoints",
	Transmog = "Transmog",
}

---@enum G_RLF.BlizzModule
G_RLF.BlizzModule = {
	BossBanner = "BossBanner",
	LootToasts = "LootToasts",
	MoneyAlerts = "MoneyAlerts",
}

---@enum G_RLF.SupportModule
G_RLF.SupportModule = {
	Communications = "Communications",
	Logger = "Logger",
	LootDisplay = "LootDisplay",
	Notifications = "Notifications",
	TestMode = "TestMode",
}

---@enum G_RLF.PricesEnum
G_RLF.PricesEnum = {
	None = "none",
	Vendor = "vendor",
	AH = "ah",
	VendorAH = "vendor_ah",
	AHVendor = "ah_vendor",
	Highest = "highest",
}

---@enum G_RLF.EnterAnimationType
G_RLF.EnterAnimationType = {
	NONE = "none",
	FADE = "fade",
	SLIDE = "slide",
}

---@enum G_RLF.ExitAnimationType
G_RLF.ExitAnimationType = {
	NONE = "none",
	FADE = "fade",
}

---@enum G_RLF.SlideDirection
G_RLF.SlideDirection = {
	UP = "up",
	DOWN = "down",
	LEFT = "left",
	RIGHT = "right",
}

---@enum G_RLF.WrapCharEnum
G_RLF.WrapCharEnum = {
	DEFAULT = 0,
	SPACE = 1,
	PARENTHESIS = 2,
	BRACKET = 3,
	BRACE = 4,
	ANGLE = 5,
	BAR = 6,
}

---@enum G_RLF.GameSounds
G_RLF.GameSounds = {
	LOOT_SMALL_COIN = 567428,
}

---@enum G_RLF.DefaultIcons
G_RLF.DefaultIcons = {
	MONEY = "133785",
	REPUTATION = "236681",
	XP = "894556",
	PROFESSION = "133740",
	TRAVELPOINTS = "4635200",
	TRANSMOG = "3889767",
}

---@enum G_RLF.Frames
G_RLF.Frames = {
	MAIN = "RLF_MAIN",
	PARTY = "RLF_PARTY",
}

---@enum G_RLF.TertiaryStats
G_RLF.TertiaryStats = {
	None = 0,
	Speed = 1,
	Leech = 2,
	Avoid = 3,
	Indestructible = 4,
}

G_RLF.NotificationKeys = {
	VERSION = "RLF_NewVersion",
	WELCOME = "RLF_Welcome",
}

G_RLF.CommMessagePrefixes = {
	VERSION = "RLF_Version",
}

G_RLF.CommsMessages = {
	VERSION = G_RLF.CommMessagePrefixes.VERSION .. " %s",
}

G_RLF.VersionCompare = {
	OLDER = -1,
	SAME = 0,
	NEWER = 1,
}
