local addonName, G_RLF = ...

local Currency = G_RLF.RLF:NewModule("Currency", "AceEvent-3.0")

Currency.Element = {}

function Currency.Element:new(...)
	local element = {}
	G_RLF.InitializeLootDisplayProperties(element)

	element.type = "Currency"
	element.IsEnabled = function()
		return Currency:IsEnabled()
	end

	element.isLink = true

	local t
	element.key, t, element.icon, element.quantity = ...

	element.textFn = function(existingQuantity, truncatedLink)
		if not truncatedLink then
			return t
		end
		return truncatedLink .. " x" .. ((existingQuantity or 0) + element.quantity)
	end

	local info = C_CurrencyInfo.GetCurrencyInfo(element.key)

	element.quality = info.quality
	element.currentTotal = info.quantity
	element.totalEarned = info.totalEarned
	element.cappedQuantity = info.maxQuantity

	element.secondaryTextFn = function(...)
		if element.currentTotal == 0 then
			return ""
		end

		local str = "    |cFFBABABA" .. element.currentTotal .. "|r"

		if element.cappedQuantity > 0 then
			local percentage, numerator
			if element.totalEarned > 0 then
				numerator = element.totalEarned
				percentage = element.totalEarned / element.cappedQuantity
			else
				numerator = element.currentTotal
				percentage = element.currentTotal / element.cappedQuantity
			end
			local color
			if percentage < 0.7 then
				color = "|cFFFFFFFF"
			elseif percentage >= 0.7 and percentage < 0.9 then
				color = "|cFFFF9B00"
			else
				color = "|cFFFF0000"
			end

			str = str .. "  " .. color .. "(" .. numerator .. " / " .. element.cappedQuantity .. ")|r"
		end

		return str
	end

	return element
end

local hiddenCurrencies

local function isHiddenCurrency(id)
	return hiddenCurrencies[id] == true
end

function Currency:OnInitialize()
	if G_RLF.db.global.currencyFeed then
		self:Enable()
	else
		self:Disable()
	end
end

function Currency:OnDisable()
	self:UnregisterEvent("CURRENCY_DISPLAY_UPDATE")
	self:UnregisterEvent("PERKS_PROGRAM_CURRENCY_AWARDED")
end

function Currency:OnEnable()
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
	self:RegisterEvent("PERKS_PROGRAM_CURRENCY_AWARDED")
end

function Currency:Process(eventName, currencyType, quantityChange)
	self:getLogger():Info(eventName, "WOWEVENT", self.moduleName, currencyType, eventName, quantityChange)

	if currencyType == nil or not quantityChange or quantityChange <= 0 then
		self:getLogger():Debug(
			"Skip showing currency",
			addonName,
			self.moduleName,
			currencyType,
			"SKIP: Something was missing, don't display",
			quantityChange
		)
		return
	end

	if isHiddenCurrency(currencyType) then
		self:getLogger():Debug(
			"Skip showing currency",
			addonName,
			self.moduleName,
			currencyType,
			"SKIP: This is a known hidden currencyType",
			quantityChange
		)
		return
	end

	local info = C_CurrencyInfo.GetCurrencyInfo(currencyType)
	if info == nil or info.description == "" or info.iconFileID == nil then
		self:getLogger():Debug(
			"Skip showing currency",
			addonName,
			self.moduleName,
			currencyType,
			"SKIP: Description or icon was empty",
			quantityChange
		)
		return
	end

	self:fn(function()
		local basicInfo = C_CurrencyInfo.GetBasicCurrencyInfo(currencyType, quantityChange)
		local e = self.Element:new(
			info.currencyID,
			C_CurrencyInfo.GetCurrencyLink(currencyType),
			info.iconFileID,
			basicInfo.displayAmount
		)
		e:Show()
	end)
end

function Currency:CURRENCY_DISPLAY_UPDATE(eventName, ...)
	local currencyType, _quantity, quantityChange, _quantityGainSource, _quantityLostSource = ...

	self:Process(eventName, currencyType, quantityChange)
end

function Currency:PERKS_PROGRAM_CURRENCY_AWARDED(eventName, quantityChange)
	local currencyType = 2032 -- https://www.wowhead.com/currency=2032/traders-tender

	self:Process(eventName, currencyType, quantityChange)
end

