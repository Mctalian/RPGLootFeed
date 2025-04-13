---@class TSM_API
---@field public ToItemString fun(item: string)
---@field public GetCustomPriceValue fun(priceSource: string, itemString: string)

---@class ElvUIApp : AceAddon

---@class ElvUILocale: table<string, string>

---@class ElvUIPrivateDb : table

---@class ElvUIProfileDb : table

---@class ElvUIGlobalDb : table

---@class ElvUISkinsModule : AceModule
---@field HandleItemButton fun(self: ElvUISkinsModule, button: Button, setInline: boolean)
---@field HandleIconBorder fun(self: ElvUISkinsModule, borderTexture: Texture)
