local common_stubs = require("spec/common_stubs")

local function contains_string(state, arguments)
  local expected = arguments[1]
  return function(value)
      return type(value) == "string" and string.find(value, expected, 1, true) ~= nil
  end
end

assert:register("matcher", "contains_string", contains_string)

describe("AddonMethods", function()
  local ns, errorHandlerSpy
  before_each(function()
    errorHandlerSpy = spy.new()
    _G.geterrorhandler = function()
      return errorHandlerSpy
    end
    -- Define the global G_RLF
    ns = ns or common_stubs.setup_G_RLF(spy)

    -- Load the module before each test
    assert(loadfile("utils/AddonMethods.lua"))("TestAddon", ns)
  end)

  describe("fn", function()
    it("calls the function with xpcall and errorhandler", function()
      local funcSpy = spy.new()
      local func = function(...)
        funcSpy(...)
      end
      ns:fn(func, 1, 2, 3)
      assert.spy(funcSpy).was.called_with(1, 2, 3)
    end)

    it("calls the errorhandler when the function throws an error", function()
      local func = function()
        error("test error")
      end
      pcall(function()
        ns:fn(func)
      end)
      assert.spy(errorHandlerSpy).was.called()
      assert.spy(errorHandlerSpy).was_not_called_with(match.contains_string("Trace"))
    end)

    it("calls the errorhandler with stack trace if the calling module function throws an error", function()
      local func = function() error("test error") end
      local module = { moduleName = "TestModule" }
      pcall(function() ns.fn(module, func) end)
      assert.spy(errorHandlerSpy).was_called_with(match.contains_string("Trace"))
    end)
  end)

  describe("RGBAToHexFormat", function()
    it("converts RGBA01 to WoW's hex color format", function()
      local result = ns:RGBAToHexFormat(0.1, 0.2, 0.3, 0.4)
      assert.are.equal(result, "|c6619334C")
    end)
  end)
end)