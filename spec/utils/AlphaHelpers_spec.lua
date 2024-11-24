local common_stubs = require("spec.common_stubs")

describe("AlphaHelpers", function()
  local ns

  before_each(function()
    ns = common_stubs.setup_G_RLF(spy)
    assert(loadfile("utils/AlphaHelpers.lua"))("TestAddon", ns)
  end)

  describe("dump", function()
    local function parse_dumped_table(dump_string)
      local func, err = load("return " .. dump_string)
      if not func then
          error("Failed to parse dumped table: " .. err)
      end
      return func()
    end

    it("dumps a table to a string", function()
      local t = { key = "value", nested = { 1, 2, 3 } }
      local result = dump(t)

      local parsed = parse_dumped_table(result)

      assert.are.same(parsed, t)
    end)

    it("dumps a non-table value to a string", function()
      local result = dump(123)
      assert.are.equal(result, "123")
    end)
  end)

  describe("ProfileFunction", function()
    it("profiles a function and prints if it takes too long", function()
      local func = function() end
      local profiledFunc = ns:ProfileFunction(func, "testFunc")
      spy.on(ns, "Print")
      profiledFunc()
      assert.spy(ns.Print).was_not_called()
    end)
  end)
end)
