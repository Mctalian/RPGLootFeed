describe("Experience module", function()
  local mockLootDisplay
  local _ = match._

  before_each(function()
      -- Define the global G_RLF
      _G.G_RLF = {
        db = {
          global = {}
        },
        LootDisplay = {
          ShowXP = function() end
        }
      }
      _G.UnitLevel = function()
          return 2
      end
      _G.UnitXP = function()
          return 10
      end
      _G.UnitXPMax = function()
          return 50
      end

      mockLootDisplay = mock(_G.G_RLF.LootDisplay, true)
      -- Load the list module before each test
      dofile("Features/Experience.lua")
  end)

  it("does not run if the feature is disabled", function()
      _G.G_RLF.db.global.xpFeed = false

      _G.G_RLF.Xp:OnXpChange("player")

      assert.stub(mockLootDisplay.ShowXP).was.not_called()
  end)

  it("does not show xp if the unit target is not player", function()
    _G.G_RLF.db.global.xpFeed = true

    _G.G_RLF.Xp:OnXpChange("target")

    assert.stub(mockLootDisplay.ShowXP).was.not_called()
  end)

  it("does not show xp if the calculated delta is 0", function()
    _G.G_RLF.db.global.xpFeed = true

    _G.G_RLF.Xp:Snapshot()

    _G.G_RLF.Xp:OnXpChange("player")

    assert.stub(mockLootDisplay.ShowXP).was.not_called()
  end)

  it("does not show xp if the calculated delta is 0", function()
    _G.G_RLF.db.global.xpFeed = true

    _G.G_RLF.Xp:Snapshot()

    _G.UnitLevel = function()
      return 3
    end
    _G.UnitXPMax = function()
      return 100
    end

    _G.G_RLF.Xp:OnXpChange("player")

    assert.stub(mockLootDisplay.ShowXP).was.called_with(_, 50)
  end)
end)
