local addonName, G_RLF = ...

-- Queue implementation in Lua
local Queue = {}
Queue.__index = Queue

-- Create a new queue
function Queue:new()
	local instance = { first = 1, last = 0, items = {} }
	setmetatable(instance, Queue)
	return instance
end

-- Add an item to the end of the queue (enqueue)
function Queue:enqueue(item)
	if item._inQueue then
		return
	end
	self.last = self.last + 1
	self.items[self.last] = item
	item._inQueue = true
end

-- Remove an item from the front of the queue (dequeue)
function Queue:dequeue()
	if self.first > self.last then
		return nil -- Queue is empty
	end
	local item = self.items[self.first]
	self.items[self.first] = nil -- Clear the reference
	self.first = self.first + 1
	item._inQueue = false
	return item
end

-- Check if the queue is empty
function Queue:isEmpty()
	return self.first > self.last
end

-- Peek at the front item without removing it
function Queue:peek()
	return self.items[self.first]
end

-- Get the size of the queue
function Queue:size()
	return self.last - self.first + 1
end

G_RLF.Queue = Queue
