local busted = require("busted")
local stub = busted.stub

local itemMocks = {}

_G.C_Item = {}
itemMocks.GetItemCount = stub(_G.C_Item, "GetItemCount").returns(1)
itemMocks.GetItemInfo = stub(_G.C_Item, "GetItemInfo").returns(18803, "Finkle's Lava Dredger", 2, 60, 1, "INV_AXE_33")
itemMocks.GetItemIDForItemInfo = stub(_G.C_Item, "GetItemIDForItemInfo").returns(18803)
itemMocks.GetItemStats = stub(_G.C_Item, "GetItemStats").returns({
	["ITEM_MOD_STRENGTH_SHORT"] = 10,
	["ITEM_MOD_AGILITY_SHORT"] = 5,
	["ITEM_MOD_INTELLECT_SHORT"] = 8,
	["ITEM_MOD_STAMINA_SHORT"] = 12,
})
itemMocks.GetItemStatDelta = stub(_G.C_Item, "GetItemStatDelta").returns({
	["ITEM_MOD_STRENGTH_SHORT"] = 10,
	["ITEM_MOD_AGILITY_SHORT"] = 5,
	["ITEM_MOD_INTELLECT_SHORT"] = 8,
	["ITEM_MOD_STAMINA_SHORT"] = 12,
})
itemMocks.IsEquippableItem = stub(_G.C_Item, "IsEquippableItem").returns(true)
itemMocks.GetItemQualityColor = stub(_G.C_Item, "GetItemQualityColor").returns(1, 0.5, 0, 1)

return itemMocks
