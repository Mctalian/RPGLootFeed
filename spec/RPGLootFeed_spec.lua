describe("RPGLootFeed module", function()

  before_each(function()
      _G.LibStub = function()
        return {
          GetLocale = function()
          end
        }
      end
      -- Define the global G_RLF
      _G.G_RLF = {
        RLF = {}
      }
      -- Load the list module before each test
      dofile("RPGLootFeed.lua")
  end)

  it("TODO", function()
    assert.are.equal(true, true)
  end)
end)
