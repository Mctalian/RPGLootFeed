describe("Maps", function()
	local G_RLF

	before_each(function()
		G_RLF = {}
		_G.G_RLF = G_RLF
		_G.Enum = {
			ItemArmorSubclass = {
				Plate = 4,
				Mail = 3,
				Leather = 2,
				Cloth = 1,
			},
		}
		assert(loadfile("utils/Maps.lua"))("TestAddon", G_RLF)
	end)

	it("defines armorClassMapping", function()
		assert.is_not_nil(G_RLF.armorClassMapping)
	end)

	it("defines equipSlotMap", function()
		assert.is_not_nil(G_RLF.equipSlotMap)
	end)
end)