hiddenCurrencies = {
	[2918] = true,
	[2919] = true,
	[2899] = true,
	[2793] = true,
	[2902] = true,
	[2897] = true,
	[3045] = true,
	[2912] = true,
	[1822] = true,
	[3066] = true,
	[3040] = true,
	[2785] = true,
	[1810] = true,
	[3002] = true,
	[2795] = true,
	[3041] = true,
	[2901] = true,
	[1191] = true,
	[3054] = true,
	[3068] = true,
	[2034] = true,
	[2789] = true,
	[3003] = true,
	[3050] = true,
	[2035] = true,
	[3004] = true,
	[2813] = true,
	[2786] = true,
	[2026] = true,
	[2792] = true,
	[1728] = true,
	[3051] = true,
	[3047] = true,
	[2794] = true,
	[3052] = true,
	[2787] = true,
	[2033] = true,
	[2024] = true,
	[2788] = true,
	[2900] = true,
	[2023] = true,
	[3065] = true,
	[3057] = true,
	[1889] = true,
	[3086] = true,
	[2791] = true,
	[3071] = true,
	[2029] = true,
	[3042] = true,
	[3046] = true,
	[2898] = true,
	[3059] = true,
	[3061] = true,
	[3048] = true,
	[2027] = true,
	[2167] = true,
	[1744] = true,
	[2706] = true,
	[2030] = true,
	[3064] = true,
	[3067] = true,
	[2790] = true,
	[3058] = true,
	[3043] = true,
	[1703] = true,
	[2709] = true,
	[3063] = true,
	[2025] = true,
	[2921] = true,
	[2904] = true,
	[2903] = true,
	[2533] = true,
	[2166] = true,
	[3070] = true,
	[3049] = true,
	[1171] = true,
	[1877] = true,
	[2715] = true,
	[2796] = true,
	[3069] = true,
	[3060] = true,
	[3075] = true,
	[3013] = true,
	[2814] = true,
	[2707] = true,
	[2267] = true,
	[2153] = true,
	[2805] = true,
	[3074] = true,
	[2920] = true,
	[2652] = true,
	[2819] = true,
	[2106] = true,
	[3023] = true,
	[3073] = true,
	[3083] = true,
	[2922] = true,
	[3053] = true,
	[2808] = true,
	[2649] = true,
	[2028] = true,
	[3044] = true,
	[1891] = true,
	[1907] = true,
	[2171] = true,
	[1579] = true,
	[3062] = true,
	[1838] = true,
	[1559] = true,
	[2109] = true,
	[1747] = true,
	[1982] = true,
	[3077] = true,
	[3079] = true,
	[2000] = true,
	[1745] = true,
	[2031] = true,
	[2410] = true,
	[2036] = true,
	[3080] = true,
	[1757] = true,
	[1880] = true,
	[3085] = true,
	[3099] = true,
	[2408] = true,
	[1325] = true,
	[3005] = true,
	[2169] = true,
	[3009] = true,
	[1878] = true,
	[3010] = true,
	[1593] = true,
	[2278] = true,
	[2866] = true,
	[1807] = true,
	[2908] = true,
	[2874] = true,
	[2420] = true,
	[2172] = true,
	[2645] = true,
	[2149] = true,
	[3094] = true,
	[3076] = true,
	[2710] = true,
	[1750] = true,
	[2413] = true,
	[2419] = true,
	[2780] = true,
	[2810] = true,
	[2151] = true,
	[2152] = true,
	[2708] = true,
	[1347] = true,
	[2910] = true,
	[1501] = true,
	[1752] = true,
	[2170] = true,
	[1540] = true,
	[1722] = true,
	[2021] = true,
	[2094] = true,
	[1541] = true,
	[1804] = true,
	[3088] = true,
	[2402] = true,
	[1746] = true,
	[3103] = true,
	[1598] = true,
	[3115] = true,
	[1837] = true,
	[2087] = true,
	[2002] = true,
	[2784] = true,
	[2653] = true,
	[1594] = true,
	[2150] = true,
	[2906] = true,
	[2409] = true,
	[2165] = true,
	[2872] = true,
	[2858] = true,
	[2088] = true,
	[2862] = true,
	[2173] = true,
	[2108] = true,
	[2175] = true,
	[2244] = true,
	[1595] = true,
	[1805] = true,
	[1324] = true,
	[2856] = true,
	[2873] = true,
	[2909] = true,
	[2717] = true,
	[3081] = true,
	[2861] = true,
	[1842] = true,
	[1884] = true,
	[2275] = true,
	[1592] = true,
	[2277] = true,
	[1794] = true,
	[2148] = true,
	[3000] = true,
	[1596] = true,
	[1806] = true,
	[1848] = true,
	[1903] = true,
	[1597] = true,
	[2266] = true,
	[1808] = true,
	[2871] = true,
	[1748] = true,
	[2268] = true,
	[1852] = true,
	[3078] = true,
	[1997] = true,
	[2716] = true,
	[3007] = true,
	[2911] = true,
	[1506] = true,
	[1714] = true,
	[2876] = true,
	[2878] = true,
	[2913] = true,
	[3082] = true,
	[3084] = true,
	[1738] = true,
	[1769] = true,
	[2231] = true,
	[1742] = true,
	[3026] = true,
	[1847] = true,
	[3001] = true,
	[3027] = true,
	[2854] = true,
	[2907] = true,
	[1599] = true,
	[1349] = true,
	[1600] = true,
	[2269] = true,
	[2411] = true,
	[3006] = true,
	[1853] = true,
	[2270] = true,
	[2412] = true,
	[2271] = true,
	[2859] = true,
	[1840] = true,
	[2800] = true,
	[3011] = true,
	[1883] = true,
	[2107] = true,
	[2865] = true,
	[3025] = true,
	[3087] = true,
	[2279] = true,
	[2867] = true,
	[2264] = true,
	[2280] = true,
	[2265] = true,
	[2869] = true,
	[1849] = true,
	[1850] = true,
	[1749] = true,
	[2857] = true,
	[1350] = true,
	[1705] = true,
	[2875] = true,
	[2272] = true,
	[2718] = true,
	[2860] = true,
	[1758] = true,
	[2273] = true,
	[2774] = true,
	[1723] = true,
	[1841] = true,
	[2274] = true,
	[1762] = true,
	[3022] = true,
	[1887] = true,
	[2276] = true,
	[2864] = true,
	[1888] = true,
	[2811] = true,
	[1740] = true,
	[1845] = true,
	[1846] = true,
	[1902] = true,
	[2868] = true,
	[2853] = true,
	[2870] = true,
	[1947] = true,
	[2855] = true,
	[3104] = true,
	[1851] = true,
	[1986] = true,
	[1839] = true,
	[1761] = true,
	[2863] = true,
	[1763] = true,
	[1843] = true,
	[2174] = true,
	[1739] = true,
	[1844] = true,
	[3024] = true,
	[2655] = true,
	[3072] = true,
	[2799] = true,
}

return Currency
