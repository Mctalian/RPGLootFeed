---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

local lootDisplayProperties = {
	"key",
	"textFn",
	"secondaryTextFn",
	"secondaryText",
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
	"eventChannel",
}

---@class RLF_LootElement
---@field public key string
---@field public textFn fun(existingQuantity: number, truncatedLink: string): string
---@field public secondaryTextFn fun(...: any): string
---@field public unit string
---@field public sellPrice number
---@field public isLink boolean
---@field public icon number
---@field public eventChannel string
---@field public quantity number
---@field public quality number
---@field public totalCount number
---@field public showForSeconds number
---@field public r number
---@field public g number
---@field public b number
---@field public a number
---@field public logFn fun(text: string, amount: number, new: boolean): nil
---@field public Show fun(s: RLF_LootElement, itemName?: string, itemQuality?: number): nil
---@field public isPassingFilter fun(s: RLF_LootElement, itemName: string, itemQuality: number): boolean
---@field public IsEnabled fun(s: RLF_LootElement): boolean
---@field public type string

function G_RLF.InitializeLootDisplayProperties(element)
	for _, prop in ipairs(lootDisplayProperties) do
		element[prop] = nil
	end

	element.isLink = false
	element.eventChannel = "RLF_NEW_LOOT"
	element.showForSeconds = G_RLF.db.global.animations.exit.fadeOutDelay

	function element:isPassingFilter(_itemName, _itemQuality)
		return true
	end

	element.Show = function(element, itemName, itemQuality)
		if element:isPassingFilter(itemName, itemQuality) then
			G_RLF:LogDebug("Show", addonName, element.type, element.key, nil, element.quantity)
			G_RLF:SendMessage(element.eventChannel, element)
		end
	end

	element.logFn = function(text, amount, new)
		local amountLogText = tostring(amount)
		local sign = "+"
		if element.quantity < 0 then
			sign = "-"
		end
		if not new then
			amountLogText = format("%s (diff: %s%s)", amount, sign, math.abs(element.quantity))
		end

		G_RLF:LogInfo(element.type .. "Shown", addonName, element.type, element.key, text, amountLogText, new)
	end
end

return {}
