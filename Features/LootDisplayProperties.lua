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

	self.getLogger = function()
		return G_RLF.RLF:GetModule("Logger")
	end

	self.isPassingFilter = function()
		return true
	end

	self.Show = function(_, itemName, itemQuality)
		if self:isPassingFilter(itemName, itemQuality) then
			G_RLF.LootDisplay:ShowLoot(self)
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

		self:getLogger():Info(self.type .. "Shown", addonName, self.type, self.key, text, amountLogText, new)
	end
end
