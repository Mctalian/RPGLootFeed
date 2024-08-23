local ItemLoot = {}

function ItemLoot:OnItemLooted(...)
  if not G_RLF.db.global.itemLootFeed then
      return
  end

  local msg, _, _, _, _, _, _, _, _, _, _, guid = ...
  local raidLoot = msg:match("HlootHistory:")
  if raidLoot then
      -- Ignore this message as it's a raid loot message
      return
  end
  -- This will not work if another addon is overriding formatting globals like LOOT_ITEM, LOOT_ITEM_MULTIPLE, etc.
  local me = guid == GetPlayerGuid()
  if not me then
      return
  end
  local itemID = msg:match("Hitem:(%d+)")
  if itemID ~= nil then
      local amount = msg:match("r ?x(%d+)") or 1
      local _, itemLink, _, _, _, _, _, _, _, itemTexture = C_Item.GetItemInfo(itemID)
      G_RLF.LootDisplay:ShowLoot(itemID, itemLink, itemTexture, amount)
  end
end

G_RLF.Loot = ItemLoot
