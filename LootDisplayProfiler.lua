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
