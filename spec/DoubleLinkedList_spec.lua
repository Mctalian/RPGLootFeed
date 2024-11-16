describe("List module", function()
	local list

	-- Helper function to create a node with a value
	local function create_node(value)
		return { value = value }
	end

	local ns
	before_each(function()
		-- Define the global G_RLF
		ns = ns or {}
		-- Load the list module before each test
		assert(loadfile("DoubleLinkedList.lua"))("TestAddon", ns)

		list = ns.list
	end)

	it("should initialize an empty list", function()
		local l = list()
		assert.are.equal(l.length, 0)
		assert.is_nil(l.first)
		assert.is_nil(l.last)
	end)

	it("should push elements to the list", function()
		local l = list()
		l:push(create_node("first"))
		l:push(create_node("second"))

		assert.are.equal(l.length, 2)
		assert.are.equal(l.first.value, "first")
		assert.are.equal(l.last.value, "second")
		assert.are.equal(l.first._next, l.last)
		assert.are.equal(l.last._prev, l.first)
	end)

	it("should unshift elements to the list", function()
		local l = list()
		l:unshift(create_node("first"))
		l:unshift(create_node("second"))

		assert.are.equal(l.length, 2)
		assert.are.equal(l.first.value, "second")
		assert.are.equal(l.last.value, "first")
		assert.are.equal(l.first._next, l.last)
		assert.are.equal(l.last._prev, l.first)
	end)

	it("should pop elements from the list", function()
		local l = list(create_node("first"), create_node("second"), create_node("third"))
		local popped = l:pop()

		assert.are.equal(popped.value, "third")
		assert.are.equal(l.length, 2)
		assert.are.equal(l.last.value, "second")
		assert.is_nil(l.last._next)
	end)

	it("should shift elements from the list", function()
		local l = list(create_node("first"), create_node("second"), create_node("third"))
		local shifted = l:shift()

		assert.are.equal(shifted.value, "first")
		assert.are.equal(l.length, 2)
		assert.are.equal(l.first.value, "second")
		assert.is_nil(l.first._prev)
	end)

	it("should remove a specific node from the list", function()
		local l = list(create_node("first"), create_node("second"), create_node("third"))
		l:remove(l.first._next) -- remove "second"

		assert.are.equal(l.length, 2)
		assert.are.equal(l.first._next.value, "third")
		assert.are.equal(l.last._prev.value, "first")
	end)

	it("can remove the only node from the list", function()
		local l = list(create_node("first"))
		l:remove(l.last) -- remove "first"

		assert.are.equal(l.length, 0)
		assert.is_nil(l.first)
		assert.is_nil(l.last)
	end)

	it("can remove the last node from the list", function()
		local l = list(create_node("first"), create_node("second"))
		l:remove(l.last) -- remove "second"

		assert.are.equal(l.length, 1)
		assert.are.equal(l.first.value, "first")
		assert.is_nil(l.first._next)
		assert.are.equal(l.last, l.first)
		assert.is_not_nil(l.last)
	end)

	it("should iterate over the list", function()
		local l = list(create_node("first"), create_node("second"), create_node("third"))
		local result = {}

		for node in l:iterate() do
			table.insert(result, node.value)
		end

		assert.are.same(result, { "first", "second", "third" })
	end)

	it("should gracefully handle pop on an empty list", function()
		local l = list()

		local result = l:pop()

		assert.is_nil(result)
		assert.are.equal(l.length, 0)
	end)

	it("should gracefully handle shift on an empty list", function()
		local l = list()

		local result = l:shift()

		assert.is_nil(result)
		assert.are.equal(l.length, 0)
	end)

	it("pops the only item from a list and leaves it empty", function()
		local l = list(create_node("first"))

		local result = l:pop()
		assert.are.equal(result.value, "first")
		assert.is_nil(l.first)
		assert.is_nil(l.last)
		assert.are.equal(l.length, 0)
	end)

	it("does not allow the same node to be added twice", function()
		local f = create_node("first")
		local s = create_node("second")
		local t = create_node("third")
		local l = list(f, s, t, s) -- Adding 's' twice won't work
		local result = {}

		for node in l:iterate() do
			table.insert(result, node.value)
		end

		assert.are.same(result, { "first", "second", "third" })
	end)
end)
