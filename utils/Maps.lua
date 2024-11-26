local addonName, G_RLF = ...

G_RLF.armorClassMapping = {
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

G_RLF.equipSlotMap = {
	INVTYPE_HEAD = 1,
	INVTYPE_NECK = 2,
	INVTYPE_SHOULDER = 3,
	INVTYPE_BODY = 4,
	INVTYPE_CHEST = 5,
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
