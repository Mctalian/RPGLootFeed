local addonName, G_RLF = ...

G_RLF.LootDisplayProperties = {
	"key",
	"textFn",
	"secondaryTextFn",
	"unit",
	"sellPrice",
	"isLink",
	"icon",
	"quantity",
	"quality",
	"totalCount",
	"r",
	"g",
	"b",
	"a",
	"logFn",
}

function G_RLF.InitializeLootDisplayProperties(self)
	for _, prop in ipairs(G_RLF.LootDisplayProperties) do
		self[prop] = nil
	end

	self.isLink = false

	function self:isPassingFilter(_itemName, _itemQuality)
		return true
	end

	self.Show = function(element, itemName, itemQuality)
		G_RLF:LogDebug("Show", addonName, element.type, element.key, nil, element.quantity)
		if self:isPassingFilter(itemName, itemQuality) then
			G_RLF:SendMessage("RLF_NEW_LOOT", self)
		end
	end

	self.logFn = function(text, amount, new)
		local amountLogText = amount
		local sign = "+"
		if self.quantity < 0 then
			sign = "-"
		end
		if not new then
			amountLogText = format("%s (diff: %s%s)", amount, sign, math.abs(self.quantity))
		end

		G_RLF:LogInfo(self.type .. "Shown", addonName, self.type, self.key, text, amountLogText, new)
	end
end

return G_RLF.LootDisplayProperties
