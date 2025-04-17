---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

G_RLF.standardArmorClassMapping = {
	WARRIOR = Enum.ItemArmorSubclass.Plate,
	PALADIN = Enum.ItemArmorSubclass.Plate,
	DEATHKNIGHT = Enum.ItemArmorSubclass.Plate,
	HUNTER = Enum.ItemArmorSubclass.Mail,
	SHAMAN = Enum.ItemArmorSubclass.Mail,
	EVOKER = Enum.ItemArmorSubclass.Mail,
	ROGUE = Enum.ItemArmorSubclass.Leather,
	DRUID = Enum.ItemArmorSubclass.Leather,
	DEMONHUNTER = Enum.ItemArmorSubclass.Leather,
	MONK = Enum.ItemArmorSubclass.Leather,
	PRIEST = Enum.ItemArmorSubclass.Cloth,
	MAGE = Enum.ItemArmorSubclass.Cloth,
	WARLOCK = Enum.ItemArmorSubclass.Cloth,
}

G_RLF.armorClassMapping = G_RLF.standardArmorClassMapping

G_RLF.cataArmorClassMappingLowLevel = {
	WARRIOR = Enum.ItemArmorSubclass.Mail,
	PALADIN = Enum.ItemArmorSubclass.Mail,
	DEATHKNIGHT = Enum.ItemArmorSubclass.Mail,
	HUNTER = Enum.ItemArmorSubclass.Leather,
	SHAMAN = Enum.ItemArmorSubclass.Leather,
	-- It's really just the ones above
	EVOKER = Enum.ItemArmorSubclass.Mail,
	ROGUE = Enum.ItemArmorSubclass.Leather,
	DRUID = Enum.ItemArmorSubclass.Leather,
	DEMONHUNTER = Enum.ItemArmorSubclass.Leather,
	MONK = Enum.ItemArmorSubclass.Leather,
	PRIEST = Enum.ItemArmorSubclass.Cloth,
	MAGE = Enum.ItemArmorSubclass.Cloth,
	WARLOCK = Enum.ItemArmorSubclass.Cloth,
}

G_RLF.equipSlotMap = {
	INVTYPE_HEAD = 1,
	INVTYPE_NECK = 2,
	INVTYPE_SHOULDER = 3,
	INVTYPE_BODY = 4,
	INVTYPE_CHEST = 5,
	INVTYPE_ROBE = 5,
	INVTYPE_WAIST = 6,
	INVTYPE_LEGS = 7,
	INVTYPE_FEET = 8,
	INVTYPE_WRIST = 9,
	INVTYPE_HAND = 10,
	INVTYPE_FINGER = { 11, 12 }, -- Rings
	INVTYPE_TRINKET = { 13, 14 }, -- Trinkets
	INVTYPE_CLOAK = 15,
	INVTYPE_WEAPON = { 16, 17 }, -- One-handed weapons
	INVTYPE_SHIELD = 17, -- Off-hand
	INVTYPE_2HWEAPON = 16, -- Two-handed weapons
	INVTYPE_WEAPONMAINHAND = 16,
	INVTYPE_WEAPONOFFHAND = 17,
	INVTYPE_HOLDABLE = 17, -- Off-hand items
	INVTYPE_RANGED = 18, -- Bows, guns, wands
	INVTYPE_TABARD = 19,
}

---@type table<G_RLF.TertiaryStats, string>
G_RLF.tertiaryToString = {
	[G_RLF.TertiaryStats.Speed] = _G["ITEM_MOD_CR_SPEED_SHORT"],
	[G_RLF.TertiaryStats.Leech] = _G["ITEM_MOD_CR_LIFESTEAL_SHORT"],
	[G_RLF.TertiaryStats.Avoid] = _G["ITEM_MOD_CR_AVOIDANCE_SHORT"],
	[G_RLF.TertiaryStats.Indestructible] = _G["ITEM_MOD_CR_STURDINESS_SHORT"],
}

G_RLF.WrapCharOptions = {
	[G_RLF.WrapCharEnum.SPACE] = G_RLF.L["Spaces"],
	[G_RLF.WrapCharEnum.PARENTHESIS] = G_RLF.L["Parentheses"],
	[G_RLF.WrapCharEnum.BRACKET] = G_RLF.L["Square Brackets"],
	[G_RLF.WrapCharEnum.BRACE] = G_RLF.L["Curly Braces"],
	[G_RLF.WrapCharEnum.ANGLE] = G_RLF.L["Angle Brackets"],
	[G_RLF.WrapCharEnum.BAR] = G_RLF.L["Bars"],
}

G_RLF.AtlastIconCoefficients = {
	["ParagonReputation_Bag"] = 1,
	["npe_arrowrightglow"] = 1.2,
	["spellicon-256x256-selljunk"] = 1.5,
	["bags-junkcoin"] = 1.5,
	["auctioneer"] = 1.5,
	["Auctioneer"] = 1.5,
}
