local assert = require("luassert")
local busted = require("busted")
local describe = busted.describe
local it = busted.it
local setup = busted.setup

describe("Queue module", function()
	local Queue

	-- Helper function to create an item with a value
	local function create_item(value)
		return { value = value }
	end

	setup(function()
		-- Define the global G_RLF
		local ns = {}
		-- Load the Queue module before each test
		assert(loadfile("RPGLootFeed/utils/Queue.lua"))("TestAddon", ns)
		Queue = ns.Queue
	end)

	it("should initialize an empty queue", function()
		local q = Queue:new()
		assert.are.equal(q:size(), 0)
		assert.is_true(q:isEmpty())
	end)

	it("should enqueue items to the queue", function()
		local q = Queue:new()
		local item1 = create_item("first")
		local item2 = create_item("second")
		q:enqueue(item1)
		q:enqueue(item2)

		assert.are.equal(q:size(), 2)
		assert.are.equal(q:peek().value, "first")
	end)

	it("should dequeue items from the queue", function()
		local q = Queue:new()
		local item1 = create_item("first")
		local item2 = create_item("second")
		q:enqueue(item1)
		q:enqueue(item2)

		local dequeued = q:dequeue()
		assert.are.equal(dequeued.value, "first")
		assert.are.equal(q:size(), 1)
		assert.are.equal(q:peek().value, "second")
	end)

	it("should handle dequeue on an empty queue gracefully", function()
		local q = Queue:new()
		local result = q:dequeue()
		assert.is_nil(result)
		assert.are.equal(q:size(), 0)
	end)

	it("should not allow the same item to be enqueued twice", function()
		local q = Queue:new()
		local item = create_item("first")
		q:enqueue(item)
		q:enqueue(item) -- Attempt to enqueue the same item again

		assert.are.equal(q:size(), 1)
	end)

	it("should check if the queue is empty", function()
		local q = Queue:new()
		assert.is_true(q:isEmpty())

		local item = create_item("first")
		q:enqueue(item)
		assert.is_false(q:isEmpty())
	end)

	it("should peek at the front item without removing it", function()
		local q = Queue:new()
		local item1 = create_item("first")
		local item2 = create_item("second")
		q:enqueue(item1)
		q:enqueue(item2)

		local peeked = q:peek()
		assert.are.equal(peeked.value, "first")
		assert.are.equal(q:size(), 2)
	end)

	it("should get the size of the queue", function()
		local q = Queue:new()
		assert.are.equal(q:size(), 0)

		local item1 = create_item("first")
		local item2 = create_item("second")
		q:enqueue(item1)
		q:enqueue(item2)

		assert.are.equal(q:size(), 2)
	end)
end)
