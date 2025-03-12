---@type string, G_RLF
local addonName, G_RLF = ...

---@class Queue<T>
---@field first number
---@field last number
---@field items table
local Queue = {}
Queue.__index = Queue

--- Create a new queue
--- @return Queue
function Queue:new()
	local instance = { first = 1, last = 0, items = {} }
	setmetatable(instance, Queue)
	return instance
end

--- Add an item to the end of the queue (enqueue)
--- @generic T
--- @param item T
function Queue:enqueue(item)
	if item._inQueue then
		return
	end
	self.last = self.last + 1
	self.items[self.last] = item
	item._inQueue = true
end

--- Remove an item from the front of the queue (dequeue)
--- @generic T
--- @return T | nil
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

--- Check if the queue is empty
--- @return boolean
function Queue:isEmpty()
	return self.first > self.last
end

--- Peek at the front item without removing it
--- @generic T
--- @return T | nil
function Queue:peek()
	return self.items[self.first]
end

--- Get the size of the queue
--- @return number
function Queue:size()
	return self.last - self.first + 1
end

G_RLF.Queue = Queue
