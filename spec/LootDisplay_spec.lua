describe("LootDisplay module", function()

  before_each(function()
      -- Define the global G_RLF
      _G.G_RLF = {
        list = function()
        end
      }
      -- Load the list module before each test
      dofile("LootDisplay.lua")
  end)

  it("TODO", function()
    assert.are.equal(true, true)
  end)
end)
