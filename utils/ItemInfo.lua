local addonName, G_RLF = ...

local ItemInfo = {}
ItemInfo.__index = ItemInfo
function ItemInfo:new(...)
	local self = {}
	setmetatable(self, ItemInfo)
	self.itemId, self.itemName, self.itemLink, self.itemQuality, self.itemLevel, self.itemMinLevel, self.itemType, self.itemSubType, self.itemStackCount, self.itemEquipLoc, self.itemTexture, self.sellPrice, self.classID, self.subclassID, self.bindType, self.expansionID, self.setID, self.isCraftingReagent =
		...
	if not self.itemName then
		return nil
	end
	if not self.itemId then
		self.itemId = C_Item.GetItemIDForItemInfo(self.itemLink)
	end
	return self
end

function ItemInfo:IsMount()
	-- Highlight Mounts
	if
		self.classID == Enum.ItemClass.Miscellaneous
		and self.subclassID == Enum.ItemMiscellaneousSubclass.Mount
		and G_RLF.db.global.itemHighlights.mounts
	then
		return true
	end

	return false
end

function ItemInfo:IsLegendary()
	-- Highlight Legendary Items
	if self.itemQuality == Enum.ItemQuality.Legendary and G_RLF.db.global.itemHighlights.legendary then
		return true
	end

	return false
end

G_RLF.ItemInfo = ItemInfo