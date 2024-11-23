local addonName, G_RLF = ...

local LootDisplay = G_RLF.RLF:GetModule("LootDisplay")

-- Wrap all loot display methods in the G_RLF:ProfileFunction method
for k, v in pairs(LootDisplay) do
	if type(v) == "function" then
		LootDisplay[k] = G_RLF:ProfileFunction(v, "LootDisplay:" .. k)
	end
end

-- Wrap all LootDisplayFrameMixin methods in the G_RLF:ProfileFunction method
for k, v in pairs(LootDisplayFrameMixin) do
	if type(v) == "function" then
		LootDisplayFrameMixin[k] = G_RLF:ProfileFunction(v, "LootDisplayFrameMixin:" .. k)
	end
end

-- Wrap all LootDisplayRowMixin methods in the G_RLF:ProfileFunction method
for k, v in pairs(LootDisplayRowMixin) do
	if type(v) == "function" then
		LootDisplayRowMixin[k] = G_RLF:ProfileFunction(v, "LootDisplayRowMixin:" .. k)
	end
end

-- Wrap all Feature modules' methods in the G_RLF:ProfileFunction method
local ItemLoot = G_RLF.RLF:GetModule("ItemLoot")
local Currency = G_RLF.RLF:GetModule("Currency")
local Rep = G_RLF.RLF:GetModule("Reputation")
local Xp = G_RLF.RLF:GetModule("Experience")
local Money = G_RLF.RLF:GetModule("Money")

for k, v in pairs(ItemLoot) do
	if type(v) == "function" then
		ItemLoot[k] = G_RLF:ProfileFunction(v, "ItemLoot:" .. k)
	end
end

for k, v in pairs(Currency) do
	if type(v) == "function" then
		Currency[k] = G_RLF:ProfileFunction(v, "Currency:" .. k)
	end
end

for k, v in pairs(Rep) do
	if type(v) == "function" then
		Rep[k] = G_RLF:ProfileFunction(v, "Rep:" .. k)
	end
end

for k, v in pairs(Xp) do
	if type(v) == "function" then
		Xp[k] = G_RLF:ProfileFunction(v, "Xp:" .. k)
	end
end

for k, v in pairs(Money) do
	if type(v) == "function" then
		Money[k] = G_RLF:ProfileFunction(v, "Money:" .. k)
	end
end

-- Wrap all TestMode methods in the G_RLF:ProfileFunction method
local TestMode = G_RLF.RLF:GetModule("TestMode")

for k, v in pairs(TestMode) do
	if type(v) == "function" then
		TestMode[k] = G_RLF:ProfileFunction(v, "TestMode:" .. k)
	end
end

-- Wrap all Logger methods in the G_RLF:ProfileFunction method
local Logger = G_RLF.RLF:GetModule("Logger")

for k, v in pairs(Logger) do
	if type(v) == "function" then
		Logger[k] = G_RLF:ProfileFunction(v, "Logger:" .. k)
	end
end
