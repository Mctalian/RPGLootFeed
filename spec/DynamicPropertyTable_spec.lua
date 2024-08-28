-- dynamic_property_table_spec.lua
describe("DynamicPropertyTable", function()
	local globalTable, defaultsTable, proxy

	before_each(function()
		-- Initialize the tables
		require("DynamicPropertyTable")
		globalTable = {}
		defaultsTable = { key1 = "default1", key2 = "default2", key3 = true }
		proxy = DynamicPropertyTable(globalTable, defaultsTable)
	end)

	it("should return default value if key is not in globalTable", function()
		assert.are.equal(proxy.key1, "default1")
		assert.are.equal(proxy.key2, "default2")
	end)

	it("should return global value if key is present in globalTable", function()
		globalTable.key1 = "global1"
		assert.are.equal(proxy.key1, "global1")
	end)

	it("should set value in globalTable if key is in defaultsTable", function()
		proxy.key1 = "newGlobal1"
		assert.are.equal(globalTable.key1, "newGlobal1")
	end)

	it("should not affect globalTable if key is not in defaultsTable", function()
		proxy.nonDefaultKey = "newValue"
		assert.is_nil(globalTable.nonDefaultKey)
		assert.are.equal(proxy.nonDefaultKey, "newValue")
	end)

	it("should handle non-existent keys gracefully", function()
		assert.is_nil(proxy.nonExistentKey)
	end)

	it("should handle updates to default values", function()
		defaultsTable.key2 = "updatedDefault2"
		assert.are.equal(proxy.key2, "updatedDefault2")
	end)

	it("should handle booleans", function()
		globalTable.key3 = false
		assert.are.equal(proxy.key3, false)
	end)
end)
