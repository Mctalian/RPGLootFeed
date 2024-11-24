local common_stubs = require("spec/common_stubs")

describe("Professions Module", function()
	local _ = match._
	local Professions, ns

	before_each(function()
		ns = ns or common_stubs.setup_G_RLF(spy)
		_G.Enum = { ItemQuality = { Rare = 3 } }
		_G.GetProfessions = function()
			return 1, 2, 3, 4, 5
		end
		_G.GetProfessionInfo = function(id)
			return "Profession" .. id, "icon" .. id, id * 10, id * 20, nil, nil, nil, nil, nil, nil, "Expansion" .. id
		end

		Professions = assert(loadfile("Features/Professions.lua"))("TestAddon", ns)
		Professions:OnInitialize()
	end)

	it("should initialize professions correctly", function()
		Professions:InitializeProfessions()
		assert.are.same(Professions.profNameIconMap["Profession1"], "icon1")
	end)

	it("should handle PLAYER_ENTERING_WORLD event", function()
		spy.on(Professions, "RegisterEvent")
		Professions:PLAYER_ENTERING_WORLD()
		assert.equal(#Professions.profLocaleBaseNames, 5)
	end)

	describe("Element", function()
		it("creates a new element correctly", function()
			local element = Professions.Element:new(1, "Expansion1", "icon1", 10, 20, 5)
			assert.are.same(element.name, "Expansion1")
			assert.are.same(element.icon, "icon1")
			assert.are.same(element.level, 10)
			assert.are.same(element.maxLevel, 20)
			assert.are.same(element.quantity, 5)
			assert.are.same(element.key, "PROF_1")
		end)
	end)
end)
