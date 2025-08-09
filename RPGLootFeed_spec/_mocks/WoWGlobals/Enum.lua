local enums = {}

_G.Enum = {
	ItemArmorSubclass = {
		Cloth = 1,
		Leather = 2,
		Mail = 3,
		Plate = 4,
	},
	ItemClass = { Armor = 4, Questitem = 12, Miscellaneous = 15 },
	ItemMiscellaneousSubclass = { Mount = 5 },
	ItemQuality = {
		Poor = 0,
		Common = 1,
		Uncommon = 2,
		Rare = 3,
		Epic = 4,
		Legendary = 5,
		Artifact = 6,
		Heirloom = 7,
		WoWToken = 8,
	},
}

return enums
