---@type string, G_RLF
local _, G_RLF = ...

---@diagnostic disable-next-line: param-type-mismatch
local L = LibStub("AceLocale-3.0"):NewLocale(G_RLF.localeName, "ptPT")
if not L then
	return
end
