---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

local modules = {}

for _, v in pairs(G_RLF.FeatureModule) do
	if type(v) == "string" and v ~= "" then
		table.insert(modules, G_RLF.RLF:GetModule(v))
	end
end

for _, v in pairs(G_RLF.BlizzModule) do
	if type(v) == "string" and v ~= "" then
		table.insert(modules, G_RLF.RLF:GetModule(v))
	end
end

for _, v in pairs(G_RLF.SupportModule) do
	if type(v) == "string" and v ~= "" then
		table.insert(modules, G_RLF.RLF:GetModule(v))
	end
end

-- Wrap all modules' methods in the G_RLF:ProfileFunction method
for _, m in ipairs(modules) do
	if not m then
		G_RLF:LogError("Module not found: " .. tostring(m))
	else
		for k, v in pairs(m) do
			if type(v) == "function" then
				m[k] = G_RLF:ProfileFunction(v, m.moduleName .. ":" .. k)
			end
		end
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
