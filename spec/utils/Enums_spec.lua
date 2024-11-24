describe("Enums", function()
  local G_RLF

  before_each(function()
    G_RLF = {}
    _G.G_RLF = G_RLF
    assert(loadfile("utils/Enums.lua"))("TestAddon", G_RLF)
  end)

  it("defines DisableBossBanner enum", function()
    assert.is_not_nil(G_RLF.DisableBossBanner)
  end)

  it("defines LogEventSource enum", function()
    assert.is_not_nil(G_RLF.LogEventSource)
  end)

  it("defines LogLevel enum", function()
    assert.is_not_nil(G_RLF.LogLevel)
  end)

  it("defines FeatureModule enum", function()
    assert.is_not_nil(G_RLF.FeatureModule)
  end)

  it("defines WrapCharEnum enum", function()
    assert.is_not_nil(G_RLF.WrapCharEnum)
  end)
end)