---@type string, table
local _, ns = ...

---@class G_RLF
local G_RLF = ns

---@diagnostic disable-next-line: param-type-mismatch
local L = LibStub("AceLocale-3.0"):NewLocale(G_RLF.localeName, "ptPT")
if not L then
	return
end
