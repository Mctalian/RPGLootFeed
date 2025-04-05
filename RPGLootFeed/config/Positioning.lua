---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

local Positioning = {}

---@class RLF_DBGlobal
G_RLF.defaults.global = G_RLF.defaults.global or {}

---@class RLF_ConfigPositioning
G_RLF.defaults.global.positioning = {
	---@type string | ScriptRegion
	relativePoint = "UIParent",
	anchorPoint = "BOTTOMLEFT",
	xOffset = 720,
	yOffset = 375,
	frameStrata = "MEDIUM",
}
-- Enumerate available frames to anchor to
local function EnumerateFrames()
	local frames = {
		[-1] = G_RLF.L["Screen"],
	}
	local framesToCheck = {
		["UIParent"] = G_RLF.L["UIParent"],
		["PlayerFrame"] = G_RLF.L["PlayerFrame"],
		["Minimap"] = G_RLF.L["Minimap"],
		["MainMenuBarBackpackButton"] = G_RLF.L["BagBar"],
	}
	for f, s in pairs(framesToCheck) do
		if _G[f] then
			frames[f] = s
		end
	end
	return frames
end

G_RLF.options.args.positioning = {
	type = "group",
	handler = Positioning,
	name = G_RLF.L["Positioning"],
	desc = G_RLF.L["PositioningDesc"],
	order = G_RLF.level1OptionsOrder.positioning,
	args = {
		relativeTo = {
			type = "select",
			name = G_RLF.L["Anchor Relative To"],
			desc = G_RLF.L["RelativeToDesc"],
			get = function()
				return G_RLF.db.global.positioning.relativePoint
			end,
			set = function(_, value)
				G_RLF.db.global.positioning.relativePoint = value
				G_RLF.LootDisplay:UpdatePosition()
			end,
			values = EnumerateFrames(),
			order = 1,
		},
		anchorPoint = {
			type = "select",
			name = G_RLF.L["Anchor Point"],
			desc = G_RLF.L["AnchorPointDesc"],
			get = function()
				return G_RLF.db.global.positioning.anchorPoint
			end,
			set = function(_, value)
				G_RLF.db.global.positioning.anchorPoint = value
				G_RLF.LootDisplay:UpdatePosition()
			end,
			values = {
				["TOPLEFT"] = G_RLF.L["Top Left"],
				["TOPRIGHT"] = G_RLF.L["Top Right"],
				["BOTTOMLEFT"] = G_RLF.L["Bottom Left"],
				["BOTTOMRIGHT"] = G_RLF.L["Bottom Right"],
				["TOP"] = G_RLF.L["Top"],
				["BOTTOM"] = G_RLF.L["Bottom"],
				["LEFT"] = G_RLF.L["Left"],
				["RIGHT"] = G_RLF.L["Right"],
				["CENTER"] = G_RLF.L["Center"],
			},
			order = 2,
		},
		xOffset = {
			type = "range",
			name = G_RLF.L["X Offset"],
			desc = G_RLF.L["XOffsetDesc"],
			min = -1500,
			max = 1500,
			get = function()
				return G_RLF.db.global.positioning.xOffset
			end,
			set = function(_, value)
				G_RLF.db.global.positioning.xOffset = value
				G_RLF.LootDisplay:UpdatePosition()
			end,
			order = 3,
		},
		yOffset = {
			type = "range",
			name = G_RLF.L["Y Offset"],
			desc = G_RLF.L["YOffsetDesc"],
			min = -1500,
			max = 1500,
			get = function()
				return G_RLF.db.global.positioning.yOffset
			end,
			set = function(_, value)
				G_RLF.db.global.positioning.yOffset = value
				G_RLF.LootDisplay:UpdatePosition()
			end,
			order = 4,
		},
		frameStrata = {
			type = "select",
			name = G_RLF.L["Frame Strata"],
			desc = G_RLF.L["FrameStrataDesc"],
			get = function()
				return G_RLF.db.global.positioning.frameStrata
			end,
			set = function(_, value)
				G_RLF.db.global.positioning.frameStrata = value
				G_RLF.LootDisplay:UpdateStrata()
			end,
			values = {
				["BACKGROUND"] = G_RLF.L["Background"],
				["LOW"] = G_RLF.L["Low"],
				["MEDIUM"] = G_RLF.L["Medium"],
				["HIGH"] = G_RLF.L["High"],
				["DIALOG"] = G_RLF.L["Dialog"],
				["TOOLTIP"] = G_RLF.L["Tooltip"],
			},
			sorting = {
				"BACKGROUND",
				"LOW",
				"MEDIUM",
				"HIGH",
				"DIALOG",
				"TOOLTIP",
			},
			order = 5,
		},
		partyLootFrame = G_RLF.ConfigHandlers.PartyLootConfig:GetPositioningOptions(6),
	},
}
