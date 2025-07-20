---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

---@class RLF_Money: RLF_Module, AceEvent-3.0
local Money = G_RLF.RLF:NewModule(G_RLF.FeatureModule.Money, "AceEvent-3.0")

Money.Element = {}

function Money.Element:new(...)
	---@class Money.Element: RLF_BaseLootElement
	local element = {}
	G_RLF.InitializeLootDisplayProperties(element)

	element.type = "Money"
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
	if not element.quantity then
		return
	end
	element.textFn = function(existingCopper)
		local sign = ""
		local total = (existingCopper or 0) + element.quantity
		if total < 0 then
			sign = "-"
		end
		local coinString = C_CurrencyInfo.GetCoinTextureString(math.abs(total))
		if G_RLF.db.global.money.accountantMode then
			return "(" .. coinString .. ")"
		end
		return sign .. coinString
	end

	local function abbreviate(total)
		if total > 1000000000 then
			return string.format("%.2f" .. G_RLF.L["BillionAbbrev"], total / 1000000000)
		elseif total > 1000000 then
			return string.format("%.2f" .. G_RLF.L["MillionAbbrev"], total / 1000000)
		elseif total > 1000 then
			return string.format("%.2f" .. G_RLF.L["ThousandAbbrev"], total / 1000)
		end
		return total
	end

	element.secondaryTextFn = function()
		if not G_RLF.db.global.money.showMoneyTotal then
			return
		end

		local money = GetMoney()
		if money > 10000000 then -- More than 1000 gold
			money = math.floor(money / 10000) * 10000 -- truncate silver and copper
			if G_RLF.db.global.money.abbreviateTotal then
				local goldOnly = math.floor(money / 10000) -- get the gold
				local coinString = C_CurrencyInfo.GetCoinTextureString(money) -- get the coin string
				return "    " .. string.gsub(coinString, goldOnly, abbreviate(goldOnly)) -- replace the money with the abbreviated version
			end
		end
		return "    " .. C_CurrencyInfo.GetCoinTextureString(money)
	end

	function element:PlaySoundIfEnabled()
		if G_RLF.db.global.money.overrideMoneyLootSound and G_RLF.db.global.money.moneyLootSound ~= "" then
			local willPlay, handle = PlaySoundFile(G_RLF.db.global.money.moneyLootSound)
			if not willPlay then
				G_RLF:LogWarn(
					"Failed to play sound " .. G_RLF.db.global.money.moneyLootSound,
					addonName,
					Money.moduleName
				)
			else
				G_RLF:LogDebug(
					"Sound queued to play " .. G_RLF.db.global.money.moneyLootSound .. " " .. handle,
					addonName,
					Money.moduleName
				)
			end
		end
	end

	return element
end

function Money:OnInitialize()
	self.startingMoney = 0
	if G_RLF.db.global.money.enabled then
		self:Enable()
	else
		self:Disable()
	end
end

function Money:OnDisable()
	self:UnregisterEvent("PLAYER_MONEY")
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function Money:OnEnable()
	self:RegisterEvent("PLAYER_MONEY")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self.startingMoney = GetMoney()
	G_RLF:LogDebug("OnEnable", addonName, self.moduleName)
end

function Money:PLAYER_ENTERING_WORLD(eventName)
	G_RLF:LogInfo(eventName, "WOWEVENT", self.moduleName)
	self.startingMoney = GetMoney()
end

function Money:PLAYER_MONEY(eventName)
	G_RLF:LogInfo(eventName, "WOWEVENT", self.moduleName)
	self:fn(function()
		local newMoney = GetMoney()
		local amountInCopper = newMoney - self.startingMoney
		if amountInCopper == 0 then
			G_RLF:LogDebug(
				"Skipping: No change in money",
				addonName,
				self.moduleName,
				"MONEY",
				"Amount is 0",
				amountInCopper
			)
			return
		end
		self.startingMoney = newMoney
		if G_RLF.db.global.money.onlyIncome and amountInCopper < 0 then
			G_RLF:LogDebug("Ignoring money loss in 'only income' mode", addonName, self.moduleName)
			return
		end

		local e = self.Element:new(amountInCopper)
		if not e then
			G_RLF:LogDebug("No money to display", addonName, self.moduleName)
			return
		end

		e:Show()
		e:PlaySoundIfEnabled()
	end)
end

return Money
