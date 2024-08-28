TestMode = {}

local p = "ff9d9d9d"
local c = "ffffffff"
local u = "ff1eff00"
local r = "ff0070dd"
local e = "ffa335ee"
local l = "ffff8000"
local a = "ffe6cc80"
local h = "ff00ccff"

local function createItemLink(name, id, color)
	return "|c" .. color .. "|Hitem:" .. id .. "::::::::1:::::::|h[" .. name .. "]|h|r"
end

-- Initial test items with color variables
local testItems = {
	{
		name = "Linen Cloth",
		id = 2589,
		icon = 132889,
		color = c,
	},
	{
		name = "Wool Cloth",
		id = 2592,
		icon = 132911,
		color = c,
	},
	{
		name = "Rough Wooden Staff",
		id = 1515,
		icon = 135146,
		color = p,
	},
	{
		name = "Murloc Eye",
		id = 730,
		icon = 133884,
		color = p,
	},
	{
		name = "Thunderfury, Blessed Blade of the Windseeker",
		id = 19019,
		icon = 135349,
		color = l,
	},
	{
		name = "Inflatable Thunderfury, Blessed Blade of the Windseeker",
		id = 128507,
		icon = 135349,
		color = r,
	}, -- New items
	{
		name = "Crystal Shard",
		id = 132842,
		icon = 237190,
		color = c,
	},
	{
		name = "Bracers of the Green Fortress",
		id = 23538,
		icon = 132605,
		color = e,
	},
	{
		name = "Black Diamond",
		id = 11754,
		icon = 134071,
		color = u,
	},
	{
		name = "Xal'atath, Blade of the Black Empire",
		id = 128827,
		icon = 134165,
		color = a,
	},
	{
		name = "Band of Radiant Echoes",
		id = 219325,
		icon = 4638575,
		color = h,
	},
}

TestMode.TestItems = {}
for _, item in ipairs(testItems) do
	table.insert(TestMode.TestItems, {
		id = item.id,
		link = createItemLink(item.name, item.id, item.color),
		icon = item.icon,
	})
end

TestMode.TestCurrencies = { -- Existing currencies
	{
		currencyID = 2245,
		name = "Flightstone",
		iconFileID = 4638586,
	}, -- Dragonflight
	{
		currencyID = 1191,
		name = "Valor",
		iconFileID = 463447,
	},
	{
		currencyID = 1828,
		name = "Soul Ash",
		iconFileID = 3743738,
	}, -- Shadowlands
	{
		currencyID = 1792,
		name = "Honor",
		iconFileID = 255347,
	},
	{
		currencyID = 1755,
		name = "Argus Waystone",
		iconFileID = 399041,
	}, -- Legion
	{
		currencyID = 1580,
		name = "Seal of Wartorn Fate",
		iconFileID = 1416740,
	}, -- Battle for Azeroth
	{
		currencyID = 1273,
		name = "Seal of Broken Fate",
		iconFileID = 1604168,
	}, -- Legion
	{
		currencyID = 1166,
		name = "Timewarped Badge",
		iconFileID = 463446,
	},
	{
		currencyID = 515,
		name = "Darkmoon Prize Ticket",
		iconFileID = 134481,
	},
	{
		currencyID = 241,
		name = "Champion's Seal",
		iconFileID = 236689,
	}, -- Wrath of the Lich King
	-- New currencies
	{
		currencyID = 1813,
		name = "Reservoir Anima",
		iconFileID = 3528288,
	}, -- Shadowlands
	{
		currencyID = 2778,
		name = "Bronze",
		iconFileID = 4638724,
	}, -- Remix
	{
		currencyID = 3089,
		name = "Residual Memories",
		iconFileID = 3015740,
	}, -- TWW: Pre-Patch
	{
		currencyID = 1101,
		name = "Oil",
		iconFileID = 1131085,
	}, -- Legion
	{
		currencyID = 1704,
		name = "Spirit Shard",
		iconFileID = 133286,
	}, -- Burning Crusade
}

function TestMode:ToggleTestMode()
	if self.testMode then
		-- Stop test mode
		self.testMode = false
		if self.testTimer then
			self.testTimer:Cancel()
			self.testTimer = nil
		end
		G_RLF:Print(G_RLF.L["Test Mode Disabled"])
	else
		-- Start test mode
		self.testMode = true
		G_RLF:Print(G_RLF.L["Test Mode Enabled"])
		self.testTimer = C_Timer.NewTicker(1.5, function()
			self:GenerateRandomLoot()
		end)
	end
end

function TestMode:GenerateRandomLoot()
	-- Randomly decide whether to generate an item or currency
	local rng = math.random()
	if rng < 0.8 then
		-- Generate random item
		local item = self.TestItems[math.random(#self.TestItems)]
		local amountLooted = math.random(1, 5)
		G_RLF.LootDisplay:ShowLoot(item.id, item.link, item.icon, amountLooted)
		if rng < 0.1 then
			local copper = math.random(1, 100000000)
			G_RLF.LootDisplay:ShowMoney(copper)
		end
	else
		-- Generate random currency
		local currency = self.TestCurrencies[math.random(#self.TestCurrencies)]
		local amountLooted = math.random(1, 500)
		local currencyLink = G_RLF:GetCurrencyLink(currency.currencyID, currency.name)
		G_RLF.LootDisplay:ShowLoot(currency.currencyID, currencyLink, currency.iconFileID, amountLooted)
	end
end

G_RLF.TestMode = TestMode
