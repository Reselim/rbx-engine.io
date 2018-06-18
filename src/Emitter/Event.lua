local Event = {}
Event.__index = Event

function Event.new()
	return setmetatable({
		_bindable = Instance.new("BindableEvent")
	}, Event)
end

function Event:Fire(...)
	self._args = {...}
	self._bindable:Fire()
	self._args = nil
end

function Event:Connect(handler)
	return self._bindable.Event:Connect(function()
		handler(unpack(self._args))
	end)
end

function Event:Wait()
	self._bindable.Event:Wait()
	return unpack(self._args)
end

return Event
