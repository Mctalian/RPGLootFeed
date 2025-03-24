---@type string, table
local addonName, ns = ...

---@class G_RLF
local G_RLF = ns

local DbAccessor = {}

--- Get the frame's sizing config from the db
--- @param frame? G_RLF.Frames
--- @return RLF_ConfigSizing
function DbAccessor:Sizing(frame)
	if frame == G_RLF.Frames.PARTY then
		return G_RLF.db.global.partyLoot.sizing
	end
	return G_RLF.db.global.sizing
end

--- Get the frame's positioning config from the db
--- @param frame? G_RLF.Frames
--- @return RLF_ConfigPositioning
function DbAccessor:Positioning(frame)
	if frame == G_RLF.Frames.PARTY then
		return G_RLF.db.global.partyLoot.positioning
	end
	return G_RLF.db.global.positioning
end

--- Get the frame's styling config from the db
--- @param frame? G_RLF.Frames
--- @return RLF_ConfigStyling
function DbAccessor:Styling(frame)
	if frame == G_RLF.Frames.PARTY then
		return G_RLF.db.global.partyLoot.styling
	end
	return G_RLF.db.global.styling
end

G_RLF.DbAccessor = DbAccessor

return DbAccessor
