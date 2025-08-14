---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

---@class RLF_Money: RLF_Module, AceEvent-3.0
local Money = G_RLF.RLF:NewModule(G_RLF.FeatureModule.Money, "AceEvent-3.0")

-- Context provider function to be registered when module is enabled
local function createMoneyContextProvider()
	return function(context, data)
		-- Get coin string for the total amount
		context.coinString = C_CurrencyInfo.GetCoinTextureString(context.absTotal)

		-- Support for accountant mode
		if G_RLF.db.global.money.accountantMode then
			context.coinString = "(" .. context.coinString .. ")"
		end

		-- Current money total for secondary text
		if G_RLF.db.global.money.showMoneyTotal then
			local currentMoney = GetMoney()
			if currentMoney > 10000000 then -- More than 1000 gold
				currentMoney = math.floor(currentMoney / 10000) * 10000 -- truncate silver and copper
			end
			context.currentMoney = C_CurrencyInfo.GetCoinTextureString(currentMoney)

			-- Handle abbreviation if enabled
			if G_RLF.db.global.money.abbreviateTotal and currentMoney > 10000000 then
				local goldOnly = math.floor(currentMoney / 10000)
				context.currentMoney =
					context.currentMoney:gsub(tostring(goldOnly), G_RLF.TextTemplateEngine:AbbreviateNumber(goldOnly))
			end
		else
			-- When showMoneyTotal is disabled, provide empty currentMoney
			-- This will cause row 2 to be only spacers, which ProcessRowElements will detect and return ""
			context.currentMoney = ""
		end
	end
end

Money.Element = {}

function Money.Element:new(...)
	---@class Money.Element: RLF_BaseLootElement
	local element = {}
	G_RLF.InitializeLootDisplayProperties(element)

	element.type = G_RLF.FeatureModule.Money
	element.icon = G_RLF.DefaultIcons.MONEY
	if not G_RLF.db.global.money.enableIcon or G_RLF.db.global.misc.hideAllIcons then
		element.icon = nil
	end
	element.quality = G_RLF.ItemQualEnum.Poor
	element.IsEnabled = function()
		return Money:IsEnabled()
	end

	element.key = "MONEY_LOOT"
	element.quantity = ...
	if not element.quantity or element.quantity == 0 then
		return
	end

	-- Generate text elements using the new data-driven approach
	element.textElements = Money:GenerateTextElements(element.quantity)

	---@type RLF_LootElementData
	local elementData = {
		key = element.key,
		type = "Money", -- Use string type for context provider lookup
		textElements = element.textElements,
		quantity = element.quantity,
		icon = element.icon,
		quality = element.quality,
	}

	-- Replace the old textFn with a new one that uses TextTemplateEngine
	element.textFn = function(existingCopper)
		return G_RLF.TextTemplateEngine:ProcessRowElements(1, elementData, existingCopper)
	end

	-- Replace the old secondaryTextFn with new template-based approach
	element.secondaryTextFn = function(existingCopper)
		return G_RLF.TextTemplateEngine:ProcessRowElements(2, elementData, existingCopper)
	end

	-- Handle sound configuration like the original Money module
	if G_RLF.db.global.money.overrideMoneyLootSound and G_RLF.db.global.money.moneyLootSound ~= "" then
		element.sound = G_RLF.db.global.money.moneyLootSound
	end

	-- Add PlaySoundIfEnabled method to the element
	function element:PlaySoundIfEnabled()
		if G_RLF.db.global.money.overrideMoneyLootSound and G_RLF.db.global.money.moneyLootSound ~= "" then
			local willPlay, handle = PlaySoundFile(G_RLF.db.global.money.moneyLootSound)
			if not willPlay then
				G_RLF:LogWarn(
					"Failed to play sound " .. G_RLF.db.global.money.moneyLootSound,
					addonName,
					Money.moduleName or "MoneyV2"
				)
			else
				G_RLF:LogDebug(
					"Sound queued to play " .. G_RLF.db.global.money.moneyLootSound .. " " .. handle,
					addonName,
					Money.moduleName or "MoneyV2"
				)
			end
		end
	end

	return element
end

--- Generate text elements for Money type using the new data-driven approach
---@param quantity number The money amount in copper
---@return table<number, table<string, RLF_TextElement>> textElements Row-indexed elements: [row][elementKey] = element
function Money:GenerateTextElements(quantity)
	local elements = {}

	-- Row 1: Primary money display
	elements[1] = {}
	elements[1].primary = {
		type = "primary",
		template = "{sign}{coinString}",
		order = 1,
		color = nil, -- Will use default color
	}

	-- Row 2: Context text element (money total) - only if enabled
	elements[2] = {}
	elements[2].contextSpacer = {
		type = "spacer",
		spacerCount = 4, -- "    " spacing
		order = 1,
	}

	elements[2].context = {
		type = "context",
		template = "{currentMoney}",
		order = 2,
		color = nil,
	}

	return elements
end

function Money:OnInitialize()
	self.startingMoney = 0
	if G_RLF.db.global.money.enabled then
		self:Enable()
	else
		self:Disable()
	end
end

function Money:OnEnable()
	-- Register our context provider with the TextTemplateEngine
	G_RLF.TextTemplateEngine:RegisterContextProvider("Money", createMoneyContextProvider())

	self:RegisterEvent("PLAYER_MONEY")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self.startingMoney = GetMoney()
end

function Money:OnDisable()
	-- Unregister our context provider
	G_RLF.TextTemplateEngine.contextProviders["Money"] = nil

	self:UnregisterEvent("PLAYER_MONEY")
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function Money:PLAYER_ENTERING_WORLD(eventName)
	self.startingMoney = GetMoney()
end

function Money:PLAYER_MONEY(eventName)
	G_RLF:fn(function()
		local newMoney = GetMoney()
		local amountInCopper = newMoney - self.startingMoney
		if amountInCopper == 0 then
			return
		end
		self.startingMoney = newMoney
		if G_RLF.db.global.money.onlyIncome and amountInCopper < 0 then
			return
		end

		local element = self.Element:new(amountInCopper)
		if element then
			element:Show()
			element:PlaySoundIfEnabled()
		end
	end)
end

return Money
