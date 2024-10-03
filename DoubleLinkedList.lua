local _, G_RLF = ...

local list = {}
list.__index = list

setmetatable(list, {
	__call = function(_, ...)
		local t = setmetatable({
			length = 0,
		}, list)
		for _, v in ipairs({ ... }) do
			t:push(v)
		end
		return t
	end,
})

function list:push(t)
	-- Check if node is already in the list (to avoid circular references)
	if t._next or t._prev or t._inList then
		return false
	end

	if self.last then
		self.last._next = t
		t._prev = self.last
		self.last = t
	else
		-- this is the first node
		self.first = t
		self.last = t
	end

	self.length = self.length + 1
	t._inList = true
	return true
end

function list:unshift(t)
	-- Check if node is already in the list (to avoid circular references)
	if t._next or t._prev or t._inList then
		return false
	end

	if self.first then
		self.first._prev = t
		t._next = self.first
		self.first = t
	else
		self.first = t
		self.last = t
	end

	self.length = self.length + 1
	t._inList = true
	return true
end

function list:pop()
	if not self.last then
		return
	end
	local ret = self.last

	if ret._prev then
		ret._prev._next = nil
		self.last = ret._prev
		ret._prev = nil
	else
		-- this was the only node
		self.first = nil
		self.last = nil
	end

	self.length = self.length - 1
	ret._inList = false
	return ret
end

function list:shift()
	if not self.first then
		return
	end
	local ret = self.first

	if ret._next then
		ret._next._prev = nil
		self.first = ret._next
		ret._next = nil
	else
		self.first = nil
		self.last = nil
	end

	self.length = self.length - 1
	ret._inList = false
	return ret
end

function list:remove(t)
	if not t._inList then
		return
	end
	if t._next then
		if t._prev then
			t._next._prev = t._prev
			t._prev._next = t._next
		else
			-- this was the first node
			t._next._prev = nil
			self.first = t._next
		end
	elseif t._prev then
		-- this was the last node
		t._prev._next = nil
		self.last = t._prev
	else
		-- this was the only node
		self.first = nil
		self.last = nil
	end

	-- Clear next and prev references to avoid dangling pointers
	t._next = nil
	t._prev = nil
	t._inList = false

	self.length = self.length - 1
end

local function iterate(self, current)
	if not current then
		current = self.first
	elseif current then
		current = current._next
	end

	return current
end

function list:iterate()
	return iterate, self, nil
end

G_RLF.list = list
